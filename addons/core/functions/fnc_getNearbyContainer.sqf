#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The crate or vehicle the player is standing at, so the pouch can offer it as a second source.
 *
 * Preference in order: the container the player last opened (exact - the engine tells us which
 * one), the vehicle they are sitting in, then the nearest supply crate. Anything further away
 * than arm's reach does not count.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Container <OBJECT>, objNull when there is none
 *
 * Example:
 * call efak_core_fnc_getNearbyContainer;
 *
 * Public: No
 */

private _last = GVAR(lastContainer);

if (!isNull _last && {alive _last} && {_last distance ACE_player < 6} && {maxLoad _last > 0}) exitWith {
    _last
};

private _vehicle = objectParent ACE_player;

if (!isNull _vehicle) exitWith {_vehicle};

private _boxes = nearestObjects [ACE_player, ["ReammoBox_F"], 4];
private _result = objNull;

{
    if (alive _x && {maxLoad _x > 0}) exitWith {_result = _x};
} forEach _boxes;

_result
