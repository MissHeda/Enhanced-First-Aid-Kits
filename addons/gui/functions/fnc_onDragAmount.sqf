#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Changes how many items the current drag carries and redraws the number next to the mouse.
 *
 * Arguments:
 * 0: Change <NUMBER>
 * 1: Take the whole stack <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [1] call efak_gui_fnc_onDragAmount;
 * [0, true] call efak_gui_fnc_onDragAmount;
 *
 * Public: No
 */

disableSerialization;

params ["_change", ["_all", false]];

if (!GVAR(dragging)) exitWith {};

GVAR(dragAmount) = if (_all) then {
    GVAR(dragMax)
} else {
    ((GVAR(dragAmount) + _change) max 1) min GVAR(dragMax)
};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

private _counter = _display displayCtrl IDC_DRAG_COUNT;

// Just the number, as the counts in the lists show it.
_counter ctrlSetStructuredText parseText format ["%1x", GVAR(dragAmount)];

_counter ctrlShow true;
