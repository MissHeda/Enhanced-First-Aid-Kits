// ACM ACM_circulation_fnc_Syringe_GetMedicationList, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so vials in a kit were not offered.
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