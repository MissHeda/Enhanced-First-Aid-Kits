#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Moves items out of a unit's inventory into a kit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Item class <STRING>
 * 3: Amount <NUMBER> (default: 1)
 *
 * Return Value:
 * Amount actually packed <NUMBER>
 *
 * Example:
 * [player, "efak_IFAK_7", "ACE_morphine", 2] call efak_core_fnc_packItem;
 *
 * Public: Yes
 */

params ["_unit", "_kitClass", "_itemClass", ["_count", 1]];

private _available = [_unit, _itemClass] call ACEFUNC(common,getCountOfItem);
_count = (floor _count) min _available;

if (_count <= 0) exitWith {0};

// Only take as many as actually fit.
private _mass = [_itemClass] call FUNC(getItemMass);
private _free = ([_kitClass] call FUNC(getCapacity)) - ([_kitClass] call FUNC(getUsedCapacity));

if (_mass > 0) then {
    _count = _count min (floor (_free / _mass));
};

if (_count <= 0) exitWith {
    [LLSTRING(Error_NotEnoughSpace)] call ACEFUNC(common,displayTextStructured);
    0
};

([_kitClass, _itemClass, _count] call FUNC(canPackItem)) params ["_allowed", "_reason"];

if !(_allowed) exitWith {
    if (_reason isNotEqualTo "") then {
        [_reason] call ACEFUNC(common,displayTextStructured);
    };
    0
};

private _isMagazine = ((_itemClass call ACEFUNC(common,getItemType)) select 0) isEqualTo "magazine";

for "_i" from 1 to _count do {
    if (_isMagazine) then {
        _unit removeMagazine _itemClass;
    } else {
        _unit removeItem _itemClass;
    };
};

private _contents = [_kitClass] call FUNC(getContents);
_contents pushBack [_itemClass, _count];

[_kitClass, _contents] call FUNC(setContents);

TRACE_4("packed",_unit,_kitClass,_itemClass,_count);

_count
