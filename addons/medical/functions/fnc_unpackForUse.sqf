#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Makes sure a unit has an item loose in its inventory before another mod's own function uses it
 * from there: when there is none loose, one comes out of the unit's kits. For mods that take or
 * draw an item themselves (removeItem, magazine rounds) - unpack, then let the mod do its thing,
 * unchanged, rather than keeping a copy of its function in step.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class, or several in order of preference <STRING or ARRAY>
 *
 * Return Value:
 * The item class the unit now has loose, "" when it has none anywhere <STRING>
 *
 * Example:
 * [player, "ACM_OxygenTank_425"] call efak_medical_fnc_unpackForUse;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_items", "", ["", []]]];

if (_items isEqualType "") then {_items = [_items]};

if (isNull _unit || {_items isEqualTo []}) exitWith {""};

private _loose = _items findIf {([_unit, _x] call FUNC(countLoose)) > 0};

if (_loose > -1) exitWith {_items select _loose};

([_unit, _items] call FUNC(findInKits)) params ["_kitClass", "_itemClass"];

if (_kitClass isEqualTo "") exitWith {""};

if (([_unit, _kitClass, _itemClass, 1] call EFUNC(core,unpackItem)) < 1) exitWith {""};

_itemClass
