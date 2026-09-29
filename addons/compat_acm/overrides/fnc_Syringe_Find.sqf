// ACM ACM_circulation_fnc_Syringe_Find, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so empty syringes in a kit were not found.
/*
 * Author: Blue
 * Find if medic has syringe in inventory
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Size <NUMBER>
 *
 * Return Value:
 * Found syringe? <BOOL>
 *
 * Example:
 * [player, 0] call ACM_circulation_fnc_Syringe_Find;
 *
 * Public: No
 */

params ["_medic", ["_size", 0]];

// kit contents come back in lower case, and "in" is case-sensitive
private _cachedItems = ([_medic, 1] call efak_medical_fnc_listItems) apply {toLowerANSI _x};

private _array = switch (_size) do {
    case 10: {ACM_circulation_SyringeList_10};
    case 5: {ACM_circulation_SyringeList_5};
    case 3: {ACM_circulation_SyringeList_3};
    case 1: {missionNamespace getVariable ["ACM_circulation_SyringeList_13", []]};
    default {ACM_circulation_SyringeList_10 + ACM_circulation_SyringeList_5 + ACM_circulation_SyringeList_3 + (missionNamespace getVariable ["ACM_circulation_SyringeList_13", []])};
};

private _index = _array findIf {toLowerANSI _x in _cachedItems};

if (_index != -1) exitWith {true};

false;