#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Closes the kit window's open drop down menu (fnc_openMenu), if there is one: deletes its controls
 * and paints its field back. Must not run inside an event of one of the menu's own controls - those
 * go through CBA_fnc_execNextFrame.
 *
 * Arguments:
 * 0: Kit window <DISPLAY> (default: the open one)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_closeMenu;
 *
 * Public: No
 */

disableSerialization;

params [["_display", uiNamespace getVariable [QGVAR(display), displayNull]]];

if (isNull _display) exitWith {};

private _menu = _display getVariable [QGVAR(menu), []];

if (_menu isEqualTo []) exitWith {};

_display setVariable [QGVAR(menu), []];

_menu params ["_base", "_created", "", "", ["_tooltip", ""]];

// Last made first: the rows before the group they are in.
reverse _created;

{
    ctrlDelete _x;
} forEach _created;

// Switched off meanwhile - a kit whose unload container the mission sets, say - it stays off.
private _field = ((_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault [_base, []]) param [4, controlNull];

[_display, _base, ctrlEnabled _field, false] call FUNC(setButton);

// The field's tooltip, off while the menu was open - fnc_fillKitSwitch and fnc_fillTakeInto keep it
// up to date meanwhile.
_field ctrlSetTooltip _tooltip;
