#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Gives the kits a category of their own down ACE's right edge, or hands them back to the category
 * they would otherwise sit in.
 *
 * ACE files anything medical under the button ace_medical_treatment registers, so a kit ends up
 * between the bandages. With a category of its own it is taken out of that button - a kit is listed
 * once, under its own icon, and nowhere else.
 *
 * Without one there is no kit button in ACE's tabs at all: the kits go back among the medical items
 * and the tab puts up its own category button while it is open, see fnc_openTab.
 *
 * Runs at postInit, whenever the setting changes, and once the mission's settings have arrived.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_applyCategorySetting;
 *
 * Public: No
 */

if (!hasInterface || {GVAR(kitClasses) isEqualTo []}) exitWith {};

private _own = missionNamespace getVariable [QGVAR(ownCategory), true];

// Registering is what creates ACE's array in the first place, so the button comes before the rest.
if (_own) then {
    // Name and icon from EFAK_Arsenal, which a mod with containers of its own may change.
    private _name = getText (configFile >> "EFAK_Arsenal" >> "buttonName");
    if ((_name select [0, 1]) == "$") then {_name = localize (_name select [1])};

    private _slot = [
        GVAR(kitClasses),
        _name,
        getText (configFile >> "EFAK_Arsenal" >> "icon"),
        GVAR(kitsButtonSlot)
    ] call ACEFUNC(arsenal,addRightPanelButton);

    if (_slot < 0) exitWith {
        WARNING("ACE Arsenal had no free category button left - the kits stay with the medical items.");
    };

    GVAR(kitsButtonSlot) = _slot;
};

private _custom = missionNamespace getVariable [QACEGVAR(arsenal,customRightPanelButtons), []];

if (_own) then {
    {
        // An entry is nil where no mod has taken that slot.
        if (isNil "_x" || {_forEachIndex isEqualTo GVAR(kitsButtonSlot)}) then {continue};

        private _items = _x select 0;
        // Every kit class, instances included, whether or not this button lists it.
        private _kits = _items select {(toLowerANSI _x) in EGVAR(core,prototypeOf)};

        if (_kits isEqualTo []) then {continue};

        _x set [0, _items - _kits];
        GVAR(borrowedFrom) set [_forEachIndex, _kits];
    } forEach _custom;
} else {
    // Over a hashmap, _x is the slot it came from and _y the classes taken out of it.
    {
        private _entry = _custom param [_x];
        if (isNil "_entry") then {continue};

        _entry set [0, (_entry select 0) + _y];
    } forEach GVAR(borrowedFrom);

    GVAR(borrowedFrom) = createHashMap;

    // An arsenal that is open right now keeps the button it already drew until it is reopened; the
    // tab hides it either way, and it lists nothing.
    if (GVAR(kitsButtonSlot) >= 0) then {
        _custom set [GVAR(kitsButtonSlot), nil];
    };
};

// Which button an item belongs to has just changed for every kit class.
GVAR(categoryCache) = createHashMap;
