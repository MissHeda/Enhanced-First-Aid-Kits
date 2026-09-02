#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the inventory picture of any item.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * Picture path <STRING>
 *
 * Example:
 * ["ACE_fieldDressing"] call efak_core_fnc_getItemPicture;
 *
 * Public: Yes
 */

params ["_class"];

private _config = _class call CBA_fnc_getItemConfig;

if (isNull _config) exitWith {""};

getText (_config >> "picture")
