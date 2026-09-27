#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Cleans up after the kit window. Every move was applied the moment it was made, so there is
 * nothing left to apply or to throw away - only the window's own state to reset.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onPouchClosed;
 *
 * Public: No
 */

if !(isNil {GVAR(refreshHandler)}) then {
    [QEGVAR(core,contentsChanged), GVAR(refreshHandler)] call CBA_fnc_removeEventHandler;
    GVAR(refreshHandler) = nil;
};

uiNamespace setVariable [QGVAR(display), displayNull];
GVAR(kitClass) = "";
GVAR(owner) = objNull;
GVAR(patient) = objNull;
GVAR(crate) = objNull;
GVAR(baseline) = createHashMap;

// The next window starts a pile of its own.
GVAR(groundHolder) = objNull;

GVAR(kitChoices) = [];
GVAR(removedKits) = createHashMap;

// Whatever came out of a kit is its own business once the window is closed.
GVAR(kitStart) = createHashMap;
GVAR(kitStartCharges) = createHashMap;

call FUNC(onDragEnd);

if (GVAR(listsPFH) >= 0) then {
    [GVAR(listsPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(listsPFH) = -1;
};
GVAR(message) = "";
GVAR(applying) = false;
