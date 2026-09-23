#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The Take button of the contents window, and a double click on a row: takes the whole stack of
 * the selected row out of the kit - the full ones, or the opened ones of one fill - into the
 * player's inventory as the kit's unload container says.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onContentsTake;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(contentsDisplay), displayNull];

if (isNull _display) exitWith {};

private _list = _display displayCtrl IDC_CONTENTS_LIST;
private _row = lbCurSel _list;

if (_row < 0) exitWith {};

// "class|which", see fnc_fillContentsPopup: the full ones, or the opened ones of one fill.
((_list lbData _row) splitString "|") params [["_class", ""], ["_which", "-1"]];

if (_class isEqualTo "") exitWith {};

_which = parseNumber _which;

private _match = ([GVAR(contentsKit)] call EFUNC(core,getKitRows)) select {(_x select 0) == _class && {(_x select 2) == _which}};

if (_match isEqualTo []) exitWith {};

[ACE_player, GVAR(contentsKit), _class, (_match select 0) select 1, GVAR(contentsHolder), false, _which] call EFUNC(core,unpackItem);
