#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The player picked another kit in the switcher at the top: the window shows that one from now on,
 * without closing.
 *
 * Arguments:
 * 0: The switcher <CONTROL>
 * 1: Selected row <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 1] call efak_gui_fnc_onKitSwitchChanged;
 *
 * Public: No
 */

params ["", "_index"];

if (GVAR(fillingKitSwitch) || {_index < 0}) exitWith {};

(GVAR(kitChoices) param [_index, []]) params [["_holder", objNull], ["_kitClass", ""]];

if (_kitClass isEqualTo "" || {(toLowerANSI _kitClass) isEqualTo (toLowerANSI GVAR(kitClass))}) exitWith {};

// Switching fills this box again, which is better not done from inside its own change event.
[FUNC(selectKit), [_holder, _kitClass]] call CBA_fnc_execNextFrame;
