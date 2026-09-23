#include "..\script_component.hpp"
/*
 * Author: AmsteadRayle, Miss Heda
 * Counts how many of the given items are present between the medic and patient.
 *
 * OVERRIDE of ace_medical_gui_fnc_countTreatmentItems, installed through CfgFunctions - see
 * fnc_hasItem for why. Everything above the EFAK block is ACE's own code; keep it in step when
 * ACE changes.
 *
 * EFAK: a fourth count for what is sitting in kits. It is handed to the formatter through a
 * variable rather than as a fourth array entry, because the array carries nil entries for the
 * patient and the vehicle when those do not apply.
 *
 * Arguments:
 * 0: Items <ARRAY>
 *
 * Return Value:
 * Counts (can be nil) <ARRAY>
 *
 * Example:
 * [items] call ace_medical_gui_fnc_countTreatmentItems
 *
 * Public: No
 */

params ["_items"];

private _medicCount = 0;
private _patientCount = nil;
private _vehicleCount = nil;
private _target = ACEGVAR(medical_gui,target);

// Medic
{
    _medicCount = _medicCount + ([ACE_player, _x] call FUNC(countLoose)); // EFAK: loose only, the kits have a line of their own
} forEach _items;

// Patient
if (ACE_player != _target) then {
    _patientCount = 0;
    {
        _patientCount = _patientCount + ([_target, _x] call FUNC(countLoose)); // EFAK
    } forEach _items;
};

// Vehicle
private _medicVehicle = objectParent ACE_player;
private _patientVehicle = objectParent _target;
private _vehicle = [_patientVehicle, _medicVehicle] select (!isNull _medicVehicle);

if (!isNull _vehicle) then {
    _vehicleCount = 0;
    private _magazineItems = [];
    private _itemItems = [];
    {
        if (isClass (configFile >> "CfgMagazines" >> _x)) then {
            _magazineItems pushBack _x;
        } else {
            _itemItems pushBack _x;
        };
    } forEach _items;
    if (_magazineItems isNotEqualTo []) then {
        (getMagazineCargo _vehicle) params ["_itemTypes", "_itemCounts"];
        {
            _vehicleCount = _vehicleCount + (_itemCounts param [_itemTypes find _x, 0]);
        } forEach _magazineItems;
    };
    if (_itemItems isNotEqualTo []) then {
        (getItemCargo _vehicle) params ["_itemTypes", "_itemCounts"];
        {
            _vehicleCount = _vehicleCount + (_itemCounts param [_itemTypes find _x, 0]);
        } forEach _itemItems;
    };
};

// ----- EFAK -----
// One count per kit type, in registry order - "6 in IFAK", "3 in AFAK". Only kit types
// treatments may use are counted at all, so a switched off one never shows up.
GVAR(lastKitCounts) = [];

// An AI patient's kits may still be prototypes, which hold nothing yet. Reaching for them turns
// them into real kits, so they count the next time the menu looks.
[_target] call EFUNC(core,requestUnitKits);

private _units = [ACE_player];

if (ACE_player != _target && {ACEGVAR(medical_treatment,allowSharedEquipment) != 2}) then {
    _units pushBack _target;
};

private _perUnit = _units apply {[_x, true] call FUNC(kitCounts)};

{
    private _kit = EGVAR(core,kits) get (toLowerANSI _x);
    private _type = _kit select KIT_ID;
    private _count = 0;

    {
        private _ofType = _x getOrDefault [_type, createHashMap];

        {
            _count = _count + (_ofType getOrDefault [toLowerANSI _x, 0]);
        } forEach _items;
    } forEach _perUnit;

    if (_count > 0) then {
        GVAR(lastKitCounts) pushBack [_kit select KIT_SHORT_NAME, _count];
    };
} forEach EGVAR(core,kitList);

[_medicCount, _patientCount, _vehicleCount]
