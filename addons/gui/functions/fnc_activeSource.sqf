#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Which place the left panel is currently showing, by the name the moves use (see fnc_getEntries).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * "inventory", "crate" or "ground" <STRING>
 *
 * Example:
 * call efak_gui_fnc_activeSource;
 *
 * Public: No
 */

// The second tab is the crate or vehicle when there is one, the ground otherwise.
if (GVAR(leftSource) isNotEqualTo SOURCE_CRATE) exitWith {"inventory"};

["ground", "crate"] select !isNull GVAR(crate)
