#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The pencil next to the kit's name: the name turns into a text box, ready to type. Return or
 * clicking elsewhere keeps what was typed, Escape the old name (fnc_onRenameDone, fnc_onKeyDown).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onRenameClick;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display || {GVAR(kitClass) isEqualTo ""}) exitWith {};

private _edit = _display displayCtrl IDC_RENAME_EDIT;

GVAR(renaming) = GVAR(kitClass);

private _label = [GVAR(kitClass)] call EFUNC(core,getKitLabel);

// The name it goes by - its own, or the usual one to start from.
_edit ctrlSetText ([_label, [GVAR(kitClass)] call EFUNC(core,getKitTitle)] select (_label isEqualTo ""));
_edit ctrlShow true;

{
    (_display displayCtrl _x) ctrlShow true;
} forEach [IDC_RENAME_RESET_ICON, IDC_RENAME_RESET_HIT];
(_display displayCtrl IDC_KIT_SWITCH) ctrlShow false;
ctrlSetFocus _edit;
_edit ctrlSetTextSelection [0, count ctrlText _edit];
