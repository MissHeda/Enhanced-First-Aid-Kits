#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives a unit its own copy of every kit it shares with a body.
 *
 * A mission that hands the gear back on respawn with plain setUnitLoadout (a loadout read with
 * getUnitLoadout when the player died) puts the very same kit ids on the new unit that the old
 * body still carries - CBA_fnc_setLoadout, which ACE's respawn uses, goes through
 * fnc_onPreLoadoutSet and never does. Two kits with one id share one set of contents, and once
 * the body is cleared away its ids go back to the pool, emptying the kit the player still has.
 *
 * Every shared kit turns back into its prototype, with its current contents in the restore queue,
 * and fnc_convertKits fetches a fresh id for it. The body keeps the old one, contents and all.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call efak_core_fnc_dedupeKits;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit || {!local _unit}) exitWith {};

private _mine = [_unit] call FUNC(getCarriedKits);

if (_mine isEqualTo []) exitWith {};

private _bodies = allDeadMen - [_unit];

if (_bodies isEqualTo []) exitWith {};

private _theirs = createHashMap;

{
    {
        _theirs set [toLowerANSI _x, true];
    } forEach ([_x] call FUNC(getCarriedKits));
} forEach _bodies;

private _shared = _mine select {(toLowerANSI _x) in _theirs};

if (_shared isEqualTo []) exitWith {};

(_unit getVariable [QGVAR(restoreQueue), []]) params [["_expires", -1], ["_queue", createHashMap]];

if (_expires < 0 || {CBA_missionTime > _expires}) then {
    _queue = createHashMap;
};

// Read before anything is swapped: every copy of a shared kit in every container.
private _containers = [
    [LOADOUT_SLOT_UNIFORM, uniformItems _unit],
    [LOADOUT_SLOT_VEST, vestItems _unit],
    [LOADOUT_SLOT_BACKPACK, backpackItems _unit]
];

{
    private _class = _x;
    private _key = toLowerANSI _class;
    private _prototype = GVAR(prototypeOf) get _key;
    private _contents = if (_key in GVAR(followDefaults)) then {LOADOUT_KIT_DEFAULT} else {[_class] call FUNC(getContentsTree)};

    {
        _x params ["_slot", "_items"];

        for "_i" from 1 to ({(toLowerANSI _x) isEqualTo _key} count _items) do {
            if ([_unit, _class, _prototype, _slot] call FUNC(replaceItem)) then {
                private _queueKey = format ["%1:%2", _slot, toLowerANSI _prototype];
                private _list = _queue getOrDefault [_queueKey, []];
                _list pushBack +_contents;
                _queue set [_queueKey, _list];
            };
        };
    } forEach _containers;

    INFO_2("%1 shared kit %2 with a body - it gets a copy of its own.",_unit,_class);
} forEach _shared;

_unit setVariable [QGVAR(restoreQueue), [CBA_missionTime + EFAK_RESTORE_TIMEOUT, _queue]];

[_unit] call FUNC(convertKits);
