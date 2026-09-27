#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Which magazines of a class leave a place of the kit window (see fnc_getEntries) when some of them
 * are moved: the emptiest first, so an opened pill bottle goes before a full one - or the fullest
 * first, where the kit takes back only what came out of it, so nobody swaps a nearly empty bottle
 * of their own for the full one the kit gave out. fnc_takeItems takes exactly these, fnc_putItems
 * puts them down as full as they were.
 *
 * Arguments:
 * 0: Place <STRING>
 * 1: Item class <STRING>
 * 2: How many <NUMBER>
 * 3: The fullest first <BOOL> (default: false)
 *
 * Return Value:
 * Rounds of each magazine, in order - [] for an item, or a magazine of a single round, which have
 * none to keep track of <ARRAY of NUMBER>
 *
 * Example:
 * ["inventory", "ACE_painkillers", 2] call efak_gui_fnc_pickRounds;
 *
 * Public: No
 */

params ["_key", "_class", "_count", ["_fullestFirst", false]];

if (([_class] call EFUNC(core,getMagazineSize)) <= 1 || {_count <= 0}) exitWith {[]};

if (_key isEqualTo "kit") exitWith {
    [GVAR(kitClass), _class, _count] call EFUNC(core,pickCharges)
};

private _objects = switch (_key) do {
    case "crate": {[GVAR(crate)]};
    case "ground": {[[false] call FUNC(getGroundHolder)]};
    case "inventory": {[uniformContainer ACE_player, vestContainer ACE_player, backpackContainer ACE_player]};
    case "uniform": {[uniformContainer ACE_player]};
    case "vest": {[vestContainer ACE_player]};
    default {[backpackContainer ACE_player]};
};

private _rounds = [];

{
    if (isNull _x) then {continue};

    {
        _x params ["_magazine", "_ammo"];

        if (_magazine == _class) then {
            _rounds pushBack _ammo;
        };
    } forEach (magazinesAmmoCargo _x);
} forEach _objects;

_rounds sort !_fullestFirst;
_rounds select [0, _count]
