#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * One of the two sort boxes changed: remember the choice and redraw the contents list. The choice
 * outlives the tab, so the next kit opens sorted the same way.
 *
 * Arguments:
 * 0: Sort box <CONTROL>
 * 1: Selected index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 1] call efak_arsenal_fnc_onSortChanged;
 *
 * Public: No
 */

params ["_ctrl", "_index"];

// Filling the boxes selects an entry from script, which raises this same event.
if (GVAR(fillingSort) || {_index < 0}) exitWith {};

if (ctrlIDC _ctrl == IDC_EFAK_SORT) then {
    GVAR(sortMode) = _index;
} else {
    GVAR(sortAscending) = _index == 0;
};

[ctrlParent _ctrl] call FUNC(fillContents);
