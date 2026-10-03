// ACM ACM_circulation_fnc_Syringe_PrepareFinish, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so the vial and syringe must come out of a kit when that is where they are.

// This copy always stands in for ACM, whatever its version - ACM rarely touches these functions.
// Only ACM Extended, which ships its own reworked ACM that already looks into kits, runs its own
// function from its own file, untouched.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};
if (!efak_compat_acm_useCopies) exitWith {
    private _original = missionNamespace getVariable "efak_compat_acm_original_Syringe_PrepareFinish";
    if (isNil "_original") then {
        _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_Syringe_PrepareFinish.sqf";
        missionNamespace setVariable ["efak_compat_acm_original_Syringe_PrepareFinish", _original];
    };
    call _original
};

/*
 * Author: Blue
 * Finish preparing medication into syringe
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Medication Classname <STRING>
 * 2: Dose (mL) <NUMBER>
 * 3: Syringe Size <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 'Epinephrine', 1, 10] call ACM_circulation_fnc_Syringe_PrepareFinish;
 *
 * Public: No
 */

params ["_medic", "_medication", "_dose", ["_size", 10]];

switch (ACM_circulation_SyringeDraw_InventorySelection) do {
    case 1: {
        [ACM_circulation_SyringeDraw_Target, format ["ACM_Vial_%1", _medication]] call efak_medical_fnc_takeItem;
    };
    case 2: {
        (objectParent _medic) addItemCargoGlobal [(format ["ACM_Vial_%1", _medication]), -1];
    };
    default {
        [_medic, format ["ACM_Vial_%1", _medication]] call efak_medical_fnc_takeItem;
    };
};

[_medic, format ["ACM_Syringe_%1", _size]] call efak_medical_fnc_takeItem;

[_medic, (format ["ACM_Syringe_%1_%2",_size, _medication]), "", (floor (_dose * 100))] call ace_common_fnc_addToInventory;