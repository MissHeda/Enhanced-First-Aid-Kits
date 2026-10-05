#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Ends typing a kit's name: keeps it (Return, a click elsewhere) or throws it away (Escape). An
 * empty name gives the kit its type's name back.
 *
 * Arguments:
 * 0: Keep what was typed <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call efak_gui_fnc_onRenameDone;
 *
 * Public: No
 */

disableSerialization;

params [["_keep", true]];

if (GVAR(renaming) isEqualTo "") exitWith {};

private _kitClass = GVAR(renaming);
GVAR(renaming) = "";
GVAR(renameClosedAt) = diag_tickTime;
GVAR(lastRenamed) = _kitClass;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

private _edit = _display displayCtrl IDC_RENAME_EDIT;

// Kept as typed - unless it is the usual name again, which is no name of its own.
if (_keep) then {
    private _text = trim ctrlText _edit;
    [_kitClass, ["", _text] select (_text isNotEqualTo ([_kitClass] call EFUNC(core,getKitTitle)) || {([_kitClass] call EFUNC(core,getKitLabel)) isNotEqualTo ""})] call EFUNC(core,setKitLabel);
};

// The arrow stays a moment: the press on it is what ended the typing (fnc_onRenameReset).
[{
    params ["_display"];
    if (isNull _display || {GVAR(renaming) isNotEqualTo ""}) exitWith {};
    {(_display displayCtrl _x) ctrlShow false} forEach [IDC_RENAME_RESET_ICON, IDC_RENAME_RESET_HIT];
}, [_display], 0.3] call CBA_fnc_waitAndExecute;

_edit ctrlShow false;
(_display displayCtrl IDC_KIT_SWITCH) ctrlShow true;
ctrlSetFocus (_display displayCtrl IDC_LIST_KIT);

// The name shows at once here; on the other machines it follows with the event.
[{call FUNC(refreshPouch)}] call CBA_fnc_execNextFrame;
