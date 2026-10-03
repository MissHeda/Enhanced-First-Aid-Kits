// ACM ACM_circulation_fnc_Syringe_GetMedicationList, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so vials in a kit were not offered.

// This copy always stands in for ACM, whatever its version - ACM rarely touches these functions.
// Only ACM Extended, which ships its own reworked ACM that already looks into kits, runs its own
// function from its own file, untouched.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};
if (!efak_compat_acm_useCopies) exitWith {
    private _original = missionNamespace getVariable "efak_compat_acm_original_Syringe_GetMedicationList";
    if (isNil "_original") then {
        _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_Syringe_GetMedicationList.sqf";
        missionNamespace setVariable ["efak_compat_acm_original_Syringe_GetMedicationList", _original];
    };
    call _original
};

/*
 * Author: Blue
 * Update medication list
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Medication List <ARRAY<STRING>>
 *
 * Example:
 * [] call ACM_circulation_fnc_Syringe_GetMedicationList;
 *
 * Public: No
 */

params [];

private _targetInventory = switch (ACM_circulation_SyringeDraw_InventorySelection) do {
    case 1: {[ACM_circulation_SyringeDraw_Target] call efak_medical_fnc_listItems};
    case 2: {};
    default {[ACE_player] call efak_medical_fnc_listItems};
};

private _medicationList = [];

// Kit contents come back in lower case and "in" compares case-sensitively: match without case and
// hand ACM its own spelling of the vial.
private _vials = createHashMapFromArray (ACM_circulation_MedicationVialList apply {[toLowerANSI _x, _x]});

{
    private _vial = _vials get (toLowerANSI _x);
    if (!isNil "_vial") then {
        _medicationList pushBackUnique _vial;
    };
} forEach (if (isNil "_targetInventory") then {[]} else {_targetInventory});

_medicationList;