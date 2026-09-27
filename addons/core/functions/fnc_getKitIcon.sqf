#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the interaction icon of a kit.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Icon path <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitIcon;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {""};

_kit select KIT_ICON
