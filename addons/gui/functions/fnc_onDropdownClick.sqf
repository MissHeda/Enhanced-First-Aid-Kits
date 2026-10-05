#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * One of the kit window's three drop downs was clicked - the kit switcher, the sort, or where items
 * taken out go first: opens its menu (fnc_openMenu) with what there is to choose from. Which one it is
 * comes from the hit area's class name, <Name>_Hit.
 *
 * Arguments:
 * 0: The field's hit area <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl] call efak_gui_fnc_onDropdownClick;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl"];

private _display = ctrlParent _ctrl;
private _name = ctrlClassName _ctrl;
private _base = _name select [0, _name find "_"];

switch (_base) do {
    // Every kit in reach, as fnc_fillKitSwitch listed them, in a menu as wide as the field. The list
    // goes along with the menu, so a pick finds its kit even when the switcher was filled again in
    // between.
    case "KitSwitch": {
        private _kits = +GVAR(kitChoices);
        private _current = _kits findIf {(toLowerANSI (_x select 1)) isEqualTo (toLowerANSI GVAR(kitClass))};

        [
            _display,
            _base,
            _kits apply {[_x select 3, _x select 4, false, _x select 5, _x select 6]},
            _current,
            FUNC(onKitSwitchChanged),
            _kits,
            KIT_SWITCH_W, // as wide as the whole field - its click area stops at the pencil
            RENAME_X + RENAME_W / 2 // where each kit is, in a column under the pencil
        ] call FUNC(openMenu);
    };

    case "Sort": {
        [
            _display,
            _base,
            [LLSTRING(Sort_Name), LLSTRING(Sort_Mass), LLSTRING(Sort_Amount)] apply {[_x, ""]},
            GVAR(sortMode),
            FUNC(onSortChanged)
        ] call FUNC(openMenu);
    };

    // The pictures are of what the player wears, so the menu says which uniform, vest and backpack
    // that is. Automatic has an icon of its own.
    case "TakeInto": {
        // Nothing worn there: the game's own picture of the empty slot.
        private _fnc_worn = {
            params ["_class", "_cfg", "_slot"];

            [getText (configFile >> _cfg >> _class >> "picture"), format ["\A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_%1_gs.paa", _slot]] select (_class isEqualTo "")
        };

        [
            _display,
            _base,
            [
                [LELSTRING(core,Container_Auto), UI_TEX(icon_auto_ca), true],
                [LELSTRING(core,Container_Uniform), [uniform ACE_player, "CfgWeapons", "uniform"] call _fnc_worn, uniform ACE_player isEqualTo ""],
                [LELSTRING(core,Container_Vest), [vest ACE_player, "CfgWeapons", "vest"] call _fnc_worn, vest ACE_player isEqualTo ""],
                [LELSTRING(core,Container_Backpack), [backpack ACE_player, "CfgVehicles", "backpack"] call _fnc_worn, backpack ACE_player isEqualTo ""]
            ],
            [GVAR(kitClass)] call EFUNC(core,getTakeInto),
            FUNC(onTakeIntoChanged),
            GVAR(kitClass),
            SQUARE(ROW * 6.2)
        ] call FUNC(openMenu);
    };
};
