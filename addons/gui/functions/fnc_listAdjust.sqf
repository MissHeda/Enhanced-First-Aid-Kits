#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Adds to or takes from one class in a [class, count] list, in place.
 *
 * An entry keeps its place while it has anything left in it and only disappears once it is empty,
 * so the contents of a kit keep their order through a move.
 *
 * Arguments:
 * 0: List <ARRAY> of [class, count]
 * 1: Item class <STRING>
 * 2: How many to add, negative to take away <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_contents, "ACE_morphine", -2] call efak_gui_fnc_listAdjust;
 *
 * Public: No
 */

params ["_list", "_class", ["_delta", 0]];

if (_delta isEqualTo 0) exitWith {};

private _key = toLowerANSI _class;
private _index = _list findIf {toLowerANSI (_x select 0) isEqualTo _key};

if (_index < 0) exitWith {
    if (_delta > 0) then {_list pushBack [_class, _delta]};
};

(_list select _index) params ["_stored", "_count"];

_count = _count + _delta;

if (_count <= 0) then {
    _list deleteAt _index;
} else {
    _list set [_index, [_stored, _count]];
};
