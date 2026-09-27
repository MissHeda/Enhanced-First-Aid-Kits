#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001, Miss Heda
 * Checks if one of the given items are present between the medic and patient.
 *
 * OVERRIDE of ace_medical_treatment_fnc_hasItem, installed through CfgFunctions - ACE compiles
 * its functions final, so the variable cannot be reassigned at runtime and a config level
 * override is the only way in. Everything above the EFAK block is ACE's own code; keep it in step
 * when ACE changes.
 *
 * EFAK: a kit counts as a place the item can come from.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * Has Item <BOOL>
 *
 * Example:
 * [player, cursorObject, ["ACE_fieldDressing"]] call ace_medical_treatment_fnc_hasItem
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

private _fnc_checkItems = {
    params ["_unit"];

    private _unitItems = +([_unit, 1] call FUNC(looseItems)); // EFAK: loose only, kits are asked below
    private _unitVehicle = objectParent _unit;
    if (!isNull _unitVehicle) then {
        _unitItems append (itemCargo _unitVehicle);
        _unitItems append (magazineCargo _unitVehicle);
    };
    _items findAny _unitItems != -1
};

private _shared = ACEGVAR(medical_treatment,allowSharedEquipment) != 2;

if (_medic call _fnc_checkItems || {_shared && {_patient call _fnc_checkItems}}) exitWith {true};

// ----- EFAK -----
// Whether, not which - that comes out of the table the medical menu keeps warm anyway.
private _fnc_inKits = {
    private _counts = [_this] call FUNC(kitCounts);

    (_items findIf {(_counts getOrDefault [toLowerANSI _x, 0]) > 0}) != -1
};

if (_medic call _fnc_inKits) exitWith {true};

_shared && {_patient call _fnc_inKits}
