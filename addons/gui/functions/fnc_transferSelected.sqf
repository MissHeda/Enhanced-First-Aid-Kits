#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Transfers whatever is selected in one of the two lists. Used by the arrow
 * buttons and the keyboard.
 *
 * Arguments:
 * 0: Source list IDC <NUMBER>
 * 1: Amount, or AMOUNT_ALL / AMOUNT_HALF <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [IDC_LIST_KIT, AMOUNT_ALL] call efak_gui_fnc_transferSelected;
 *
 * Public: No
 */

disableSerialization;

params ["_sourceIdc", ["_amount", AMOUNT_ALL]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

[_sourceIdc, lnbCurSelRow (_display displayCtrl _sourceIdc), _amount] call FUNC(transfer);
