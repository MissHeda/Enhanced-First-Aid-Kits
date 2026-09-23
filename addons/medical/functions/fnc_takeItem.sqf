#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Takes one of an item from a unit for a treatment: a loose one if there is one, otherwise straight
 * out of a kit - the kit's contents go down by one, nothing passes through the inventory.
 *
 * For other mods: use this where you would call removeItem on a medic's or patient's supplies, and
 * count with efak_medical_fnc_countItem. The loose one is taken first, so nothing changes for
 * anybody who carries their supplies loose.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class <STRING>
 *
 * Return Value:
 * One was taken <BOOL>
 *
 * Example:
 * [player, "ACM_IV_16g"] call efak_medical_fnc_takeItem;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_itemClass", "", [""]]];

if (isNull _unit || {_itemClass isEqualTo ""}) exitWith {false};

private _isMagazine = isClass (configFile >> "CfgMagazines" >> _itemClass);

private _loose = if (_isMagazine) then {
    (magazines _unit) findIf {_x == _itemClass} > -1
} else {
    (items _unit) findIf {_x == _itemClass} > -1
};

if (_loose) exitWith {
    if (_isMagazine) then {
        _unit removeMagazine _itemClass;
    } else {
        _unit removeItem _itemClass;
    };

    true
};

([_unit, [_itemClass]] call FUNC(findInKits)) params ["_kitClass", "_found"];

if (_kitClass isEqualTo "") exitWith {false};

[_unit, _kitClass, _found, 1] call FUNC(takeFromKit)
