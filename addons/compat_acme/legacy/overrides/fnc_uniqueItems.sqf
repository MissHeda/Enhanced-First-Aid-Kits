#include "..\..\script_component.hpp"
/*
 * Author: commy2, Dedmen, Miss Heda
 * ACE's own function, and for the player the classes packed in their EFAK kits are listed as well -
 * ACM looks for the BVM through this when CPR starts, and for syringes and bags in its menus.
 * Nothing is moved: what is taken afterwards goes through efak_medical_fnc_takeItem (see acme\).
 *
 * Only for the player: AI medics of ACM take with removeItem in code this addon leaves alone.
 *
 * Returns list of unique items in a unit's inventory.
 * Items are cached if unit is ACE_player.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Include magazines <NUMBER>
 *  0: No
 *  1: Yes
 *  2: Only magazines
 *
 * Return Value:
 * Items <ARRAY>
 *
 * Example:
 * [player, 2] call ace_common_fnc_uniqueItems
 *
 * Public: Yes
 */

params ["_target", ["_includeMagazines", 0]];

private _fnc_getItems = {
    private _items = [];

    private _inventoryItems = (getItemCargo uniformContainer _target) select 0;
    _inventoryItems append ((getItemCargo vestContainer _target) select 0);
    _inventoryItems append ((getItemCargo backpackContainer _target) select 0);

    private _magazines = magazines _target;

    _items set [0, _inventoryItems arrayIntersect _inventoryItems];
    _items set [1, _magazines arrayIntersect _magazines];

    _items
};

private _result = if (_target isEqualTo ACE_player) then {
    // Cache items list if unit is ACE_player
    if (isNil "ace_common_uniqueItemsCache") then {
        ace_common_uniqueItemsCache = call _fnc_getItems;
    };

    switch (_includeMagazines) do {
        case 0: {
            ace_common_uniqueItemsCache select 0
        };
        case 1: {
            (ace_common_uniqueItemsCache select 1) + (ace_common_uniqueItemsCache select 0)
        };
        case 2: {
            ace_common_uniqueItemsCache select 1
        };
    };
} else {
    if (_target isKindOf "CAManBase") then {
        private _items = call _fnc_getItems;

        switch (_includeMagazines) do {
            case 0: {
                _items select 0
            };
            case 1: {
                (_items select 1) + (_items select 0)
            };
            case 2: {
                _items select 1
            };
        };
    } else {
        private _items = switch (_includeMagazines) do {
            case 0: {
                itemCargo _target
            };
            case 1: {
                (magazineCargo _target) + (itemCargo _target)
            };
            case 2: {
                magazineCargo _target
            };
        };

        _items arrayIntersect _items
    };
};

// ----- EFAK -----
if (!hasInterface || {_target isNotEqualTo ACE_player}) exitWith {_result};

// This is asked hundreds of times a frame - by the interaction menu's conditions, by ACM's treatment
// checks - so the answer is kept for the frame, per mode, until a kit's contents change. Like ACE's
// own list for the player, it is shared: callers must not change it.
private _cache = missionNamespace getVariable "efak_compat_acme_uniqueItemsCache";

if (isNil "_cache") then {
    _cache = createHashMap;
    missionNamespace setVariable ["efak_compat_acme_uniqueItemsCache", _cache];
};

(_cache getOrDefault [_includeMagazines, []]) params [["_frame", -1], ["_stamp", -1], ["_aceCache", []], ["_merged", []]];

// ACE rebuilds its own list for the player whenever their inventory changes, so a different list
// there means the loose part is different too.
if (
    _frame isEqualTo diag_frameNo &&
    {_stamp isEqualTo efak_core_contentsStamp} &&
    {_aceCache isEqualRef ace_common_uniqueItemsCache}
) exitWith {
    _merged
};

// What the kits hold, as the classes are spelled in config - "in" is case sensitive.
private _kitClasses = [];

{
    if !([_x] call efak_medical_fnc_canUseKit) then {continue};

    {
        _x params ["_class"];

        if ([_class] call efak_core_fnc_isKit) then {continue};

        private _isMagazine = isClass (configFile >> "CfgMagazines" >> _class);

        if (_isMagazine && {_includeMagazines == 0}) then {continue};
        if (!_isMagazine && {_includeMagazines == 2}) then {continue};

        _kitClasses pushBackUnique _class;
    } forEach (efak_core_contents getOrDefault [toLowerANSI _x, []]);
} forEach ([_target] call efak_core_fnc_getCarriedKits);

// A copy: the list above may be ACE's own cache.
private _merged = +_result;

{
    _merged pushBackUnique _x;
} forEach _kitClasses;

_cache set [_includeMagazines, [diag_frameNo, efak_core_contentsStamp, ace_common_uniqueItemsCache, _merged]];

_merged
