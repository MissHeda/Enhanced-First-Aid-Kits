#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Drops an empty kit from the inventory of the unit carrying it, if the kit is
 * set up to disappear when empty, and hands its instance id back to the pool.
 *
 * The removal is routed to the machine the unit is local on, so a medic can
 * empty the kit of a casualty on another client.
 *
 * Arguments:
 * 0: Unit carrying the kit <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * Kit was removed <BOOL>
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_core_fnc_removeKit;
 *
 * Public: No
 */

params ["_kitOwner", "_kitClass"];

private _kit = [_kitClass] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {false};

if (([_kitClass] call FUNC(getContents)) isNotEqualTo []) exitWith {false};

// Off unless the mission says otherwise: an emptied kit is still a container, and taking it out
// of somebody's hands the moment the last dressing leaves it is not what anybody expects.
private _removeWhenEmpty = missionNamespace getVariable [
    format [QGVAR(kit_%1_removeWhenEmpty), _kit select KIT_ID],
    false
];

if !(_removeWhenEmpty) exitWith {false};

[QGVAR(removeItem), [_kitOwner, _kitClass], _kitOwner] call CBA_fnc_targetEvent;
[_kitClass] call FUNC(freeInstance);

true
