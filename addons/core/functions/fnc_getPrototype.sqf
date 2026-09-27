#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Resolves any kit class to the prototype class it belongs to.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Prototype class, "" when the class is not a kit <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getPrototype;
 *
 * Public: Yes
 */

params ["_class"];

GVAR(prototypeOf) getOrDefault [toLowerANSI _class, ""]
