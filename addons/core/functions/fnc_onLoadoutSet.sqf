#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * CBA_loadoutSet handler. Runs right after setUnitLoadout, on the machine that
 * called CBA_fnc_setLoadout, and passes what fnc_onPreLoadoutSet collected to
 * the machine that owns the unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Loadout <ARRAY>
 * 2: Extended info <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["CBA_loadoutSet", {_this call efak_core_fnc_onLoadoutSet}] call CBA_fnc_addEventHandler;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

private _state = _unit getVariable QGVAR(loadoutSetState);

if (isNil "_state") exitWith {};

_unit setVariable [QGVAR(loadoutSetState), nil];

_state params ["_queue", "_heldBefore"];

if (local _unit) exitWith {
    [_unit, _queue, _heldBefore] call FUNC(applyLoadoutRestore);
};

if (count _queue == 0 && {_heldBefore isEqualTo []}) exitWith {};

// Only the owner converts, and only the owner can tell which kits the set destroyed. It may already
// have started converting the new prototypes with the default contents by the time this arrives;
// the generation it bumps sends those instances back unused.
[QGVAR(restoreLoadoutKits), [_unit, toArray _queue, _heldBefore], _unit] call CBA_fnc_targetEvent;
