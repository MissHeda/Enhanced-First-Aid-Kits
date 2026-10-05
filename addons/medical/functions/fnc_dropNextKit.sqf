#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts the next kit down at the unit's feet (getDropKit), so a medic who reaches a casualty can
 * set the bag down and treat out of it lying there (usableKits).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * A kit was put down <BOOL>
 *
 * Example:
 * [player] call efak_medical_fnc_dropNextKit;
 *
 * Public: No
 */

params ["_unit"];

if (!alive _unit || {!isNull objectParent _unit} || {!([_unit] call ACEFUNC(common,isAwake))}) exitWith {false};

private _kit = [_unit] call FUNC(getDropKit);

if (_kit isEqualTo "") exitWith {false};

[_unit, _kit] call EFUNC(core,dropKit)
