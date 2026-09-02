#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns an instance class to its pool and clears its contents. Runs on the
 * server, but may be called from anywhere.
 *
 * Arguments:
 * 0: Instance class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_freeInstance;
 *
 * Public: No
 */

params ["_class"];

if !(isServer) exitWith {
    [QGVAR(freeInstance), [_class]] call CBA_fnc_serverEvent;
};

GVAR(usedInstances) deleteAt (toLowerANSI _class);

[QGVAR(contentsChanged), [_class, []]] call CBA_fnc_globalEvent;
