// ACM ACM_breathing_fnc_useOxygenTankReserve, kit-aware for EFAK. Not a copy: with an oxygen tank loose in
// the uniform, vest or backpack ACM's own function draws the breath as always. Without one, it comes out
// of a tank packed in a kit, which stays in the kit - and when it is empty, so does the empty tank
// (efak_medical_fnc_drawCharge). Runs with ACM Extended too, whose function is the same here.

private _original = missionNamespace getVariable "efak_compat_acm_original_useOxygenTankReserve";
if (isNil "_original") then {
    _original = compile preprocessFileLineNumbers "\x\ACM\addons\breathing\functions\fnc_useOxygenTankReserve.sqf";
    missionNamespace setVariable ["efak_compat_acm_original_useOxygenTankReserve", _original];
};

params ["_unit"];

if (([_unit, "ACM_OxygenTank_425"] call efak_medical_fnc_countLoose) > 0) exitWith {_this call _original};

private _left = [_unit, "ACM_OxygenTank_425", "ACM_OxygenTank_425_Empty"] call efak_medical_fnc_drawCharge;

// ACM's answer: a breath with oxygen, and the tank not empty yet.
_left > 0
