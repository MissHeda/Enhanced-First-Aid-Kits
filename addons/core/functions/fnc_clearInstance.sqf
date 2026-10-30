#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Server only. Wipes what an instance id still remembers from the kit that had it last - contents,
 * opened magazines, the defaults flag and its name - right before the id goes to a new kit.
 *
 * fnc_freeInstance leaves all of that in place on purpose: the kit may come back (see there).
 *
 * Arguments:
 * 0: Instance class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_clearInstance;
 *
 * Public: No
 */

params ["_class"];

private _key = toLowerANSI _class;

if (_key in GVAR(contents) || {_key in GVAR(charges)}) then {
    [QGVAR(contentsChanged), [_class, [], []]] call CBA_fnc_globalEvent;
};

if (_key in GVAR(followDefaults)) then {
    [QGVAR(followDefaultsChanged), [_class, false]] call CBA_fnc_globalEvent;
};

if (_key in GVAR(labels)) then {
    [QGVAR(labelChanged), [_class, ""]] call CBA_fnc_globalEvent;
};
