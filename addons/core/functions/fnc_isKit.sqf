#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Checks whether a classname belongs to any EFAK kit.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * Is a kit <BOOL>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_isKit;
 *
 * Public: Yes
 */

params ["_class"];

(GVAR(prototypeOf) getOrDefault [toLowerANSI _class, ""]) isNotEqualTo ""
