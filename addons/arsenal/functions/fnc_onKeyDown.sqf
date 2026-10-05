#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Arrow keys on the kit contents list take one out or put one in, the way they do on ACE's
 * container lists. Shift makes it five.
 *
 * Added next to ACE's own key handler, never instead of it: every other key is left to ACE.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 * 1: DIK code <NUMBER>
 * 2: Shift held <BOOL>
 * 3: Ctrl held <BOOL>
 * 4: Alt held <BOOL>
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * [findDisplay 1127001, 205, false, false, false] call efak_arsenal_fnc_onKeyDown;
 *
 * Public: No
 */

params ["_display", "_key", ["_shift", false]];

// Typing a kit's name: Return keeps it. (Escape closes the arsenal, as ACE has it.)
if (GVAR(renaming) isNotEqualTo "" && {_key in [DIK_RETURN, DIK_NUMPADENTER]}) exitWith {
    [true] call FUNC(onRenameDone);
    true
};

if (!GVAR(active) || {!GVAR(contentsFocus)}) exitWith {false};
if !(_key in [DIK_LEFT, DIK_RIGHT]) exitWith {false};

// The loadouts screen sits on top and has keys of its own.
if !(isNull findDisplay IDD_ACE_LOADOUTS) exitWith {false};

[_display, [-1, 1] select (_key == DIK_RIGHT), _shift] call FUNC(buttonCargo);

true
