#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001, Blue (KAT), Miss Heda
 * KAT's ace_medical_treatment_fnc_useItem (kat_misc 3.2.0) with EFAK's kit supplies added.
 *
 * KAT and EFAK both replace this ACE function: KAT to take supplies out of a shared vehicle in its
 * own order, EFAK to take them out of a kit. Whichever of the two loaded last would win and the other
 * would silently lose its part, so this compat - loaded after both - carries both. Everything outside
 * the lines marked EFAK is KAT's code with its macros written out.
 *
 * Used with every KAT version - KAT's useItem is the same in 3.2.0 and 3.2.1 and rarely changes.
 * Bring this copy up to date when it does.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * User and Item and Litter Created <ARRAY>
 *
 * Example:
 * [player, cursorObject, ["ACE_fieldDressing"]] call ace_medical_treatment_fnc_useItem
 *
 * Public: No
 */

if (isNil "efak_compat_kat_useCopies") then {
    efak_compat_kat_useCopies = true;
};
if (!efak_compat_kat_useCopies) exitWith {
    if (isNil "efak_compat_kat_efakUseItem") then {
        efak_compat_kat_efakUseItem = compile preprocessFileLineNumbers "\z\efak\addons\medical\overrides\fnc_useItem.sqf";
    };
    _this call efak_compat_kat_efakUseItem
};

// A fourth argument, true, makes it a dry run, see EFAK's own (addons\medical\overrides).
params ["_medic", "_patient", "_items", ["_dryRun", false]];

if (_medic isEqualTo player && {!isNull findDisplay 312}) exitWith {
    if (_dryRun) exitWith {""};
    [_medic, _items select 0, false]
};

scopeName "Main";

private _sharedUseOrder = [[_patient, _medic],
    [_medic, _patient],
    [_medic],
    ([[_patient, _medic],[_medic, _patient]] select ([_medic] call ace_medical_treatment_fnc_isMedic))
] select ace_medical_treatment_allowSharedEquipment;

private _useOrder = [];

private _vehicle = objectParent _medic;
private _vehicleCondition = !(isNull _vehicle) && _vehicle isEqualTo (objectParent _patient);
private _vehicleIndex = -1;

if (kat_misc_allowSharedVehicleEquipment > 0 && _vehicleCondition) then {
    switch (kat_misc_allowSharedVehicleEquipment) do {
        case 1: { // Medic's equipment first
            _useOrder = [_medic,_vehicle] + _sharedUseOrder;
            _vehicleIndex = 1;
        };
        case 2: { // Vehicle's equipment first (no self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 3: { // Vehicle's equipment first (except self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder + [_vehicle];
                _vehicleIndex = (count _useOrder) - 1;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 4: { // Vehicle's equipment first (always)
            _useOrder = ([_vehicle] + _sharedUseOrder);
            _vehicleIndex = 0;
        };
        default {
            _useOrder = _sharedUseOrder;
        };
    };
} else {
    _useOrder = _sharedUseOrder;
};

// ----- EFAK -----
// Kit supplies, tried per unit - KAT's order, or the medic's or the patient's first, as the mission
// sets it. Whether they go before or after the loose items is EFAK's setting.
private _units = _useOrder select {_x isKindOf "CAManBase"};
private _fnc_fromKits = {
    params ["_mode"];

    private _kitOrder = switch (missionNamespace getVariable ["efak_medical_kitOwnerOrder", 0]) do {
        case 1: {[_medic, _patient] arrayIntersect _units};
        case 2: {[_patient, _medic] arrayIntersect _units};
        default {_units};
    };

    {
        ([_x, _items, _mode] call efak_medical_fnc_findInKits) params ["_kitClass", "_itemClass"];

        if (_kitClass isNotEqualTo "") then {
            if (_dryRun) then {
                ([_x, _kitClass] call efak_medical_fnc_kitSourceKey) breakOut "Main";
            };

            if (([_itemClass] call efak_core_fnc_getMagazineSize) > 1) then {
                private _left = [_x, _kitClass, _itemClass] call efak_medical_fnc_useCharge;
                [_x, _itemClass, _left <= 0] breakOut "Main";
            };

            [_x, _kitClass, _itemClass, 1] call efak_medical_fnc_takeFromKit;
            [_x, _itemClass, true] breakOut "Main";
        };
    } forEach _kitOrder;
};

private _order = missionNamespace getVariable ["efak_medical_useOrder", 0];

switch (_order) do {
    case 1: {[0] call _fnc_fromKits};   // kits first
    case 2: {[2] call _fnc_fromKits};   // kits lying nearby first
};
// ----- EFAK end -----

{
    private _origin = _x;
    if (_forEachIndex != _vehicleIndex) then { // Remove unit item
        // EFAK: loose items only - a packed one is taken out of its kit by _fnc_fromKits
        private _originItems = [_origin, 0] call efak_medical_fnc_looseItems; // Item

        if (_dryRun && {(_items findAny (_originItems + ([_origin, 2] call efak_medical_fnc_looseItems))) != -1}) then {
            (["patient", "medic"] select (_origin isEqualTo _medic)) breakOut "Main";
        };

        {
            if (_x in _originItems) then {
                _origin removeItem _x;
                [_origin, _x, true] breakOut "Main";
            };
        } forEach _items;

        _originItems = [_origin, 2] call efak_medical_fnc_looseItems; // Magazine
        {
            if (_x in _originItems) then {
                private _magsStart = count magazines _origin;
                [_origin, _x] call ace_common_fnc_adjustMagazineAmmo;
                private _magsEnd = count magazines _origin;
                [_origin, _x, (_magsEnd < _magsStart)] breakOut "Main";
            };
        } forEach _items;
    } else { // Remove vehicle item
        private _originItems = [_origin, 0] call ace_common_fnc_uniqueItems; // Item

        if (_dryRun && {(_items findAny (_originItems + ([_origin, 2] call ace_common_fnc_uniqueItems))) != -1}) then {
            "vehicle" breakOut "Main";
        };

        {
            if (_x in _originItems) then {
                _origin addItemCargoGlobal [_x, -1];
                [_origin, _x, false] breakOut "Main";
            };
        } forEach _items;

        _originItems = [_origin, 2] call ace_common_fnc_uniqueItems; // Magazine
        {
            if (_x in _originItems) then {
                [_origin, _x] call ace_common_fnc_adjustMagazineAmmo;
                [_origin, _x, false] breakOut "Main";
            };
        } forEach _items;
    };
} forEach _useOrder;

// ----- EFAK -----
switch (_order) do {
    case 0: {[0] call _fnc_fromKits};   // loose items first, kits last
    case 2: {[1] call _fnc_fromKits};   // the carried kits last
};

if (_dryRun) exitWith {""};

[objNull, "", false]
