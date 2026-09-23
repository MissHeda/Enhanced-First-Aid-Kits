#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Swaps one item of a unit for another, keeping it in the same container.
 * Used to turn a kit prototype into a concrete instance.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Class to remove, any case <STRING>
 * 2: Class to add <STRING>
 * 3: Loadout slot to look in first: 3 uniform, 4 vest, 5 backpack, -1 any <NUMBER> (default: -1)
 *
 * Return Value:
 * Replacement succeeded <BOOL>
 *
 * Example:
 * [player, "efak_IFAK", "efak_IFAK_7", 4] call efak_core_fnc_replaceItem;
 *
 * Public: No
 */

params ["_unit", "_oldClass", "_newClass", ["_slot", -1]];

if (isNull _unit || {!local _unit}) exitWith {false};

private _key = toLowerANSI _oldClass;

// The container the request was made for comes first. The kit may have been moved since, and one
// prototype of a type is as good as another, so the other containers are still worth a look.
private _containers = [
    [LOADOUT_SLOT_UNIFORM, "uniform", uniformContainer _unit],
    [LOADOUT_SLOT_VEST, "vest", vestContainer _unit],
    [LOADOUT_SLOT_BACKPACK, "backpack", backpackContainer _unit]
];

private _preferred = _containers findIf {(_x select 0) == _slot};

if (_preferred > 0) then {
    _containers = [_containers deleteAt _preferred] + _containers;
};

private _container = objNull;
private _found = "";

{
    _x params ["", "_name", "_object"];

    if (isNull _object) then {continue};

    // Callers pass lowercase keys, and "in" on an array of strings is case sensitive, so the match
    // is done by hand and the class is removed under the name the engine uses.
    private _cargo = itemCargo _object;
    private _index = _cargo findIf {(toLowerANSI _x) isEqualTo _key};

    if (_index > -1) exitWith {
        _container = [_name, _object];
        _found = _cargo select _index;
    };
} forEach _containers;

// Nothing to replace: the kit was dropped, traded or removed while the instance was on its way.
// Adding the instance anyway would hand out a kit for free.
if (_found isEqualTo "") exitWith {
    false
};

_container params ["_name", "_object"];

switch (_name) do {
    case "uniform": {_unit removeItemFromUniform _found};
    case "vest": {_unit removeItemFromVest _found};
    default {_unit removeItemFromBackpack _found};
};

// Straight into the container the prototype came out of, whatever its load says. The instance
// weighs exactly what the prototype did, and a container a loadout overfilled (setUnitLoadout never
// checks) would otherwise have the kit dropped on the ground - with its id handed back to the pool
// by the caller, which thinks the kit is gone.
_object addItemCargoGlobal [_newClass, 1];

true
