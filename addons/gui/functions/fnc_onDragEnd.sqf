#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The drag is over - dropped on a list, let go somewhere else, or the window closed. Hides the number
 * next to the mouse. The amount itself stays until the next drag starts: the drop may be handled
 * after the button that ended it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onDragEnd;
 *
 * Public: No
 */

disableSerialization;

GVAR(dragging) = false;

if (GVAR(dragPFH) >= 0) then {
    [GVAR(dragPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(dragPFH) = -1;
};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

(_display displayCtrl IDC_DRAG_COUNT) ctrlShow false;
