#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The player picked another kit in the switcher at the top (fnc_onDropdownClick): the window shows
 * that one from now on, without closing.
 *
 * Arguments:
 * 0: Picked row <NUMBER>
 * 1: The kits the menu listed, see fnc_fillKitSwitch <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [1, efak_gui_kitChoices] call efak_gui_fnc_onKitSwitchChanged;
 *
 * Public: No
 */

params ["_index", "_kits"];

(_kits param [_index, []]) params [["_holder", objNull], ["_kitClass", ""]];

if (_kitClass isEqualTo "" || {(toLowerANSI _kitClass) isEqualTo (toLowerANSI GVAR(kitClass))}) exitWith {};

[_holder, _kitClass] call FUNC(selectKit);
