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

// Typing a kit's name: Return keeps it, Escape throws it away, every other key is the text box's.
if (GVAR(renaming) isNotEqualTo "") exitWith {
    switch (true) do {
        case (_key in [DIK_RETURN, DIK_NUMPADENTER]): {[true] call FUNC(onRenameDone); true};
        case (_key == DIK_ESCAPE): {[false] call FUNC(onRenameDone); true};
        default {false};
    };
};

// The key that opened the window moves it on to the next kit.
if (_this call FUNC(onCycleKey)) exitWith {true};

switch (true) do {
    case (_key in [DIK_LCONTROL, DIK_RCONTROL]): {GVAR(ctrlHeld) = true};
    case (_key in [DIK_LSHIFT, DIK_RSHIFT]): {GVAR(shiftHeld) = true};
    default {
        GVAR(ctrlHeld) = _ctrl;
        GVAR(shiftHeld) = _shift;
    };
};

// Escape closes an open drop down menu first, the window only after that.
if (_key == DIK_ESCAPE && {(_display getVariable [QGVAR(menu), []]) isNotEqualTo []}) exitWith {
    [_display] call FUNC(closeMenu);
    true
};

if !(_key in [DIK_RETURN, DIK_NUMPADENTER]) exitWith {false};

// Done typing: hand focus back to the kit list.
if (focusedCtrl _display in [_display displayCtrl IDC_SEARCH, _display displayCtrl IDC_AMOUNT]) then {
    ctrlSetFocus (_display displayCtrl IDC_LIST_KIT);
};

true
