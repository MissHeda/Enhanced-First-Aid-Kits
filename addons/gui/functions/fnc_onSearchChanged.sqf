#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The search box changed: filter all three lists by it.
 *
 * Arguments:
 * 0: Search box <CONTROL>
 * 1: New text <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, "band"] call efak_gui_fnc_onSearchChanged;
 *
 * Public: No
 */

params ["", "_text"];

GVAR(searchText) = trim _text;

// "Search" in the field only while nothing is typed.
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
(_display displayCtrl IDC_SEARCH_PLACEHOLDER) ctrlShow (_text isEqualTo "");

call FUNC(refreshPouch);
