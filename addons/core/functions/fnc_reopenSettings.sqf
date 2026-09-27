#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Opens the CBA settings menu again after a short wait - used once a realism mode has been applied,
 * so the player who picked it sees the settings it changed. On top of the pause menu, the Eden
 * editor or the mission, whichever is there.
 *
 * Arguments:
 * 0: Seconds to wait <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [1] call efak_core_fnc_reopenSettings;
 *
 * Public: No
 */

params [["_delay", 1]];

if (!hasInterface) exitWith {};

// Scheduled: the Eden editor has no frame loop to wait with, and the menu that was just closed has
// to be gone first.
[_delay] spawn {
    params ["_delay"];

    uiSleep _delay;

    private _display = [findDisplay 49, findDisplay 313, findDisplay 46] param [
        [findDisplay 49, findDisplay 313, findDisplay 46] findIf {!isNull _x},
        displayNull
    ];

    // Already open again, or nothing to open it on.
    if (isNull _display || {!isNull findDisplay 151}) exitWith {};

    [_display] call CBA_settings_fnc_openSettingsMenu;
};
