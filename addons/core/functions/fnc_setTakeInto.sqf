#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Remembers where the player wants items taken out of this type of kit to go first.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 * 1: CONTAINER_AUTO, CONTAINER_UNIFORM, CONTAINER_VEST or CONTAINER_BACKPACK <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", 2] call efak_core_fnc_setTakeInto;
 *
 * Public: No
 */

params ["_class", "_mode"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {};

// Decided by the mission: nothing for the player to choose.
if ([_class] call FUNC(isTakeIntoForced)) exitWith {};

if ([_class] call FUNC(getTakeInto) isEqualTo _mode) exitWith {};

private _id = _kit select KIT_ID;
private _pairs = (profileNamespace getVariable [QGVAR(takeInto), []]) select {
    _x isEqualType [] && {(_x param [0, ""]) isNotEqualTo _id}
};

_pairs pushBack [_id, _mode];

profileNamespace setVariable [QGVAR(takeInto), _pairs];
saveProfileNamespace;
