#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The pencil next to the kits tab's title: the selected kit's row becomes a text box with its name
 * in it. Return, the pencil again or a click elsewhere keeps what was typed (fnc_onRenameDone); an
 * empty name, or the arrow at the end of the box, gives the kit its usual one back.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_onRenameClick;
 *
 * Public: No
 */

private _display = findDisplay IDD_ACE_ARSENAL;

if (isNull _display || {!GVAR(active)}) exitWith {};

// The click on the pencil that ended typing - the box lost its focus to it a moment ago.
if (diag_tickTime - GVAR(renameClosedAt) < 0.25) exitWith {};

if (GVAR(selectedPreparing) || {GVAR(selected) isEqualTo ""}) exitWith {};

private _list = _display displayCtrl IDC_EFAK_KIT_LIST;
private _row = lbCurSel _list;

if (_row < 0) exitWith {};

// The row on screen: rows are KIT_ROW_H high, counted from the first one in view.
(ctrlPosition _list) params ["_listX", "_listY", "_listW", "_listH"];

private _visible = floor (_listH / KIT_ROW_H);
private _first = 0;

if (lbSize _list > _visible) then {
    _first = round ((((ctrlScrollValues _list) param [0, 0]) max 0) * (lbSize _list - _visible));
};

private _rowY = _listY + (_row - _first) * KIT_ROW_H;
private _label = [GVAR(selected)] call EFUNC(core,getKitLabel);
private _resetW = 6 * GRID_W;

private _edit = _display displayCtrl IDC_EFAK_RENAME_EDIT;
private _reset = _display displayCtrl IDC_EFAK_RENAME_RESET;

GVAR(renaming) = GVAR(selected);

// The name as the row shows it - its own, or the usual one to start from.
_edit ctrlSetText ([_label, _list lbText _row] select (_label isEqualTo ""));
_edit ctrlSetPosition [_listX + 7 * GRID_W, _rowY, _listW - 7 * GRID_W - 2 * _resetW, KIT_ROW_H];
_edit ctrlShow true;
_edit ctrlEnable true;
_edit ctrlSetFade 0;
_edit ctrlCommit 0;

_reset ctrlSetPosition [_listX + _listW - 2 * _resetW, _rowY, _resetW, KIT_ROW_H];
_reset ctrlShow true;
_reset ctrlEnable true;
_reset ctrlSetFade 0;
_reset ctrlCommit 0;

// A control that had focus is drawn above the others: the arrow over the list, then the box.
ctrlSetFocus _reset;
ctrlSetFocus _edit;
_edit ctrlSetTextSelection [0, count ctrlText _edit];
