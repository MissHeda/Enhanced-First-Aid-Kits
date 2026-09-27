#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether an object is holding a given kit instance. A kit is not always on a person - it can be
 * sitting in a crate or a vehicle, and those answer to a different set of commands.
 *
 * Arguments:
 * 0: Unit or container <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * Holds it <BOOL>
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_core_fnc_holderHasKit;
 *
 * Public: No
 */

params ["_holder", "_kitClass"];

if (isNull _holder) exitWith {false};

private _key = toLowerANSI _kitClass;

if (_holder isKindOf "CAManBase") exitWith {
    (items _holder) findIf {(toLowerANSI _x) isEqualTo _key} > -1
};

((getItemCargo _holder) param [0, []]) findIf {(toLowerANSI _x) isEqualTo _key} > -1
