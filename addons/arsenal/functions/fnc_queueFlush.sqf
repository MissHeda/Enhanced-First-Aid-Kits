#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Writes the staged kit contents shortly after the last change.
 *
 * Every write is broadcast to every machine, once per kit. Clicking "+" five times on three kits
 * would otherwise send fifteen of them. Each click pushes the write back, so a burst of clicks
 * ends in one write per kit.
 *
 * When the write held something back (see flush), the contents list is drawn again so it shows
 * what the kits really hold now.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_queueFlush;
 *
 * Public: No
 */

private _fnc_write = {
    if (call FUNC(flush)) then {
        [findDisplay IDD_ACE_ARSENAL] call FUNC(fillContents);
    };
};

// The Eden editor never starts CBA's frame loop, so a delayed write would never happen there.
if (is3DEN) exitWith {call _fnc_write};

GVAR(flushToken) = GVAR(flushToken) + 1;

[{
    params ["_token", "_fnc_write"];

    // A newer click, a closed tab or a closed arsenal has already taken care of it.
    if (GVAR(active) && {_token == GVAR(flushToken)}) then {
        call _fnc_write;
    };
}, [GVAR(flushToken), _fnc_write], FLUSH_DELAY] call CBA_fnc_waitAndExecute;
