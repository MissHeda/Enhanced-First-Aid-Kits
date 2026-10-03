// ACM ACM_circulation_fnc_canConnectAED, kit-aware for EFAK. Copied from ACM 1.5.0.4 (the same in 1.4.8) with
// its macros written out; ACM looks for the AED with "items _medic" only, so one packed in a kit could never be
// connected. Connecting does not take the AED out of the inventory, so asking is all that changes.

// This copy always stands in for ACM, whatever its version - ACM rarely touches these functions.
// Only ACM Extended, which ships its own reworked ACM that already looks into kits, runs its own
// function from its own file, untouched.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};
if (!efak_compat_acm_useCopies) exitWith {
    private _original = missionNamespace getVariable "efak_compat_acm_original_canConnectAED";
    if (isNil "_original") then {
        _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_canConnectAED.sqf";
        missionNamespace setVariable ["efak_compat_acm_original_canConnectAED", _original];
    };
    call _original
};

/*
 * Author: Blue
 * Check if medic can connect AED to patient
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Can connect AED <BOOL>
 *
 * Example:
 * [player, cursorTarget] call ACM_circulation_fnc_canConnectAED;
 *
 * Public: No
 */

params ["_medic", "_patient"];

private _targetPatient = _medic getVariable ["ACM_circulation_AED_Target_Patient", objNull];

((([_medic, "ACM_AED"] call efak_medical_fnc_countItem) > 0) || [_patient] call ACM_circulation_fnc_hasAED) && ((isNull _targetPatient) || (_targetPatient isEqualTo _patient));
