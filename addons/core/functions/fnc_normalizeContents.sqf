#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Cleans up a contents array: drops unknown classes and non positive counts,
 * merges duplicate entries and keeps the original order.
 *
 * Arguments:
 * 0: Contents <ARRAY> of [class, count]
 *
 * Return Value:
 * Cleaned contents <ARRAY>
 *
 * Example:
 * [[["ACE_morphine", 1], ["ACE_morphine", 2]]] call efak_core_fnc_normalizeContents;
 *
 * Public: Yes
 */

params [["_contents", [], [[]]]];

private _order = [];
private _counts = createHashMap;

{
    if !(_x isEqualType []) then {continue};

    _x params [["_class", "", [""]], ["_count", 0, [0]]];

    _count = floor _count;
    if (_class isEqualTo "" || {_count <= 0}) then {continue};
    if (isNull (_class call CBA_fnc_getItemConfig)) then {
        continue;
    };

    private _key = toLowerANSI _class;
    if !(_key in _counts) then {
        _order pushBack [_key, _class];
    };
    _counts set [_key, (_counts getOrDefault [_key, 0]) + _count];
} forEach _contents;

_order apply {[_x select 1, _counts get (_x select 0)]}
