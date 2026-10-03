// ACM ACM_circulation_fnc_Syringe_Find, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so empty syringes in a kit were not found.

// This copy always stands in for ACM, whatever its version - ACM rarely touches these functions.
// Only ACM Extended, which ships its own reworked ACM that already looks into kits, runs its own
// function from its own file, untouched.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};
if (!efak_compat_acm_useCopies) exitWith {
    private _original = missionNamespace getVariable "efak_compat_acm_original_Syringe_Find";
    if (isNil "_original") then {
        _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_Syringe_Find.sqf";
        missionNamespace setVariable ["efak_compat_acm_original_Syringe_Find", _original];
    };
    call _original
};

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