#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Checks whether an item may go into a kit.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Item class <STRING>
 * 2: Amount <NUMBER> (default: 1)
 *
 * Return Value:
 * 0: Allowed <BOOL>
 * 1: Reason when not allowed, "" otherwise <STRING>
 *
 * Example:
 * ["efak_IFAK_7", "ACE_morphine", 1] call efak_core_fnc_canPackItem;
 *
 * Public: Yes
 */

params ["_kitClass", "_itemClass", ["_count", 1]];

if !(GVAR(enablePacking)) exitWith {[false, LLSTRING(Error_PackingDisabled)]};

if (([_kitClass] call FUNC(getKitData)) isEqualTo []) exitWith {[false, ""]};

// A kit inside a kit would let you fold an arbitrary amount of gear into one
// item, so it stays off unless the mission explicitly wants it.
if (([_itemClass] call FUNC(isKit)) && {!GVAR(allowNesting)}) exitWith {
    [false, LLSTRING(Error_NoNesting)]
};

private _config = _itemClass call CBA_fnc_getItemConfig;
if (isNull _config) exitWith {[false, ""]};

// Weapons, backpacks and uniforms are not something you fold into a pouch.
if !(((_itemClass call ACEFUNC(common,getItemType)) select 0) in ["item", "magazine"]) exitWith {
    [false, LLSTRING(Error_ItemNotAllowed)]
};

private _key = toLowerANSI _itemClass;

if (_key in GVAR(blacklistLookup)) exitWith {[false, LLSTRING(Error_ItemNotAllowed)]};

if (GVAR(itemFilter) == FILTER_MEDICAL && {getNumber (_config >> "ACE_isMedicalItem") != 1}) exitWith {
    [false, LLSTRING(Error_MedicalOnly)]
};

if (GVAR(itemFilter) == FILTER_LIST && {!(_key in GVAR(whitelistLookup))}) exitWith {
    [false, LLSTRING(Error_ItemNotAllowed)]
};

private _free = ([_kitClass] call FUNC(getCapacity)) - ([_kitClass] call FUNC(getUsedCapacity));

if (([_itemClass] call FUNC(getItemMass)) * _count > _free) exitWith {
    [false, LLSTRING(Error_NotEnoughSpace)]
};

[true, ""]
