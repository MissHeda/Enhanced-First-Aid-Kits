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

private _isMagazine = isClass (configFile >> "CfgMagazines" >> _itemClass);
private _containers = [uniformContainer _unit, vestContainer _unit, backpackContainer _unit] select {!isNull _x};

// Counted here rather than with ACE's getCountOfItem, which with efak_compat_acme counts what is in the
// kits too. Every magazine with its rounds and where it is, the emptiest first: an opened bottle goes
// in before a full one, and keeps its rounds in the kit.
private _magazines = [];
private _available = 0;

{
    private _container = _x;

    if (_isMagazine) then {
        {
            _x params ["_magazine", "_rounds"];

            if (_magazine == _itemClass) then {
                _magazines pushBack [_rounds, _container];
            };
        } forEach (magazinesAmmoCargo _container);
    } else {
        (getItemCargo _container) params ["_classes", "_counts"];

        _available = _available + (_counts param [_classes find _itemClass, 0]);
    };
} forEach _containers;

if (_isMagazine) then {
    _magazines sort true;
    _available = count _magazines;
};

_count = (floor _count) min _available;

if (_count <= 0) exitWith {0};

if !([_kitClass] call FUNC(canPackInto)) exitWith {
    [LLSTRING(Error_PackingDisabled)] call ACEFUNC(common,displayTextStructured);
    0
};

// Whether this kind of item goes in at all, before counting how many.
([_kitClass, _itemClass, _count, true] call FUNC(canPackItem)) params ["_rulesAllow", "_rulesReason"];

if !(_rulesAllow) exitWith {
    if (_rulesReason isNotEqualTo "") then {
        [_rulesReason] call ACEFUNC(common,displayTextStructured);
    };
    0
};

// Packed only up to the default contents: no more than they hold.
private _limit = [_kitClass, _itemClass] call FUNC(getPackLimit);

if (_limit >= 0) then {
    _count = _count min (_limit - ([[_kitClass] call FUNC(getContents), _itemClass] call FUNC(countItem)));
};

if (_count <= 0) exitWith {
    [LLSTRING(Error_DefaultsReached)] call ACEFUNC(common,displayTextStructured);
    0
};

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

private _packed = [];

if (_isMagazine) then {
    {
        _x params ["_rounds", "_container"];

        _container addMagazineAmmoCargo [_itemClass, -1, _rounds];
        _packed pushBack _rounds;
    } forEach (_magazines select [0, _count]);
} else {
    for "_i" from 1 to _count do {
        _unit removeItem _itemClass;
    };
};

private _contents = [_kitClass] call FUNC(getContents);
_contents pushBack [_itemClass, _count];

[_kitClass, _contents, [[_kitClass] call FUNC(getCharges), _itemClass, _packed] call FUNC(adjustCharges)] call FUNC(setContents);

_count
