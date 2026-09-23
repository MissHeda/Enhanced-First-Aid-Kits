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
 * "inventory" or "crate" <STRING>
 *
 * Example:
 * call efak_gui_fnc_activeSource;
 *
 * Public: No
 */

["inventory", "crate"] select (GVAR(leftSource) isEqualTo SOURCE_CRATE)
