#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many of an item a unit carries loose in uniform, vest and backpack - never what is inside a
 * kit. ACE's own ace_common_fnc_getCountOfItem, as it is without EFAK (see fnc_looseItems for why
 * EFAK needs its own).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class <STRING>
 *
 * Return Value:
 * Count <NUMBER>
 *
 * Example:
 * [player, "ACE_morphine"] call efak_medical_fnc_countLoose;
 *
 * Public: No
 */

params ["_unit", "_itemClass"];

private _count = 0;
private _isMagazine = isClass (configFile >> "CfgMagazines" >> _itemClass);

{
    (if (_isMagazine) then {
        getMagazineCargo _x
    } else {
        getItemCargo _x
    }) params ["_itemTypes", "_itemCounts"];

    _count = _count + (_itemCounts param [_itemTypes find _itemClass, 0]);
} forEach [uniformContainer _unit, vestContainer _unit, backpackContainer _unit];

_count
