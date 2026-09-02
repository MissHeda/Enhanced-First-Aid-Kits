#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the contents a freshly spawned kit of this type starts with.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Contents <ARRAY> of [class, count]
 *
 * Example:
 * ["efak_IFAK"] call efak_core_fnc_getDefaultContents;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {[]};

private _setting = missionNamespace getVariable [
    format [QGVAR(kit_%1_defaultContents), _kit select KIT_ID],
    _kit select KIT_DEFAULTS
];

[_setting] call FUNC(parseContents)
