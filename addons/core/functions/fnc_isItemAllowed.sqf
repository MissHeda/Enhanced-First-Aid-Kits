#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether a kit type takes this kind of item at all: worn gear and weapons never, then the kit's
 * blacklist and item filter. Nothing about room, amounts or nesting.
 *
 * These rules hold everywhere, not only for packing by hand: loadouts and the default contents
 * lose whatever breaks them (fnc_restoreContents, fnc_getDefaultContents).
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 * 1: Item class <STRING>
 *
 * Return Value:
 * 0: Allowed <BOOL>
 * 1: Reason when not allowed, "" otherwise <STRING>
 *
 * Example:
 * ["efak_IFAK", "ACE_morphine"] call efak_core_fnc_isItemAllowed;
 *
 * Public: Yes
 */

params ["_kitClass", "_itemClass"];

private _kit = [_kitClass] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {[false, ""]};

private _config = _itemClass call CBA_fnc_getItemConfig;

if (isNull _config) exitWith {[false, ""]};

// Only things that go into a pouch. Weapons and backpacks are out, and so is everything that is
// worn - uniforms, vests, helmets, glasses, night vision and binoculars are all "items" to the
// engine. Weapon attachments are small loose items and may go in.
(_itemClass call ACEFUNC(common,getItemType)) params ["_itemType", "_itemSubtype"];

// Backpacks are vehicles to the engine and nothing ACE sorts; called what they are here.
if (getNumber (configFile >> "CfgVehicles" >> _itemClass >> "isBackpack") == 1) then {
    _itemType = "backpack";
    _itemSubtype = "backpack";
};

// A container made for one kind of thing lists it (itemTypes). Worn things only go into one that
// names them outright - a CBRN bag carries the suit and the mask as "item/uniform", "item/glasses",
// and its breathing set as "backpack".
private _types = _kit param [KIT_TYPES, []];
private _fullType = toLowerANSI format ["%1/%2", _itemType, _itemSubtype];

if (
    (!(_itemType in ["item", "magazine"]) && {!(_itemType == "backpack" && {"backpack" in _types})}) ||
    {_itemSubtype in ["uniform", "vest", "headgear", "glasses", "goggles", "hmd", "binocular"] && {!(_fullType in _types)}}
) exitWith {
    [false, LLSTRING(Error_ItemNotAllowed)]
};

private _id = _kit select KIT_ID;
private _key = toLowerANSI _itemClass;

// What a compat addon rules out for every kit, see EFAK_Excluded.
if (_itemType == "magazine" && {GVAR(excludedPrefixes) findIf {(_key find _x) == 0} > -1}) exitWith {
    [false, LLSTRING(Error_ItemNotAllowed)]
};

if (_key in (GVAR(blacklistLookup) getOrDefault [_id, createHashMap])) exitWith {
    [false, LLSTRING(Error_Blacklisted)]
};

private _whitelist = GVAR(whitelistLookup) getOrDefault [_id, createHashMap];

// A container made for one kind of thing - an ammo pouch for magazines - takes only that kind,
// unless the mission's whitelist names the item. Types as ace_common_fnc_getItemType gives them:
// "magazine", or with the subtype, "magazine/secondary".
if (
    _types isNotEqualTo [] &&
    {!(_key in _whitelist)} &&
    {!((toLowerANSI _itemType) in _types)} &&
    {!(_fullType in _types)}
) exitWith {
    [false, LLSTRING(Error_TypeNotAllowed)]
};

private _filter = missionNamespace getVariable [format [QGVAR(kit_%1_itemFilter), _id], _kit param [KIT_FILTER, FILTER_MEDICAL]];

// Medical mode takes the whitelist as extra allowed items on top of everything medical, so a
// mission can let a chemlight or a pair of scissors in without opening the kit to everything.
if (
    _filter == FILTER_MEDICAL &&
    {!(_key in GVAR(medicalLookup))} &&
    {getNumber (_config >> "ACE_isMedicalItem") != 1} &&
    {!(_key in _whitelist)}
) exitWith {
    [false, LLSTRING(Error_MedicalOnly)]
};

if (_filter == FILTER_LIST && {!(_key in _whitelist)}) exitWith {
    [false, LLSTRING(Error_NotWhitelisted)]
};

private _isKindInWhitelist = {
    private _i = 0;
    {if ((_key isKindOf [_x, configFile >> "CfgWeapons"]) || (_key isKindOf [_x, configFile >> "CfgMagazines"])) exitWith {_i = 1}} forEach _whitelist;
    _i == 0;
};

if (_filter == FILTER_KIND && _isKindInWhitelist) exitWith {
        [false, LLSTRING(Error_NotKindOf)]
    };

[true, ""]
