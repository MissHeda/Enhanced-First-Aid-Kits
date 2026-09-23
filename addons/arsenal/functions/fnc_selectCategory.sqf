#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Switches the kit contents list to one of ACE's category buttons and moves the highlight there,
 * the way ACE does for its own right panel.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 * 1: Button IDC <NUMBER>
 * 2: Picked by the player (true) or by the tab itself (false) <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001, 38, true] call efak_arsenal_fnc_selectCategory;
 *
 * Public: No
 */

params ["_display", "_idc", ["_byPlayer", false]];

if (!GVAR(active) || {isNull _display}) exitWith {};

{
    private _background = _display displayCtrl (_x - 1);
    _background ctrlSetFade parseNumber (_x != _idc);
    _background ctrlCommit FADE_DELAY;
} forEach GVAR(categoryIdcs);

GVAR(category) = _idc;

[_display] call FUNC(fillContents);

// If this ACE version kept its own click handler on the button after all, it has just shown ACE's
// right panel again. Put the tab back on top once it is done.
if (is3DEN) then {
    // The editor has no CBA frame loop, but the engine's own frame event still runs.
    addMissionEventHandler ["EachFrame", {
        removeMissionEventHandler ["EachFrame", _thisEventHandler];
        [_thisArgs select 0] call FUNC(applyVisibility);
    }, [_display]];
} else {
    [{
        [_this] call FUNC(applyVisibility);
    }, _display] call CBA_fnc_execNextFrame;
};
