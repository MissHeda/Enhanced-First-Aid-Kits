#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * How many items the Pack and Take buttons should move, read from the amount box.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Amount, or AMOUNT_ALL when the box is empty or zero <NUMBER>
 *
 * Example:
 * call efak_gui_fnc_getAmount;
 *
 * Public: No
 */

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {AMOUNT_ALL};

private _amount = floor parseNumber ctrlText (_display displayCtrl IDC_AMOUNT);

[AMOUNT_ALL, _amount] select (_amount >= 1)
