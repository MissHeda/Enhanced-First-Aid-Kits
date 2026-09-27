#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Right click on the search bar clears it, as in ACE's own.
 *
 * Arguments:
 * 0: Search bar <CONTROL>
 * 1: Mouse button <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 1] call efak_arsenal_fnc_onSearchClick;
 *
 * Public: No
 */

params ["_ctrl", "_button"];

if (_button != 1) exitWith {};

_ctrl ctrlSetText "";
GVAR(searchText) = "";

[ctrlParent _ctrl] call FUNC(fillContents);
