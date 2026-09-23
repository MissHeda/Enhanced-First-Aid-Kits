#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Switches the left panel between the player's own gear and the crate in front of them.
 *
 * Arguments:
 * 0: Source <NUMBER> - SOURCE_INVENTORY or SOURCE_CRATE
 *
 * Return Value:
 * None
 *
 * Example:
 * [SOURCE_CRATE] call efak_gui_fnc_selectSource;
 *
 * Public: No
 */

params ["_source"];

if (_source isEqualTo SOURCE_CRATE && {isNull GVAR(crate)}) exitWith {};

GVAR(leftSource) = _source;
GVAR(message) = "";

call FUNC(refreshPouch);
