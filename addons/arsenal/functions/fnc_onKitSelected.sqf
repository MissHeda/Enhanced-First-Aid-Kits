#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows the contents of the kit type picked in the kit list.
 *
 * Arguments:
 * 0: Kit list control <CONTROL>
 * 1: Selected row <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 0] call efak_arsenal_fnc_onKitSelected;
 *
 * Public: No
 */

params ["_ctrl", "_index"];

GVAR(kitSelectionSeen) = true;

if (!GVAR(active)) exitWith {};

// Nothing selected only happens while the list is being rebuilt. The last choice is kept so the
// rebuild can find it again, and the rebuild selects a row right after.
if (_index < 0) exitWith {};

private _display = ctrlParent _ctrl;

private _kind = _ctrl lbValue _index;

if (_kind != ROW_NOTICE) then {
    GVAR(selected) = _ctrl lbData _index;
    GVAR(selectedPreparing) = _kind == ROW_PREPARING;
} else {
    GVAR(selected) = "";
    GVAR(selectedPreparing) = false;
};

[_display] call FUNC(fillContents);
