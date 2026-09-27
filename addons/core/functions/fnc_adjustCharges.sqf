#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The opened magazines of a kit after some of a class went in or came out. Only works on the list
 * given - write it with fnc_setContents together with the contents.
 *
 * Arguments:
 * 0: Opened magazines, as fnc_getCharges returns them without a class <ARRAY>
 * 1: Item class <STRING>
 * 2: Rounds of each magazine that went in <ARRAY of NUMBER>
 * 3: Rounds of each magazine that came out <ARRAY of NUMBER>
 *
 * Return Value:
 * Opened magazines <ARRAY>
 *
 * Example:
 * [["efak_IFAK_7"] call efak_core_fnc_getCharges, "ACE_painkillers", [7], []] call efak_core_fnc_adjustCharges;
 *
 * Public: No
 */

params ["_charges", "_itemClass", ["_in", []], ["_out", []]];

private _size = [_itemClass] call FUNC(getMagazineSize);

if (_size <= 1) exitWith {_charges};

private _result = +_charges;

// Full ones are not listed, so only an opened one that leaves takes an entry with it.
{
    private _rounds = _x;

    if (_rounds >= _size) then {continue};

    private _index = _result findIf {(_x select 0) == _itemClass && {(_x select 1) == _rounds}};

    if (_index >= 0) then {
        _result deleteAt _index;
    };
} forEach _out;

{
    if (_x >= 1 && {_x < _size}) then {
        _result pushBack [_itemClass, floor _x];
    };
} forEach _in;

_result
