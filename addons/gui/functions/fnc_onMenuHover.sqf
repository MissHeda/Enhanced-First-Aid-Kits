#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The mouse went onto or off a row of a drop down menu (fnc_openMenu): the row lights up under it.
 *
 * Arguments:
 * 0: The row's hit area <CONTROL>
 * 1: The mouse went onto it <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, true] call efak_gui_fnc_onMenuHover;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl", "_entered"];

(_ctrl getVariable [QGVAR(menuRow), []]) params [["_index", -1], ["_row", [[], []]]];
_row params ["_rects", "_corners"];

private _color = [S_CLEAR, S_FIELD_HOVER] select _entered;

{
    _x ctrlSetBackgroundColor _color;
} forEach _rects;

{
    _x ctrlSetTextColor _color;
} forEach _corners;
