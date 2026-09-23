#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * A sort box changed: remember the choice and redraw. The choice outlives the dialog, so the next
 * kit opens sorted the same way.
 *
 * Arguments:
 * 0: Sort box <CONTROL>
 * 1: Selected index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 1] call efak_gui_fnc_onSortChanged;
 *
 * Public: No
 */

params ["_ctrl", "_index"];

if (GVAR(fillingSort) || {_index < 0}) exitWith {};

if (ctrlIDC _ctrl == IDC_SORT) then {
    GVAR(sortMode) = _index;
} else {
    GVAR(sortAscending) = _index == 0;
};

call FUNC(refreshPouch);
