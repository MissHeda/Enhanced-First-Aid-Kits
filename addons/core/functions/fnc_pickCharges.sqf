#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Which magazines leave a kit when some of a class are taken out: the opened ones first, the
 * emptiest of them first, then full ones - or only full ones, or only opened ones of one fill, for
 * a row that stands for just those (the kit window, the contents window and the ACE menu list an
 * opened magazine apart from the full stack).
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Item class <STRING>
 * 2: How many <NUMBER>
 * 3: Which: -1 opened first, then full - 0 full ones only - more than 0 only opened ones with that
 *    many rounds <NUMBER> (default: -1)
 *
 * Return Value:
 * The rounds of each magazine that leaves, in that order, no more than the kit holds - [] for a
 * class without rounds to keep track of (items, magazines of one round) <ARRAY of NUMBER>
 *
 * Example:
 * ["efak_IFAK_7", "ACE_painkillers", 2] call efak_core_fnc_pickCharges;
 *
 * Public: Yes
 */

params ["_kitClass", "_itemClass", "_count", ["_which", -1]];

private _size = [_itemClass] call FUNC(getMagazineSize);

if (_size <= 1 || {_count <= 0}) exitWith {[]};

private _opened = [_kitClass, _itemClass] call FUNC(getCharges);

private _rounds = switch (true) do {
    case (_which > 0): {_opened select {_x == _which}};
    case (_which == 0): {[]};
    default {+_opened};
};

_rounds resize ((count _rounds) min _count);

// The full ones after the opened ones, as many as the kit has.
if (_which <= 0) then {
    private _contents = [_kitClass] call FUNC(getContents);
    private _index = _contents findIf {(_x select 0) == _itemClass};
    private _full = if (_index < 0) then {0} else {((_contents select _index) select 1) - count _opened};

    while {count _rounds < _count && {_full > 0}} do {
        _rounds pushBack _size;
        _full = _full - 1;
    };
};

_rounds
