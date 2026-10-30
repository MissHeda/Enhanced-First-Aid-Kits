#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Server only. Takes kits somebody carries back out of the pool, together with the kits packed
 * inside them.
 *
 * A kit id goes back to the pool when the server thinks the kit is gone: its unit was deleted (a
 * player who disconnected, a body cleared away). Missions that save gear with getUnitLoadout hand
 * those very kits back on reconnect or respawn, often before the server has seen them on the new
 * unit. Their contents are still there (fnc_freeInstance keeps them), but an id in the pool would
 * sooner or later go to a second kit, and both would share - and empty - one set of contents.
 *
 * Arguments:
 * 0: Kit instance classes <ARRAY>
 * 1: Nesting depth, internal <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [["efak_IFAK_7"]] call efak_core_fnc_claimInstances;
 *
 * Public: No
 */

params [["_classes", [], [[]]], ["_depth", 0]];

{
    if !(_x isEqualType "") then {continue};

    private _key = toLowerANSI _x;

    if (!(_key in GVAR(prototypeOf)) || {_key in GVAR(needsConversion)}) then {continue};

    if !(_key in GVAR(usedInstances)) then {
        GVAR(usedInstances) set [_key, true];
        INFO_1("Kit %1 is carried again - taken back out of the pool.",_x);
    };

    // The depth limit only guards against contents that somehow reference their own kit.
    if (_depth < EFAK_RESTORE_MAX_DEPTH) then {
        private _nested = (GVAR(contents) getOrDefault [_key, []]) apply {_x param [0, ""]};
        [_nested select {(toLowerANSI _x) isNotEqualTo _key}, _depth + 1] call FUNC(claimInstances);
    };
} forEach _classes;
