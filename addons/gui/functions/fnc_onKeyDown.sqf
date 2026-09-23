#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Display key down: keeps track of Ctrl and Shift, and keeps Enter from doing anything.
 *
 * No command reports whether a key is held, and neither the list double click nor the drop event
 * carries any modifier state - so the dialog records it here, as the keys themselves go down and up.
 *
 * Every move takes effect the moment it is made, so Enter has nothing to confirm: it is swallowed
 * rather than left to the engine's OK handling. In the search or amount box it means "done typing".
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: DIK code <NUMBER>
 * 2: Shift held <BOOL>
 * 3: Ctrl held <BOOL>
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * [_display, 29, false, true] call efak_gui_fnc_onKeyDown;
 *
 * Public: No
 */

params ["_display", "_key", "_shift", "_ctrl"];

switch (true) do {
    case (_key in [DIK_LCONTROL, DIK_RCONTROL]): {GVAR(ctrlHeld) = true};
    case (_key in [DIK_LSHIFT, DIK_RSHIFT]): {GVAR(shiftHeld) = true};
    default {
        GVAR(ctrlHeld) = _ctrl;
        GVAR(shiftHeld) = _shift;
    };
};

if !(_key in [DIK_RETURN, DIK_NUMPADENTER]) exitWith {false};

// Done typing: hand focus back to the kit list.
if (focusedCtrl _display in [_display displayCtrl IDC_SEARCH, _display displayCtrl IDC_AMOUNT]) then {
    ctrlSetFocus (_display displayCtrl IDC_LIST_KIT);
};

true
