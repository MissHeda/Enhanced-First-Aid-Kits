#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Limits a contents tree to what an ACE Arsenal offers. An item the arsenal does
 * not offer may still stay up to the amount the kit comes with by default: the
 * same kit taken fresh out of that arsenal would hold exactly that, so a limited
 * arsenal that only offers the kits does not turn every saved kit into an empty
 * one. Everything else is cut and reported.
 *
 * Arguments:
 * 0: Kit prototype class <STRING>
 * 1: Contents tree <ARRAY> (see fnc_getContentsTree)
 * 2: Items the arsenal offers <HASHMAP> (ace_arsenal_virtualItemsFlat)
 * 3: Receives the classes that were cut, unique <ARRAY> (default: [])
 * 4: Nesting depth, internal <NUMBER> (default: 0)
 *
 * Return Value:
 * Filtered contents tree <ARRAY>
 *
 * Example:
 * ["efak_IFAK", [["ACE_morphine", 4]], ace_arsenal_virtualItemsFlat] call efak_core_fnc_filterContentsTree;
 *
 * Public: No
 */

params ["_prototype", "_tree", "_available", ["_removed", []], ["_depth", 0]];

if !(_tree isEqualType []) exitWith {[]};

private _allowance = createHashMap;

{
    _x params ["_class", "_count"];
    private _key = toLowerANSI _class;
    _allowance set [_key, (_allowance getOrDefault [_key, 0]) + _count];
} forEach ([_prototype] call FUNC(getDefaultContents));

private _result = [];

{
    if !(_x isEqualType [] && {_x isEqualTypeParams ["", 0]}) then {continue};

    _x params ["_class", "_count"];

    private _subTree = _x param [2, -1];
    private _config = _class call CBA_fnc_getItemConfig;

    // Unknown classes are the server's to drop; nothing the arsenal could say about them.
    if (isNull _config) then {continue};

    private _name = configName _config;
    private _kitPrototype = [_name] call FUNC(getPrototype);

    // A packed kit is offered when its prototype is. The instance ids themselves never are.
    private _offered = if (_kitPrototype isEqualTo "") then {_name in _available} else {_kitPrototype in _available};

    if !(_offered) then {
        private _key = toLowerANSI _name;
        private _left = _allowance getOrDefault [_key, 0];
        private _keep = (floor _count) min _left;

        _allowance set [_key, _left - _keep];

        if (_keep < _count) then {
            _removed pushBackUnique _name;
        };

        _count = _keep;
    };

    if (_count <= 0) then {continue};

    if (_kitPrototype isNotEqualTo "" && {_subTree isEqualType []} && {_depth < EFAK_RESTORE_MAX_DEPTH}) then {
        _result pushBack [_name, _count, [_kitPrototype, _subTree, _available, _removed, _depth + 1] call FUNC(filterContentsTree)];
    } else {
        private _rounds = _x param [3, []];

        if (_rounds isEqualType [] && {_rounds isNotEqualTo []}) then {
            _result pushBack [_name, _count, -1, _rounds];
        } else {
            _result pushBack [_name, _count];
        };
    };
} forEach _tree;

_result
