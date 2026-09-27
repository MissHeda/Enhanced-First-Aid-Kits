#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The search bar above the contents list changed: filter the list by it, as you type.
 *
 * Arguments:
 * 0: Search bar <CONTROL>
 * 1: New text <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, "band"] call efak_arsenal_fnc_onSearchChanged;
 *
 * Public: No
 */

params ["_ctrl", "_text"];

GVAR(searchText) = trim _text;

[ctrlParent _ctrl] call FUNC(fillContents);
