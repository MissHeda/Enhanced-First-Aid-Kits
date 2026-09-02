#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Empties the open kit into the player's inventory and closes the pouch.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_unpackAllPressed;
 *
 * Public: No
 */

disableSerialization;

[ACE_player, GVAR(kitClass), GVAR(owner)] call EFUNC(core,unpackAll);

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if !(isNull _display) then {
    _display closeDisplay 2;
};
