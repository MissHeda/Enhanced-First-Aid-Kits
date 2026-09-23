#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Server only. Fills a freshly allocated kit instance with contents that came
 * from outside the running mission: a saved, shared, imported or copied loadout.
 * That data may be old, from another modpack or edited by hand, so it has to
 * pass the same rules as packing by hand before it goes in:
 *
 * - classes that do not exist are dropped (normalizeContents),
 * - an instance id is never taken over, a kit packed inside gets a fresh one,
 * - items the kit's blacklist or item filter rejects are dropped entirely,
 * - a packed kit with nesting off, and everything in a kit that is packed only
 *   up to its defaults, may stay up to the amount the defaults hold,
 * - entries are trimmed from the end until the kit is within its capacity, or
 *   within its default fill if that is heavier.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents tree <ARRAY> (see fnc_getContentsTree)
 * 2: Nesting depth, internal <NUMBER> (default: 0)
 * 3: Packed kits that may still get an instance, internal <ARRAY> (default: [EFAK_RESTORE_MAX_NESTED])
 *
 * Return Value:
 * Contents that were stored <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7", [["ACE_morphine", 2]]] call efak_core_fnc_restoreContents;
 *
 * Public: No
 */

params ["_instance", ["_tree", [], [[]]], ["_depth", 0], ["_budget", [EFAK_RESTORE_MAX_NESTED]]];

if !(isServer || {is3DEN}) exitWith {
    WARNING_1("restoreContents called on a client for '%1'.",_instance);
    []
};

private _prototype = [_instance] call FUNC(getPrototype);

if (_prototype isEqualTo "") exitWith {[]};

private _defaults = [_prototype] call FUNC(getDefaultContents);
private _allowance = createHashMap;

{
    _x params ["_class", "_count"];
    private _key = toLowerANSI _class;
    _allowance set [_key, (_allowance getOrDefault [_key, 0]) + _count];
} forEach _defaults;

// ---------------------------------------------------------------------------
// What may go in at all
// ---------------------------------------------------------------------------

private _kept = [];

{
    if !(_x isEqualType [] && {_x isEqualTypeParams ["", 0]}) then {continue};

    _x params ["_class", "_count"];

    private _subTree = _x param [2, -1];
    // The rounds of opened magazines, see fnc_getContentsTree. Checked by fnc_reconcileCharges.
    private _rounds = _x param [3, []];

    if !(_rounds isEqualType []) then {_rounds = []};
    _rounds = (_rounds select [0, EFAK_RESTORE_MAX_COUNT]) select {_x isEqualType 0};

    _count = floor (_count min EFAK_RESTORE_MAX_COUNT);
    if (_count <= 0) then {continue};

    private _config = _class call CBA_fnc_getItemConfig;
    if (isNull _config) then {
        continue;
    };

    _class = configName _config;

    private _key = toLowerANSI _class;
    private _kitPrototype = GVAR(prototypeOf) getOrDefault [_key, ""];

    // An id from outside may belong to a kit somebody is carrying right now. Taking it over would
    // make both kits share one set of contents, so a packed kit always goes back to its prototype.
    if (_kitPrototype isNotEqualTo "" && {!(_key in GVAR(needsConversion))}) then {
        _class = _kitPrototype;
        _key = toLowerANSI _class;
    };

    // Blacklist and item filter hold for loadouts too, the default amount included - the
    // defaults themselves have already lost whatever breaks them.
    if !(([_instance, _class] call FUNC(isItemAllowed)) select 0) then {
        continue;
    };

    // A packed kit with nesting off, or any item in a kit that is packed only up to its defaults,
    // may stay up to the amount the defaults hold.
    if (
        ([_class] call FUNC(isKit)) && {!GVAR(allowNesting)} ||
        {[_instance, "limitToDefaults", false] call FUNC(getKitSetting)}
    ) then {
        private _left = _allowance getOrDefault [_key, 0];
        _count = _count min _left;
        _allowance set [_key, _left - _count];
    };

    if (_count <= 0) then {
        continue;
    };

    // Only a packed kit keeps a tree of its own.
    if !(_kitPrototype isNotEqualTo "" && {_subTree isEqualType []}) then {
        _subTree = -1;
    };

    _kept pushBack [_class, _count, _subTree, _rounds];
} forEach (_tree select [0, EFAK_RESTORE_MAX_ENTRIES]);

// ---------------------------------------------------------------------------
// Capacity
// ---------------------------------------------------------------------------

// A fresh kit comes with its default fill even when the capacity setting is lower than that,
// so a restored kit may weigh as much as well.
private _limit = ([_instance] call FUNC(getCapacity)) max ([_defaults] call FUNC(getUsedCapacity));
private _used = [_kept] call FUNC(getUsedCapacity);

for "_i" from (count _kept - 1) to 0 step -1 do {
    if (_used <= _limit + 0.001) exitWith {};

    private _entry = _kept select _i;
    private _mass = [_entry select 0] call FUNC(getItemMass);

    if (_mass > 0) then {
        private _remove = (ceil ((_used - _limit) / _mass)) min (_entry select 1);
        _entry set [1, (_entry select 1) - _remove];
        _used = _used - _remove * _mass;
    };
};

// ---------------------------------------------------------------------------
// Packed kits and storing
// ---------------------------------------------------------------------------

private _contents = [];
private _charges = [];

{
    _x params ["_class", "_count", "_subTree", "_rounds"];

    {
        _charges pushBack [_class, _x];
    } forEach _rounds;

    if (_count <= 0) then {continue};

    if (_subTree isEqualType [] && {_depth < EFAK_RESTORE_MAX_DEPTH}) then {
        for "_i" from 1 to _count do {
            // Out of budget or out of ids: the rest stay prototypes and get the defaults once
            // they are taken out, which is still better than losing them.
            private _nested = "";

            if ((_budget select 0) > 0) then {
                _nested = [_class] call FUNC(allocateInstance);
            };

            if (_nested isEqualTo "") exitWith {
                _contents pushBack [_class, _count - _i + 1];
            };

            _budget set [0, (_budget select 0) - 1];
            // A packed kit of a type whose contents are forced comes complete like any other.
            if ([_nested] call FUNC(isContentsForced)) then {
                [_nested, -1] call FUNC(fillNewInstance);
            } else {
                [_nested, _subTree, _depth + 1, _budget] call FUNC(restoreContents);
            };
            _contents pushBack [_nested, 1];
        };
    } else {
        _contents pushBack [_class, _count];
    };
} forEach _kept;

[_instance, _contents, _charges] call FUNC(setContents)
