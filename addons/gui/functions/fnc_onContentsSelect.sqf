#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * A row of the contents window was picked: Take works only while an item is selected.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onContentsSelect;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(contentsDisplay), displayNull];

if (isNull _display) exitWith {};

private _list = _display displayCtrl IDC_CONTENTS_LIST;
private _row = lbCurSel _list;

[_display, "BtnTake", _row >= 0 && {(_list lbData _row) isNotEqualTo ""}] call FUNC(setButton);
