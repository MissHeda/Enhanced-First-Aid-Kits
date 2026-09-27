#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The mouse entered or left a button's hit area: its surface lights up while it is over it. A button
 * that is switched off, or the chosen one of a group, stays as it is.
 *
 * Arguments:
 * 0: Hit area <CONTROL>
 * 1: Entered <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, true] call efak_gui_fnc_onButtonHover;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl", "_entered"];

if !(ctrlEnabled _ctrl) exitWith {};

private _display = ctrlParent _ctrl;
private _name = ctrlClassName _ctrl;
private _base = _name select [0, _name find "_"];

if ((_display getVariable [QGVAR(buttonActive), createHashMap]) getOrDefault [_base, false]) exitWith {};

[_display, _base, [BUTTON_NORMAL, BUTTON_HOVER] select _entered] call FUNC(paintButton);
