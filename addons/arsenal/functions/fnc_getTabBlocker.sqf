#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Tells whether the kits tab can be used in the open arsenal, and if not, why.
 *
 * Kit contents live on instance classes the server hands out to the local player. In the editor
 * the arsenal dresses a temporary copy of the unit, and on any other unit (Zeus, the arsenal
 * module) nothing ever turns the kits it carries into instances - there is nothing to edit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Reason the tab is unavailable, "" when it can be used <STRING>
 *
 * Example:
 * call efak_arsenal_fnc_getTabBlocker;
 *
 * Public: No
 */

// What the tab may change is decided per kit type (efak_core_fnc_getArsenalEditing). Even a kit that
// may not be changed at all can still be looked into, so none of that closes the tab.

private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

// In the Eden editor the arsenal dresses a stand-in for the unit being edited. There is no player
// to compare it with, and every unit of the mission may be set up.
if (is3DEN) exitWith {
    ["", (["tabDisabledUnit"] call FUNC(getText))] select (isNull _center || {!(_center isKindOf "CAManBase")})
};

if (isNull _center || {_center isNotEqualTo ACE_player} || {!local _center}) exitWith {
    (["tabDisabledUnit"] call FUNC(getText))
};

""
