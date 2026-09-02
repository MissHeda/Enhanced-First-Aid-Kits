#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the display name of a kit. Mission makers can rename every kit in the
 * CBA settings - that override is what the interaction menu and the pouch UI use.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Display name <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitName;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {_class};

private _custom = missionNamespace getVariable [format [QGVAR(kit_%1_displayName), _kit select KIT_ID], ""];

if (_custom isEqualTo "") exitWith {_kit select KIT_NAME};

_custom
