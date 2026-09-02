#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the container unpacked items should go into, as expected by
 * ace_common_fnc_addToInventory. "" lets ACE pick.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Container name <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitContainer;
 *
 * Public: No
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {""};

switch (missionNamespace getVariable [format [QGVAR(kit_%1_container), _kit select KIT_ID], CONTAINER_AUTO]) do {
    case CONTAINER_UNIFORM: {"uniform"};
    case CONTAINER_VEST: {"vest"};
    case CONTAINER_BACKPACK: {"backpack"};
    default {""};
}
