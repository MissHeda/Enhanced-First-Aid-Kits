#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many of an item a contents list holds. Packed kits count by type, so asking for
 * "efak_IFAK" finds efak_IFAK_7 as well.
 *
 * Arguments:
 * 0: Contents <ARRAY> of [class, count]
 * 1: Item class <STRING>
 *
 * Return Value:
 * Count <NUMBER>
 *
 * Example:
 * [[["ACE_morphine", 2]], "ACE_morphine"] call efak_core_fnc_countItem;
 *
 * Public: Yes
 */

params ["_contents", "_itemClass"];

private _fnc_key = {
    private _key = toLowerANSI _this;
    private _prototype = GVAR(prototypeOf) getOrDefault [_key, ""];
    [toLowerANSI _prototype, _key] select (_prototype isEqualTo "")
};

private _key = _itemClass call _fnc_key;
private _count = 0;

{
    _x params ["_class", "_amount"];

    if ((_class call _fnc_key) isEqualTo _key) then {
        _count = _count + _amount;
    };
} forEach _contents;

_count
