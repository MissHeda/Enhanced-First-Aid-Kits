#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Cleans up after the pouch dialog.
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
