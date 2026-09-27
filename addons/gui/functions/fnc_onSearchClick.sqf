#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Right click on the search box clears it, the same as in ACE Arsenal.
 *
 * Arguments:
 * 0: Search box <CONTROL>
 * 1: Mouse button <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 1] call efak_gui_fnc_onSearchClick;
 *
 * Public: No
 */

params ["_ctrl", "_button"];

if (_button != 1) exitWith {};

_ctrl ctrlSetText "";
GVAR(searchText) = "";

// Setting the text from script raises no change event, so "Search" is put back here.
((ctrlParent _ctrl) displayCtrl IDC_SEARCH_PLACEHOLDER) ctrlShow true;

call FUNC(refreshPouch);
