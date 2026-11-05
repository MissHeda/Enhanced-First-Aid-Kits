#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Lays one of every item the unit's kits hold into its inventory while the ACE interaction menu
 * is open - only kits of a type with "Use items without unpacking" on. Every ACE action that asks
 * for an item in the inventory then sees it, whichever mod it comes from: earplugs, cable ties,
 * spray paint, a wire cutter. Nothing needs to know about the kits, so a new feature of ACE or of
 * another mod works out of the box. fnc_restoreStaged puts back what is left once the menu has
 * closed and charges the kit for what an action used.
 *
 * One of each is enough for an action, and the next time the menu opens the next one comes out.
 * Left alone: magazines (they have rounds), worn things, kits, items the unit already carries
 * loose, and items that find no room in uniform, vest or backpack.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [ACE_player] call efak_core_fnc_stageItems;
 *
 * Public: No
 */

params ["_unit"];

// A new opening cancels a restore that is still waiting - what is out stays out.
GVAR(stagedGeneration) = GVAR(stagedGeneration) + 1;

if (GVAR(staged) isNotEqualTo [] || {!alive _unit} || {!local _unit}) exitWith {};

private _worn = ["uniform", "vest", "headgear", "glasses", "goggles", "nvgoggles", "binocular"];
private _loose = (items _unit) apply {toLowerANSI _x};
private _staged = [];
private _done = [];

{
    private _kitClass = _x;

    if !([_kitClass, "directUse", false] call FUNC(getKitSetting)) then {continue};

    {
        _x params ["_itemClass", "_count"];

        private _key = toLowerANSI _itemClass;

        if (_count < 1 || {_key in _done} || {_key in _loose}) then {continue};
        if !(isClass (configFile >> "CfgWeapons" >> _itemClass)) then {continue};
        if ([_itemClass] call FUNC(isKit)) then {continue};

        ([_itemClass] call ACEFUNC(common,getItemType)) params ["_type", "_subtype"];

        if (_type != "item" || {_subtype in _worn}) then {continue};

        _done pushBack _key;

        if !(_unit canAdd _itemClass) then {continue};

        _unit addItem _itemClass;
        _staged pushBack [_kitClass, _itemClass];
    } forEach ([_kitClass] call FUNC(getContents));
} forEach ([_unit] call FUNC(getCarriedKits));

if (_staged isEqualTo []) exitWith {};

GVAR(staged) = _staged;
GVAR(stagedUnit) = _unit;

// ACE keeps the player's items in a cache that is only cleared a frame later - the actions should
// see the new ones straight away.
ace_common_uniqueItemsCache = nil;
