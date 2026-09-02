#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Moves one entry between the player's inventory and the open kit.
 *
 * Arguments:
 * 0: Source list IDC <NUMBER>
 * 1: Row index <NUMBER>
 * 2: Amount, or AMOUNT_ALL / AMOUNT_HALF <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [IDC_LIST_KIT, 0, AMOUNT_ALL] call efak_gui_fnc_transfer;
 *
 * Public: No
 */

disableSerialization;

params ["_sourceIdc", "_index", ["_amount", AMOUNT_ALL]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display || {_index < 0}) exitWith {};

private _ctrl = _display displayCtrl _sourceIdc;
private _class = _ctrl lbData _index;

if (_class isEqualTo "") exitWith {};

private _stack = _ctrl lbValue _index;
private _count = switch (_amount) do {
    case AMOUNT_ALL: {_stack};
    case AMOUNT_HALF: {(floor (_stack / 2)) max 1};
    default {_amount};
};

if (_count <= 0) exitWith {};

if (_sourceIdc == IDC_LIST_INVENTORY) then {
    [ACE_player, GVAR(kitClass), _class, _count] call EFUNC(core,packItem);
} else {
    [ACE_player, GVAR(kitClass), _class, _count, GVAR(owner)] call EFUNC(core,unpackItem);
};

call FUNC(refreshPouch);
