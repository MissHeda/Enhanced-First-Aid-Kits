#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills the "Unload container" box with the four choices and selects the one the player picked
 * for this type of kit last time - or the one the mission decided, in which case the box is locked.
 *
 * Arguments:
 * 0: Kit window <DISPLAY>
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

private _ctrl = _display displayCtrl IDC_TAKE_INTO;

// Filling and selecting fire the change handler, which would write the choice straight back.
GVAR(fillingTakeInto) = true;

lbClear _ctrl;

// The order matches CONTAINER_AUTO .. CONTAINER_BACKPACK, so the row is the mode.
{
    _ctrl lbAdd _x;
} forEach [
    LELSTRING(core,Container_Auto),
    LELSTRING(core,Container_Uniform),
    LELSTRING(core,Container_Vest),
    LELSTRING(core,Container_Backpack)
];

_ctrl lbSetCurSel ([GVAR(kitClass)] call EFUNC(core,getTakeInto));

GVAR(fillingTakeInto) = false;

private _forced = [GVAR(kitClass)] call EFUNC(core,isTakeIntoForced);
private _tooltip = [LLSTRING(TakeInto_Tooltip), LLSTRING(TakeInto_Forced)] select _forced;

_ctrl ctrlEnable !_forced;
_ctrl ctrlSetTooltip _tooltip;
(_display displayCtrl IDC_TAKE_INTO_LABEL) ctrlSetTooltip _tooltip;
