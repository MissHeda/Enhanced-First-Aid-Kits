#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The player picked where items taken out of this kit go first. Remembered for this type of kit;
 * everything taken out from now on goes there first.
 *
 * Arguments:
 * 0: The box <CONTROL>
 * 1: Selected row, which is the mode <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 2] call efak_gui_fnc_onTakeIntoChanged;
 *
 * Public: No
 */

params ["", "_index"];

if (GVAR(fillingTakeInto) || {_index < 0}) exitWith {};

[GVAR(kitClass), _index] call EFUNC(core,setTakeInto);
