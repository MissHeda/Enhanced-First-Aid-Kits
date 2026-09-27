#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Paints a button (fnc_initButtons) in one of its states: its surface, its icon and its label, in the
 * colours GVAR(buttonStyles) gives that button for that state.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Button name <STRING>
 * 2: BUTTON_NORMAL, BUTTON_HOVER, BUTTON_ACTIVE or BUTTON_DISABLED <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "BtnClose", BUTTON_HOVER] call efak_gui_fnc_paintButton;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_base", "_state"];

private _entry = (_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault [_base, []];
private _style = GVAR(buttonStyles) getOrDefault [_base, []];

if (_entry isEqualTo [] || {_style isEqualTo []}) exitWith {};

_entry params ["_rects", "_corners", "_icons", "_labels"];
_style params ["_surface", "_icon", "_label"];

private _fill = _surface select _state;

{_x ctrlSetBackgroundColor _fill} forEach _rects;
{_x ctrlSetTextColor _fill} forEach _corners;
{_x ctrlSetTextColor (_icon select _state)} forEach _icons;
{_x ctrlSetTextColor (_label select _state)} forEach _labels;
