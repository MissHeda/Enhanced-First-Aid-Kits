#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * A row of a drop down menu (fnc_openMenu) was clicked: the menu closes and its field gets the choice.
 * Both a frame later - the row is deleted with the menu, which must not happen inside its own event.
 *
 * Arguments:
 * 0: The row's hit area <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl] call efak_gui_fnc_onMenuPick;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl"];

private _index = (_ctrl getVariable [QGVAR(menuRow), [-1]]) select 0;

if (_index < 0) exitWith {};

[{
    params ["_display", "_index"];

    if (isNull _display) exitWith {};

    private _menu = _display getVariable [QGVAR(menu), []];

    if (_menu isEqualTo []) exitWith {};

    _menu params ["", "", "_onPick", "_arguments"];

    [_display] call FUNC(closeMenu);
    [_index, _arguments] call _onPick;
}, [ctrlParent _ctrl, _index]] call CBA_fnc_execNextFrame;
