#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The item and magazine classes a unit carries loose in uniform, vest and backpack - never what is
 * inside a kit. ACE's own ace_common_fnc_uniqueItems, as it is without EFAK.
 *
 * EFAK's own treatment functions need exactly that: they decide between a loose item and one from
 * a kit themselves, and take a loose one with removeItem. With an older ACM Extended loaded,
 * ace_common_fnc_uniqueItems lists the kits' contents as well (efak_compat_acme legacy), which
 * would make them try to take a packed item out of a pocket.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: 0 items, 1 items and magazines, 2 magazines <NUMBER> (default: 0)
 *
 * Return Value:
 * Classes <ARRAY> - do not modify
 *
 * Example:
 * [player, 1] call efak_medical_fnc_looseItems;
 *
 * Public: No
 */

params ["_unit", ["_mode", 0]];

// ACE keeps the player's loose items in a cache of its own, which EFAK never adds to.
private _lists = if (_unit isEqualTo ACE_player && {!isNil "ace_common_uniqueItemsCache"}) then {
    ace_common_uniqueItemsCache
} else {
    private _items = (getItemCargo uniformContainer _unit) select 0;
    _items append ((getItemCargo vestContainer _unit) select 0);
    _items append ((getItemCargo backpackContainer _unit) select 0);

    private _magazines = magazines _unit;

    [_items arrayIntersect _items, _magazines arrayIntersect _magazines]
};

switch (_mode) do {
    case 1: {(_lists select 1) + (_lists select 0)};
    case 2: {_lists select 1};
    default {_lists select 0};
}
