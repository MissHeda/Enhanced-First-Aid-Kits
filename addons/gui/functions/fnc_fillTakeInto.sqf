#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows where items taken out of this kit go first on its field in the middle column, and switches
 * the field off where the mission sets it for the kit type. Its menu is fnc_onDropdownClick.
 *
 * Arguments:
 * 0: Pouch display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_fillTakeInto;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

if (isNull _display) exitWith {};

// The order matches CONTAINER_AUTO .. CONTAINER_BACKPACK, so the mode is the row.
private _names = [
    LELSTRING(core,Container_Auto),
    LELSTRING(core,Container_Uniform),
    LELSTRING(core,Container_Vest),
    LELSTRING(core,Container_Backpack)
];

(_display displayCtrl IDC_TAKE_INTO) ctrlSetText (_names param [[GVAR(kitClass)] call EFUNC(core,getTakeInto), ""]);

private _forced = [GVAR(kitClass)] call EFUNC(core,isTakeIntoForced);
private _tooltip = [LLSTRING(TakeInto_Tooltip), LLSTRING(TakeInto_Forced)] select _forced;
private _open = ((_display getVariable [QGVAR(menu), []]) param [0, ""]) isEqualTo "TakeInto";

[_display, "TakeInto", !_forced, _open && {!_forced}] call FUNC(setButton);

// Not over its own open menu; the menu puts it back when it closes (fnc_closeMenu).
if (_open) then {
    (_display getVariable [QGVAR(menu), []]) set [4, _tooltip];
} else {
    (((_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault ["TakeInto", []]) param [4, controlNull]) ctrlSetTooltip _tooltip;
};
(_display displayCtrl IDC_TAKE_INTO_LABEL) ctrlSetTooltip _tooltip;
