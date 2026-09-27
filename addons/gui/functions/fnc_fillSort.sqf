#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows the sort order in use on the sort field. Its menu is fnc_onDropdownClick.
 *
 * Arguments:
 * 0: Pouch display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_fillSort;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

if (isNull _display) exitWith {};

(_display displayCtrl IDC_SORT) ctrlSetText ([LLSTRING(Sort_Name), LLSTRING(Sort_Mass), LLSTRING(Sort_Amount)] param [GVAR(sortMode), ""]);
