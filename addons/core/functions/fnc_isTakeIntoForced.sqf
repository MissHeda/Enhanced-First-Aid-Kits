#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether the mission decides where items taken out of this type of kit go, rather than the player.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Decided by the mission <BOOL>
 *
 * Example:
 * ["efak_MFAK_3"] call efak_core_fnc_isTakeIntoForced;
 *
 * Public: No
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {false};

(missionNamespace getVariable [format [QGVAR(kit_%1_unloadContainer), _kit select KIT_ID], CONTAINER_PLAYER]) != CONTAINER_PLAYER
