#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Opens a kit in whichever UI the mission is set to. Every way of opening a kit
 * goes through here: the ACE action, the keybind, the inventory context menu
 * and the double click.
 *
 * Arguments:
 * 0: Unit carrying the kit <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * Opened <BOOL>
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_core_fnc_openKit;
 *
 * Public: Yes
 */

params ["_unit", "_kitClass"];

if (!hasInterface || {isNull _unit}) exitWith {false};

if !([_kitClass] call FUNC(isKit)) exitWith {
    WARNING_1("'%1' is not a kit instance.",_kitClass);
    false
};

[_unit, _kitClass] call EFUNC(gui,openPouch);

true
