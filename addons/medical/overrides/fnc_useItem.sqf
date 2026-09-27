#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001, Miss Heda
 * Uses one of the treatment items. Respects the priority defined by the allowSharedEquipment setting.
 *
 * OVERRIDE of ace_medical_treatment_fnc_useItem, installed through CfgFunctions - see fnc_hasItem
 * for why. Everything outside the lines marked EFAK is ACE's own code; keep it in step when ACE
 * changes.
 *
 * EFAK: the item can also be spent straight out of a kit. By default carried items go first, so
 * a kit is only touched once the pockets are empty; efak_medical_useOrder can turn that around.
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
 * [player, cursorObject, ["bandage"]] call ace_medical_treatment_fnc_useItem
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

if (_medic isEqualTo player && {!isNull findDisplay 312}) exitWith {
    [_medic, _items select 0, false] // return
};

scopeName "Main";

// ----- EFAK -----
// Kit supplies, tried per unit - in ACE's own order, or the medic's or the patient's first, as the
// mission sets it; never the patient's where ACE allows the medic's supplies only. Whether they go
// before or after the loose items is EFAK's setting too.
private _fnc_fromKits = {
    private _kitOrder = switch (missionNamespace getVariable [QGVAR(kitOwnerOrder), KIT_OWNER_ACE]) do {
        case KIT_OWNER_MEDIC: {[_medic, _patient] arrayIntersect _useOrder};
        case KIT_OWNER_PATIENT: {[_patient, _medic] arrayIntersect _useOrder};
        default {_useOrder};
    };

    {
        ([_x, _items] call FUNC(findInKits)) params ["_kitClass", "_itemClass"];

        if (_kitClass isNotEqualTo "") then {
            private _size = [_itemClass] call EFUNC(core,getMagazineSize);

            // A magazine of several rounds - a pill bottle, where ACE takes one round of a loose one -
            // gives one round and stays in the kit, opened (fnc_useCharge). Litter only for the last
            // round, as ACE does for a loose one.
            if (_size > 1) then {
                private _left = [_x, _kitClass, _itemClass] call FUNC(useCharge);

                [_x, _itemClass, _left <= 0] breakOut "Main"; // return
            };

            [_x, _kitClass, _itemClass, 1] call FUNC(takeFromKit);

            // Litter is made as if it had come out of a pocket, because as far as the treatment
            // is concerned it did.
            [_x, _itemClass, true] breakOut "Main"; // return
        };
    } forEach _kitOrder;
};

private _kitsFirst = (missionNamespace getVariable [QGVAR(useOrder), 0]) == 1;
// ----- EFAK end -----

private _allowSharedEquipment = ACEGVAR(medical_treatment,allowSharedEquipment);
if (_allowSharedEquipment == 3) then { _allowSharedEquipment = parseNumber ([_medic] call ACEFUNC(medical_treatment,isMedic)) };
private _useOrder = [[_patient, _medic], [_medic, _patient], [_medic]] select _allowSharedEquipment;

if (_kitsFirst) then {call _fnc_fromKits}; // EFAK

{
    private _unit = _x;
    private _unitVehicle = objectParent _unit;
    // EFAK: loose only - a packed item is taken out of its kit by _fnc_fromKits.
    private _unitItems = [_x, 0] call FUNC(looseItems);
    private _unitMagazines = [_x, 2] call FUNC(looseItems);
    private _vehicleItems = itemCargo _unitVehicle; // [] for objNull
    private _vehicleMagazines = magazineCargo _unitVehicle; // same

    {
        switch (true) do {
            case (_x in _vehicleItems): {
                _unitVehicle addItemCargoGlobal [_x, -1];
                [_unit, _x, false] breakOut "Main"; // return
            };
            case (_x in _vehicleMagazines): {
                [_unitVehicle, _x] call ACEFUNC(common,adjustMagazineAmmo);
                [_unit, _x, false] breakOut "Main"; // return
            };
            case (_x in _unitItems): {
                _unit removeItem _x;
                [_unit, _x, true] breakOut "Main"; // return
            };
            case (_x in _unitMagazines): {
                private _magsStart = count magazines _unit;
                [_unit, _x] call ACEFUNC(common,adjustMagazineAmmo);
                private _magsEnd = count magazines _unit;
                [_unit, _x, (_magsEnd < _magsStart)] breakOut "Main"; // return
            };
        };
    } forEach _items;
} forEach _useOrder;

// ----- EFAK -----
if (!_kitsFirst) then {call _fnc_fromKits};

[objNull, "", false] // return
