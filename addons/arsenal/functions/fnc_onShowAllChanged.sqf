#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * "All allowed items" box ticked or cleared: the kits button lists every item the selected kit may
 * hold, or only what it holds.
 *
 * Arguments:
 * 0: Checkbox <CONTROL>
 * 1: Checked, 0 or 1 <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_box, 1] call efak_arsenal_fnc_onShowAllChanged;
 *
 * Public: No
 */

params ["_box", "_checked"];

GVAR(showAll) = _checked isEqualTo 1;

if (!GVAR(active)) exitWith {};

[ctrlParent _box] call FUNC(fillContents);
