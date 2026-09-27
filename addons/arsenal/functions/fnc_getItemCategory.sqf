#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Which of ACE's right-hand category buttons an item belongs under, the same sorting ACE applies to
 * a backpack: a custom button another mod registered for it first, then grenades, explosives,
 * other magazines, the four attachment slots, and everything else under misc items.
 *
 * "Compatible magazines" is not a category of its own - it depends on the unit's weapons - and is
 * checked separately by the caller.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * Button IDC <NUMBER>
 *
 * Example:
 * ["ACE_morphine"] call efak_arsenal_fnc_getItemCategory;
 *
 * Public: No
 */

params ["_class"];

private _key = toLowerANSI _class;
private _cached = GVAR(categoryCache) getOrDefault [_key, -1];

if (_cached != -1) exitWith {_cached};

private _category = ACE_BUTTON_MISC;
private _custom = missionNamespace getVariable [QACEGVAR(arsenal,customRightPanelButtons), []];
private _customIdcs = [ACE_CUSTOM_BUTTONS];

// Custom buttons win, exactly as in ACE, where misc items leaves out whatever a custom button owns.
private _customIndex = _custom findIf {
    !isNil "_x" && {(_x param [0, []]) findIf {(toLowerANSI _x) isEqualTo _key} > -1}
};

if (_customIndex > -1 && {_customIndex < count _customIdcs}) then {
    _category = _customIdcs select _customIndex;
} else {
    (_class call BIS_fnc_itemType) params [["_kind", ""], ["_type", ""]];

    _category = switch (true) do {
        case (_kind == "Mine"): {ACE_BUTTON_PUT};
        case (_kind == "Magazine" && {_type in ["Grenade", "SmokeShell", "Flare"]}): {ACE_BUTTON_THROW};
        case (_kind == "Magazine" && {_type in ["Mine", "MineBounding", "MineDirectional", "Explosive"]}): {ACE_BUTTON_PUT};
        case (_kind == "Magazine"): {ACE_BUTTON_MAGALL};
        case (_type == "AccessorySights"): {ACE_BUTTON_OPTIC};
        case (_type == "AccessoryPointer"): {ACE_BUTTON_ITEMACC};
        case (_type == "AccessoryMuzzle"): {ACE_BUTTON_MUZZLE};
        case (_type == "AccessoryBipod"): {ACE_BUTTON_BIPOD};
        default {ACE_BUTTON_MISC};
    };
};

GVAR(categoryCache) set [_key, _category];

_category
