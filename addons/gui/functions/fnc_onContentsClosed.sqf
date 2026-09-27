#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The contents window closed: it stops listening for changes to the kit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_onContentsClosed;
 *
 * Public: No
 */

if (GVAR(contentsHandler) >= 0) then {
    [QEGVAR(core,contentsChanged), GVAR(contentsHandler)] call CBA_fnc_removeEventHandler;
    GVAR(contentsHandler) = -1;
};
