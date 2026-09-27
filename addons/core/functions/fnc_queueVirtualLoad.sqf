#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Schedules a kit weight update for the local player on the next frame.
 *
 * The things that change kit weight come in bursts - taking everything out of a kit raises a
 * contents event per item, a respawn raises both the unit and the loadout event - and each update
 * can broadcast. Collapsing a burst into one update keeps that to a single broadcast.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_queueVirtualLoad;
 *
 * Public: No
 */

if (!hasInterface || {GVAR(virtualLoadQueued)}) exitWith {};

GVAR(virtualLoadQueued) = true;

[{
    GVAR(virtualLoadQueued) = false;
    [ACE_player] call FUNC(updateVirtualLoad);
}] call CBA_fnc_execNextFrame;
