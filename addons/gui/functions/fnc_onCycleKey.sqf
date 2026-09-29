#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Key down in the kit window or the quick access window: the key that opened the window moves it
 * on to the next kit the player carries.
 *
 * Both windows are dialogs, and CBA hands keys to its keybinds from the mission display only - so
 * the window checks its own keybind here. A kit further back in the vest is one or two presses away
 * instead of a detour through the interaction menu.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: DIK code <NUMBER>
 * 2: Shift held <BOOL>
 * 3: Ctrl held <BOOL>
 * 4: Alt held <BOOL>
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * [_display, 35, false, false, false] call efak_gui_fnc_onCycleKey;
 *
 * Public: No
 */

params ["_display", "_key", "_shift", "_ctrl", "_alt"];

private _isPouch = _display isEqualTo (uiNamespace getVariable [QGVAR(display), displayNull]);
private _action = [QEGVAR(core,quickAccess), QEGVAR(core,openPouch)] select _isPouch;

(["EFAK", _action] call CBA_fnc_getKeybind) params ["", "", "", "", "", ["_binding", [0, []]]];
_binding params [["_dik", 0], ["_modifiers", []]];
_modifiers params [["_needShift", false], ["_needCtrl", false], ["_needAlt", false]];

// Unbound, or some other key.
if (_dik <= 0 || {_key != _dik} || {[_shift, _ctrl, _alt] isNotEqualTo [_needShift, _needCtrl, _needAlt]}) exitWith {false};

private _kits = [ACE_player] call EFUNC(core,getCarriedKits);

if (count _kits < 2) exitWith {true};

private _current = [GVAR(contentsKit), GVAR(kitClass)] select _isPouch;
private _next = _kits select (((_kits findIf {_x == _current}) + 1) mod count _kits);

if (_isPouch) then {
    [ACE_player, _next] call FUNC(selectKit);
} else {
    GVAR(contentsKit) = _next;
    GVAR(contentsHolder) = ACE_player;
    call FUNC(fillContentsPopup);
};

true
