#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Fits a kit's opened magazines to its contents: never more opened ones of a class than the kit
 * holds, no rounds a magazine cannot have. Where the contents went down without saying which
 * magazine left - the arsenal, a loadout trimmed to capacity - the fullest opened ones go first, so
 * nothing comes back fuller than it went in.
 *
 * Arguments:
 * 0: Contents <ARRAY>
 * 1: Opened magazines, [[class, rounds], ...] <ARRAY>
 *
 * Return Value:
 * Opened magazines <ARRAY>
 *
 * Example:
 * [[["ACE_painkillers", 2]], [["ACE_painkillers", 7]]] call efak_core_fnc_reconcileCharges;
 *
 * Public: No
 */

params ["_contents", "_charges"];

// How many opened ones of each class the kit can hold: as many as it holds of the class.
private _room = createHashMap;

{
    _x params ["_class", "_count"];
    _room set [toLowerANSI _class, (_room getOrDefault [toLowerANSI _class, 0]) + _count];
} forEach _contents;

private _valid = [];

{
    if !(_x isEqualType []) then {continue};

    _x params [["_class", "", [""]], ["_rounds", 0, [0]]];

    private _size = [_class] call FUNC(getMagazineSize);

    if (_size > 1 && {_rounds >= 1} && {_rounds < _size}) then {
        _valid pushBack [floor _rounds, _class];
    };
} forEach _charges;

// The emptiest first: they are the ones kept when there is not room for all.
_valid sort true;

private _result = [];

{
    _x params ["_rounds", "_class"];

    private _key = toLowerANSI _class;
    private _left = _room getOrDefault [_key, 0];

    if (_left > 0) then {
        _room set [_key, _left - 1];
        _result pushBack [_class, _rounds];
    };
} forEach _valid;

_result
