#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills the kit switcher at the top of the kit window and selects the kit being shown.
 *
 * Rows read like the kits tab of the ACE Arsenal: "IFAK #2 - Vest". Kits of one type are numbered
 * in list order, so two IFAKs read as #1 and #2. Filled again on every refresh, so a kit that moved
 * or disappeared is shown as it is now.
 *
 * Selecting a row from script raises the same change event a click does, so a flag keeps the change
 * handler from switching kits halfway through filling the box.
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

private _ctrl = _display displayCtrl IDC_KIT_SWITCH;
private _current = toLowerANSI GVAR(kitClass);
private _numbers = createHashMap;
private _selected = -1;

GVAR(fillingKitSwitch) = true;

lbClear _ctrl;

{
    _x params ["", "_kitClass", "_where"];

    private _prototype = [_kitClass] call EFUNC(core,getPrototype);
    private _typeKey = toLowerANSI _prototype;
    private _number = (_numbers getOrDefault [_typeKey, 0]) + 1;

    _numbers set [_typeKey, _number];

    private _index = _ctrl lbAdd format ["%1 #%2 - %3", [_kitClass] call EFUNC(core,getKitName), _number, _where];

    _ctrl lbSetData [_index, _kitClass];
    _ctrl lbSetPicture [_index, [_prototype] call EFUNC(core,getItemPicture)];

    if ((toLowerANSI _kitClass) isEqualTo _current) then {_selected = _index};
} forEach _kits;

_ctrl lbSetCurSel _selected;

// Row by row, so a pick can be traced back to who holds the kit.
GVAR(kitChoices) = _kits;
GVAR(fillingKitSwitch) = false;
