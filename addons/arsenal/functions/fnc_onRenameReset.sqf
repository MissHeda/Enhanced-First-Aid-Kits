#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The arrow at the end of the name box in the kits tab: the kit gets its usual name back. The press
 * on it usually ends the typing first (and keeps what was typed) - the kit that was just named is the
 * one it means then.
 *
 * The list below it hands on a press too: a list that had focus is drawn above the arrow, and the
 * press lands on the list then - it counts when it is where the arrow is.
 *
 * Arguments:
 * 0: Control pressed <CONTROL> (default: controlNull)
 * 1: Mouse button <NUMBER> (default: 0)
 * 2: Mouse X <NUMBER> (default: -1)
 * 3: Mouse Y <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_onRenameReset;
 *
 * Public: No
 */

params [["_ctrl", controlNull], ["_button", 0], ["_mouseX", -1], ["_mouseY", -1]];

private _reset = (findDisplay IDD_ACE_ARSENAL) displayCtrl IDC_EFAK_RENAME_RESET;

if (_button != 0 || {!ctrlShown _reset}) exitWith {};

if (ctrlIDC _ctrl == IDC_EFAK_KIT_LIST && {
    (ctrlPosition _reset) params ["_resetX", "_resetY", "_resetW", "_resetH"];
    _mouseX < _resetX || {_mouseX > _resetX + _resetW} || {_mouseY < _resetY} || {_mouseY > _resetY + _resetH}
}) exitWith {};

private _kit = GVAR(renaming);

if (_kit isNotEqualTo "") then {
    [false] call FUNC(onRenameDone);
} else {
    if (diag_tickTime - GVAR(renameClosedAt) < 0.5) then {_kit = GVAR(lastRenamed)};
};

if (_kit isEqualTo "") exitWith {};

[_kit, ""] call EFUNC(core,setKitLabel);

[{
    call FUNC(refreshKits);
    [findDisplay IDD_ACE_ARSENAL] call FUNC(fillContents);
}] call CBA_fnc_execNextFrame;
