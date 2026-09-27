#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The player picked another sort order (fnc_onDropdownClick): every list is sorted by it from now on.
 *
 * Arguments:
 * 0: Picked row, SORT_NAME, SORT_MASS or SORT_AMOUNT <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [SORT_MASS] call efak_gui_fnc_onSortChanged;
 *
 * Public: No
 */

params ["_index"];

GVAR(sortMode) = _index;

[uiNamespace getVariable [QGVAR(display), displayNull]] call FUNC(fillSort);
call FUNC(refreshPouch);
