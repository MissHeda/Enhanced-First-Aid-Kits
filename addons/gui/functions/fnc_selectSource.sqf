#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Switches the left panel between the player's own gear and the crate in front of them.
 *
 * Arguments:
 * 0: Source <NUMBER> - SOURCE_INVENTORY, or SOURCE_CRATE for the second tab (the crate, or the ground)
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

// The tab already showing: nothing changes, and a message still standing is not wiped away.
if (_source isEqualTo GVAR(leftSource)) exitWith {};

GVAR(leftSource) = _source;
GVAR(message) = "";

call FUNC(refreshPouch);
