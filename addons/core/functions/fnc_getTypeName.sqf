#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The name a mission gave a whole kit type in its settings ("Name"), or "" while it keeps its own.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Name <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getTypeName;
 *
 * Public: Yes
 */

params [["_class", "", [""]]];

if (count GVAR(typeNames) == 0) exitWith {""};

GVAR(typeNames) getOrDefault [toLowerANSI (GVAR(prototypeOf) getOrDefault [toLowerANSI _class, ""]), ""]
