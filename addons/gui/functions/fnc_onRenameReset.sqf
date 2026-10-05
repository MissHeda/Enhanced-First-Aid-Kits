#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The arrow at the end of the name box: the kit gets its usual name back. The press on it usually
 * ends the typing first (and keeps what was typed) - the kit that was just named is the one it means
 * then.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onRenameReset;
 *
 * Public: No
 */

private _kitClass = GVAR(renaming);

if (_kitClass isNotEqualTo "") then {
    [false] call FUNC(onRenameDone);
} else {
    if (diag_tickTime - GVAR(renameClosedAt) < 0.3) then {_kitClass = GVAR(lastRenamed)};
};

if (_kitClass isEqualTo "") exitWith {};

[_kitClass, ""] call EFUNC(core,setKitLabel);

[{call FUNC(refreshPouch)}] call CBA_fnc_execNextFrame;
