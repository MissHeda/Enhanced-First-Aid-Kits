#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * A row is being dragged: works out how many of it the drag carries and shows that number next to
 * the mouse. The mouse wheel changes it by one while dragging, the middle mouse button takes the
 * whole stack (see fnc_openPouch), and the drop moves exactly that many.
 *
 * Starts with one, with the whole stack when Ctrl is held and with half of it when Shift is.
 *
 * Arguments:
 * 0: List the drag started on <CONTROL>
 * 1: Class of the dragged row <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, "ACE_morphine"] call efak_gui_fnc_onDragStart;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl", "_class"];

private _max = 0;

for "_i" from 0 to ((lnbSize _ctrl) select 0) - 1 do {
    if ((_ctrl lnbData [_i, 0]) isEqualTo _class) exitWith {
        _max = _ctrl lnbValue [_i, 0];
    };
};

// A greyed row goes nowhere, so there is nothing to count.
if (_max <= 0) exitWith {
    call FUNC(onDragEnd);
};

GVAR(dragging) = true;
GVAR(dragMax) = _max;
GVAR(middleHeld) = inputMouse 2 > 0;
GVAR(dragAmount) = switch (true) do {
    case (GVAR(ctrlHeld)): {_max};
    case (GVAR(shiftHeld)): {(floor (_max / 2)) max 1};
    default {1};
};

[0] call FUNC(onDragAmount);

// Follows the mouse for as long as the drag lasts. Nothing reports a drag that ends away from the
// lists, so a released button ends it here as well. The middle button is watched here too: while a
// row is being dragged its click reaches the game rather than the window.
if (GVAR(dragPFH) < 0) then {
    GVAR(dragPFH) = [{
        private _display = uiNamespace getVariable [QGVAR(display), displayNull];

        if (isNull _display || {!GVAR(dragging)} || {inputMouse 0 == 0}) exitWith {
            call FUNC(onDragEnd);
        };

        // Pressed, not held: one press takes the stack once.
        private _middle = inputMouse 2 > 0;

        if (_middle && {!GVAR(middleHeld)}) then {
            [0, true] call FUNC(onDragAmount);
        };

        GVAR(middleHeld) = _middle;

        private _counter = _display displayCtrl IDC_DRAG_COUNT;

        // Above the pointer, where the name the engine draws next to it does not cover it.
        getMousePosition params ["_mouseX", "_mouseY"];
        (ctrlPosition _counter) params ["", "", "_w", "_h"];

        _counter ctrlSetPosition [_mouseX - _w / 2, _mouseY - _h - ROW * 0.4];
        _counter ctrlCommit 0;
    }, 0] call CBA_fnc_addPerFrameHandler;
};
