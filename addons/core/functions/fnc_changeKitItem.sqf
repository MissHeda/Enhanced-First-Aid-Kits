#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Adds items of one class to a kit's contents, or takes them out, without moving them anywhere -
 * for whatever puts them somewhere itself (fnc_wearItem).
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Item class <STRING>
 * 2: How many, negative to take out <NUMBER>
 *
 * Return Value:
 * Done - false when the kit holds fewer than asked to take out <BOOL>
 *
 * Example:
 * ["eup_CBRNBag_3", "G_AirPurifyingRespirator_01_F", -1] call efak_core_fnc_changeKitItem;
 *
 * Public: No
 */

params ["_kitClass", "_itemClass", "_delta"];

private _contents = +([_kitClass] call FUNC(getContents));
private _key = toLowerANSI _itemClass;
private _index = _contents findIf {(toLowerANSI (_x select 0)) isEqualTo _key};
private _have = 0;

if (_index > -1) then {_have = (_contents select _index) select 1};
private _new = _have + _delta;

if (_new < 0) exitWith {false};

switch (true) do {
    case (_index == -1): {_contents pushBack [_itemClass, _new]};
    case (_new == 0): {_contents deleteAt _index};
    default {_contents set [_index, [(_contents select _index) select 0, _new]]};
};

[_kitClass, _contents] call FUNC(setContents);

true
