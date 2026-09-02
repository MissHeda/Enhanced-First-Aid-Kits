#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Runs an unpack through the ACE progress bar, or straight away when the
 * mission has the unpack time set to zero.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Arguments for the unpack function, without the unit <ARRAY>
 * 2: Unpack function <CODE>
 * 3: Progress bar title <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, ["efak_IFAK_7"], efak_core_fnc_unpackAll, "Unpacking..."] call efak_core_fnc_startUnpack;
 *
 * Public: No
 */

params ["_unit", "_args", "_code", "_title"];

private _time = missionNamespace getVariable [QGVAR(unpackTime), 0];

if (_time <= 0) exitWith {
    ([_unit] + _args) call _code;
};

[
    _time,
    [[_unit] + _args, _code],
    {(_this select 0) params ["_callArgs", "_callCode"]; _callArgs call _callCode},
    {},
    _title
] call ACEFUNC(common,progressBar);
