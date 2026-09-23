#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The short name of a kit - "IFAK", "MFAK+" - for where the full name takes too much room, like the
 * ACE interaction menu. Falls back to the registry class name.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Short name <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitShortName;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {_class};

_kit param [KIT_SHORT_NAME, _kit select KIT_ID]
