#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Server only. Hands out a free instance class from a kit's pool.
 *
 * Arguments:
 * 0: Prototype class <STRING>
 *
 * Return Value:
 * Instance class, "" on failure <STRING>
 *
 * Example:
 * ["efak_IFAK"] call efak_core_fnc_allocateInstance;
 *
 * Public: No
 */

params ["_prototype"];

private _kit = [_prototype] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {""};

private _max = _kit select KIT_INSTANCES;
private _key = toLowerANSI _prototype;
private _next = GVAR(nextInstance) getOrDefault [_key, 1];
private _result = "";

for "_i" from 0 to (_max - 1) do {
    private _id = ((_next + _i - 1) % _max) + 1;
    private _class = format ["%1_%2", _prototype, _id];

    if !((toLowerANSI _class) in GVAR(usedInstances)) exitWith {
        _result = _class;
        GVAR(nextInstance) set [_key, (_id % _max) + 1];
    };
};

if (_result isEqualTo "") then {
    // Every id of this kit is in use somewhere in the world. Recycling the
    // oldest one is better than handing out nothing - the kit that owned it
    // simply falls back to the default contents.
    _result = format ["%1_%2", _prototype, _next];
    GVAR(nextInstance) set [_key, (_next % _max) + 1];
    WARNING_2("Instance pool for '%1' exhausted (%2 in use), recycling.",_prototype,_max);
};

GVAR(usedInstances) set [toLowerANSI _result, true];

_result
