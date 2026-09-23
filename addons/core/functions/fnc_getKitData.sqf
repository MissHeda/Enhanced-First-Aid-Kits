#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the cached kit data for any kit class (prototype or instance).
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Kit data, [] when the class is not a kit <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitData;
 *
 * Public: Yes
 */

params ["_class"];

private _prototype = GVAR(prototypeOf) getOrDefault [toLowerANSI _class, ""];

if (_prototype isEqualTo "") exitWith {[]};

GVAR(kits) getOrDefault [toLowerANSI _prototype, []]
