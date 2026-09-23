#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Display key up: notices Ctrl or Shift being let go.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: DIK code <NUMBER>
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * [_display, 29] call efak_gui_fnc_onKeyUp;
 *
 * Public: No
 */

params ["_display", "_key"];

if (_key in [DIK_LCONTROL, DIK_RCONTROL]) then {GVAR(ctrlHeld) = false};
if (_key in [DIK_LSHIFT, DIK_RSHIFT]) then {GVAR(shiftHeld) = false};

false
