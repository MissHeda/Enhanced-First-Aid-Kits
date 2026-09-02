#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the display name of any item, falling back to the classname.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * Display name <STRING>
 *
 * Example:
 * ["ACE_fieldDressing"] call efak_core_fnc_getItemName;
 *
 * Public: Yes
 */

params ["_class"];

private _config = _class call CBA_fnc_getItemConfig;

if (isNull _config) exitWith {_class};

private _name = getText (_config >> "displayName");

if (_name isEqualTo "") exitWith {_class};

_name
