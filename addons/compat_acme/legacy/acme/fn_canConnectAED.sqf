// EFAK compat: ACM Extended's own ACM_circulation_fnc_canConnectAED, with every
//   <unit> removeItem <item>
// replaced by
//   [<unit>, <item>] call efak_medical_fnc_takeItem
// which takes a loose one first and otherwise one straight out of an EFAK kit. Nothing else changed,
// apart from what EXTRA in the build script lists for this file.
// Generated from ACM Extended by tools/build_acme_overrides.py - regenerate after an ACM Extended update.
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

(((([_medic, 'ACM_AED'] call efak_medical_fnc_countItem) > 0)) || [_patient] call ACM_circulation_fnc_hasAED) && ((isNull _targetPatient) || (_targetPatient isEqualTo _patient));
