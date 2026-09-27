#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows the kits tab under the backpack only while the unit carries a kit, and moves ACE's tabs
 * below it down a slot to make room - or back up when the last kit is gone.
 *
 * ACE's tab positions come from its config. The first time a tab is touched its config position is
 * remembered, so moving it is always relative to where ACE put it and never drifts.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_updateTabSlot;
 *
 * Public: No
 */

params ["_display"];

if (isNull _display) exitWith {};

private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

// An open tab stays until the player leaves it, even if its last kit was just taken out.
// Runs twice a second while the arsenal is open, so it asks the cheap question.
// In the editor nothing would ever call this again once a kit is added (no frame loop), so the tab
// just stays - it says so itself when there is no kit.
private _shown = GVAR(active) || {is3DEN} || {[_center, true] call EFUNC(core,hasKits)};

if (_shown isEqualTo GVAR(tabSlotShown)) exitWith {};

GVAR(tabSlotShown) = _shown;

private _offset = [0, 10 * GRID_H] select _shown;

{
    private _ctrl = _display displayCtrl _x;
    if (isNull _ctrl) then {continue};

    (ctrlPosition _ctrl) params ["_left", "_top", "_width", "_height"];

    private _configTop = GVAR(tabConfigTop) getOrDefault [_x, -1];
    if (_configTop < 0) then {
        _configTop = _top;
        GVAR(tabConfigTop) set [_x, _configTop];
    };

    _ctrl ctrlSetPosition [_left, _configTop + _offset, _width, _height];
    _ctrl ctrlCommit 0;
} forEach [ACE_TABS_BELOW_BACKPACK];

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlShow _shown;
    _ctrl ctrlCommit 0;
} forEach [IDC_EFAK_TAB, IDC_EFAK_TAB_BACKGROUND];
