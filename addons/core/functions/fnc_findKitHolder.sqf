#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Works out who or what is holding a kit. Opening a kit from the inventory does not say where it
 * came from, and it may well be lying in the crate the player has open rather than on them.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Object to try first <OBJECT> (default: objNull)
 *
 * Return Value:
 * Holder <OBJECT>, objNull when nothing has it
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_findKitHolder;
 *
 * Public: No
 */

params ["_kitClass", ["_hint", objNull]];

private _candidates = [_hint, ACE_player, GVAR(lastContainer), objectParent ACE_player];

_candidates append (nearestObjects [ACE_player, ["ReammoBox_F"], 4]);

private _result = objNull;

{
    if ([_x, _kitClass] call FUNC(holderHasKit)) exitWith {_result = _x};
} forEach _candidates;

_result
