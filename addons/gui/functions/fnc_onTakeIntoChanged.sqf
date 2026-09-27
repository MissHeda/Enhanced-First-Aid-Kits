#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The player picked where items taken out of this kit go first (fnc_onDropdownClick): kept per kit
 * type in the profile.
 *
 * Arguments:
 * 0: Picked row, CONTAINER_AUTO to CONTAINER_BACKPACK <NUMBER>
 * 1: The kit the menu was opened for <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [1, "efak_IFAK_7"] call efak_gui_fnc_onTakeIntoChanged;
 *
 * Public: No
 */

params ["_index", "_kitClass"];

[_kitClass, _index] call EFUNC(core,setTakeInto);
[uiNamespace getVariable [QGVAR(display), displayNull]] call FUNC(fillTakeInto);
