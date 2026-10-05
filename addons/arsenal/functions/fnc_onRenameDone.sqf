#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Ends typing a kit's name in the kits tab: keeps it, or throws it away when the tab closes.
 *
 * Arguments:
 * 0: Keep what was typed <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call efak_arsenal_fnc_onRenameDone;
 *
 * Public: No
 */

params [["_keep", true]];

if (GVAR(renaming) isEqualTo "") exitWith {};

private _kit = GVAR(renaming);
GVAR(renaming) = "";
GVAR(renameClosedAt) = diag_tickTime;
GVAR(lastRenamed) = _kit;

private _display = findDisplay IDD_ACE_ARSENAL;

if (isNull _display) exitWith {};

private _edit = _display displayCtrl IDC_EFAK_RENAME_EDIT;

// Kept as typed - unless it is the usual name again, which is no name of its own.
if (_keep) then {
    private _text = trim ctrlText _edit;
    private _usual = [_kit] call EFUNC(core,getKitName);

    [_kit, ["", _text] select (_text isNotEqualTo _usual && {(_text find (_usual + " #")) != 0})] call EFUNC(core,setKitLabel);
};

_edit ctrlShow false;
_edit ctrlEnable false;
_edit ctrlCommit 0;

// The arrow stays a moment: the press on it is what ended the typing (fnc_onRenameReset).
[{
    private _reset = (findDisplay IDD_ACE_ARSENAL) displayCtrl IDC_EFAK_RENAME_RESET;
    if (GVAR(renaming) isEqualTo "") then {_reset ctrlShow false};
}, [], 0.5] call CBA_fnc_waitAndExecute;

// The list and the contents title show the name - a frame later, when it has arrived.
[{
    call FUNC(refreshKits);
    [findDisplay IDD_ACE_ARSENAL] call FUNC(fillContents);
}] call CBA_fnc_execNextFrame;
