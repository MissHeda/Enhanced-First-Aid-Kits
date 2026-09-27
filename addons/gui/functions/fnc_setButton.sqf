#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Switches a button (fnc_initButtons) on or off, and marks it as the chosen one of a group - the tab
 * that is showing - or not, and paints it to match.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Button name <STRING>
 * 2: Usable <BOOL>
 * 3: Chosen <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "TabCrate", true, false] call efak_gui_fnc_setButton;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_base", "_enabled", ["_active", false]];

private _entry = (_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault [_base, []];

if (_entry isEqualTo []) exitWith {};

(_entry select 4) ctrlEnable _enabled;
(_display getVariable [QGVAR(buttonActive), createHashMap]) set [_base, _active];

private _state = switch (true) do {
    case (!_enabled): {BUTTON_DISABLED};
    case (_active): {BUTTON_ACTIVE};
    default {BUTTON_NORMAL};
};

[_display, _base, _state] call FUNC(paintButton);
