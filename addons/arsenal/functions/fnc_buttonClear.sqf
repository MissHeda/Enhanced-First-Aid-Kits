#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Empties every kit of the selected type, like ACE's "remove all" does for a container. The rows
 * stay where they are, so whatever was taken out can be put straight back.
 *
 * Emptying is only taking out, so a "Remove only" kit may be cleared. A kit the mission keeps as it
 * is stays untouched.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_buttonClear;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active) || {isNull _display} || {GVAR(locked)}) exitWith {};

private _changed = false;

{
    if (([_x] call EFUNC(core,getArsenalEditing)) == EDIT_NOTHING) then {continue};

    private _contents = GVAR(pending) get toLowerANSI _x;

    if (!isNil "_contents" && {_contents isNotEqualTo []}) then {
        _contents resize 0;
        _changed = true;
    };
} forEach (call FUNC(getSelectedKits));

if (_changed) then {
    call FUNC(queueFlush);
};

[_display] call FUNC(updateContents);
