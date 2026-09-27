#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Writes whatever the kits tab still has staged when ACE Arsenal closes, and ends the session.
 *
 * ACE raises this at the start of its onUnload, while it still knows which unit it was editing.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_onDisplayClosed;
 *
 * Public: No
 */

if (GVAR(active)) then {
    call FUNC(flush);
};

GVAR(active) = false;

if (GVAR(tabSlotPFH) != -1) then {
    [GVAR(tabSlotPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(tabSlotPFH) = -1;
};
GVAR(flushToken) = GVAR(flushToken) + 1;
GVAR(snapshot) = [];
GVAR(base) = createHashMap;
GVAR(pending) = createHashMap;
GVAR(classNames) = createHashMap;
GVAR(groups) = [];
GVAR(rowInfo) = createHashMap;
GVAR(kitListFocus) = false;
GVAR(contentsFocus) = false;
