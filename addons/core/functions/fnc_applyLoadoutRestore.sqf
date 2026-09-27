#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Runs where the unit is local, once a loadout has been set on it. Starts a new
 * loadout generation, stores the restore queue for fnc_convertKits and gives
 * back the ids of kits the set destroyed.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Restore queue, "slot:prototype" -> [contents tree, ...] <HASHMAP, or ARRAY as toArray gives it>
 * 2: Kit instances the unit carried before the set <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, createHashMap, []] call efak_core_fnc_applyLoadoutRestore;
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_queue", createHashMap, [createHashMap, []]], ["_heldBefore", [], [[]]]];

if (isNull _unit || {!local _unit}) exitWith {};

// The Eden editor sets loadouts too, but has no running mission and no frame loop.
if (is3DEN) exitWith {
    if (_queue isEqualType []) then {
        _queue = (_queue select 0) createHashMapFromArray (_queue select 1);
    };

    if (_unit in (all3DENEntities select 0)) then {
        // A unit of the mission: its kits stay prototypes (onPreLoadoutSet saw to that), and what
        // they hold goes into the unit's attribute, which the mission hands back to them.
        private _pairs = (keys _queue) apply {[_x, _queue get _x]};
        _unit set3DENAttribute [QGVAR(kitContents), ["", str _pairs] select (_pairs isNotEqualTo [])];
    } else {
        // ACE Arsenal's stand-in unit: real kits right away, so the kits tab can edit them.
        [_unit, _queue] call FUNC(convertKitsNow);
    };
};

// From another machine it comes as "toArray" gives it, [[keys], [values]] (fnc_onLoadoutSet).
if (_queue isEqualType []) then {
    _queue = (_queue select 0) createHashMapFromArray (_queue select 1);
};

// Requests still out belong to the loadout the unit had before. Their grants must not swap a
// prototype this loadout brought for an instance with the default contents, so they are told
// apart by generation and handed back when they arrive.
private _generation = (_unit getVariable [QGVAR(loadoutGeneration), 0]) + 1;

_unit setVariable [QGVAR(loadoutGeneration), _generation];
_unit setVariable [QGVAR(pendingConversions), createHashMap];

// The loadout replaced whatever the unit was given in the Eden editor, so the contents set up there
// must not overwrite what this loadout brought when the kits are converted.
_unit setVariable [QGVAR(editorKits), nil];

if (count _queue == 0) then {
    _unit setVariable [QGVAR(restoreQueue), nil];
} else {
    _unit setVariable [QGVAR(restoreQueue), [CBA_missionTime + EFAK_RESTORE_TIMEOUT, _queue]];
};

// setUnitLoadout deletes the old inventory without a word. Kits that were in it and are not
// carried any more would hold on to their ids for the rest of the mission, and every arsenal load
// would take a few more out of the pool until it starts recycling ids of kits still in use.
if (_heldBefore isNotEqualTo []) then {
    private _carried = ([_unit] call FUNC(getCarriedKits)) apply {toLowerANSI _x};

    {
        if !((toLowerANSI _x) in _carried) then {
            [_x] call FUNC(freeInstance);
        };
    } forEach _heldBefore;
};

// The player converts right away. So does an AI whose loadout brought kits with contents of their
// own - a Zeus pasting a medic's loadout onto it - or those contents would run out with the restore
// queue. Kits that only hold the defaults stay prototypes until somebody reaches for them
// (fnc_requestUnitKits), which gives them exactly the same: every AI of a mission holding an id
// from the start would empty the pool for nothing.
// ACE_player is read defensively: the ACE Arsenal also sets loadouts in 3DEN, where it is not
// guaranteed to exist.
private _isPlayer = hasInterface && {_unit isEqualTo player || {_unit isEqualTo (missionNamespace getVariable ["ACE_player", objNull])}};
private _hasOwnContents = (values _queue) findIf {(_x findIf {_x isEqualType []}) > -1} > -1;

if (_isPlayer || {_hasOwnContents && {!([_unit] call ACEFUNC(common,isPlayer))}}) then {
    // Next frame, so the rest of CBA_fnc_setLoadout and its caller (ACE Arsenal trimming an
    // overfilled container) are done with the inventory first.
    [FUNC(convertKits), [_unit]] call CBA_fnc_execNextFrame;
};
