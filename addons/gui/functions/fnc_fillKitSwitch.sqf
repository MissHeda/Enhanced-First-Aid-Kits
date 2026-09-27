#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows the kit on the switcher at the top of the kit window - its picture and name - and lists every
 * kit in reach for its menu (fnc_onDropdownClick).
 *
 * Names read like the kits tab of the ACE Arsenal: "IFAK #2 - Vest", with the kit's short name. Kits
 * of one type are numbered in list order, so two IFAKs read as #1 and #2. Filled again on every
 * refresh, so a kit that moved or disappeared is shown as it is now.
 *
 * Arguments:
 * 0: Kit window <DISPLAY>
 * 1: Kits <ARRAY> (see fnc_getReachableKits)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, call efak_gui_fnc_getReachableKits] call efak_gui_fnc_fillKitSwitch;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_kits"];

private _current = toLowerANSI GVAR(kitClass);
private _numbers = createHashMap;
private _shown = [];

// Row by row, so a pick can be traced back to who holds the kit: [holder, kit, where, name, picture].
GVAR(kitChoices) = _kits apply {
    _x params ["_holder", "_kitClass", "_where"];

    private _prototype = [_kitClass] call EFUNC(core,getPrototype);
    private _typeKey = toLowerANSI _prototype;
    private _number = (_numbers getOrDefault [_typeKey, 0]) + 1;

    _numbers set [_typeKey, _number];

    private _choice = [
        _holder,
        _kitClass,
        _where,
        format ["%1 #%2 - %3", [_kitClass] call EFUNC(core,getKitShortName), _number, _where],
        [_prototype] call EFUNC(core,getItemPicture)
    ];

    if ((toLowerANSI _kitClass) isEqualTo _current) then {_shown = _choice};

    _choice
};

_shown params ["", ["_kitClass", ""], "", ["_name", ""], ["_picture", ""]];

private _label = _display displayCtrl IDC_KIT_SWITCH;

_label ctrlSetText _name;
(_display displayCtrl IDC_KIT_SWITCH_PICTURE) ctrlSetText _picture;

// The full name in the tooltip - but not while the menu is open, where it would pop up over it; the
// menu puts it back when it closes (fnc_closeMenu).
private _hit = ((_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault ["KitSwitch", []]) param [4, controlNull];
private _tooltip = format ["%1\n\n%2", [_kitClass] call EFUNC(core,getKitName), LLSTRING(KitSwitch_Tooltip)];
private _menu = _display getVariable [QGVAR(menu), []];

if ((_menu param [0, ""]) isEqualTo "KitSwitch") then {
    _menu set [4, _tooltip];
} else {
    _hit ctrlSetTooltip _tooltip;
};
