#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The container items taken out of this kit go into first, as the player chose it in the kit
 * window (fnc_getTakeInto). "" means no preference: uniform, then vest, then backpack.
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

switch ([_class] call FUNC(getTakeInto)) do {
    case CONTAINER_UNIFORM: {"uniform"};
    case CONTAINER_VEST: {"vest"};
    case CONTAINER_BACKPACK: {"backpack"};
    default {""};
}
