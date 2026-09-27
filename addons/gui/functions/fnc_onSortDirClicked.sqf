#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The sort direction button: turns the order of every list round.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onSortDirClicked;
 *
 * Public: No
 */

GVAR(sortAscending) = !GVAR(sortAscending);

call FUNC(refreshPouch);
