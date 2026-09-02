#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns what is inside a kit instance.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 *
 * Return Value:
 * Contents <ARRAY> of [class, count]
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getContents;
 *
 * Public: Yes
 */

params ["_class"];

+(GVAR(contents) getOrDefault [toLowerANSI _class, []])
