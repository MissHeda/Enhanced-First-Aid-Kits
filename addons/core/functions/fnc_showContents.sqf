#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows what is inside a kit in a small window at the edge of the screen. The quick look for when
 * you do not want to open the whole kit window.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Who or what holds the kit - a unit or a crate <OBJECT> (default: ACE_player)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", player] call efak_core_fnc_showContents;
 *
 * Public: Yes
 */

params ["_kitClass", ["_holder", objNull]];

[_kitClass, _holder] call EFUNC(gui,showContents);
