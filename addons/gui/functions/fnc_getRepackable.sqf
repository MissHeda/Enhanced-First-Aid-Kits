#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * How many of an item came out of the kit being shown since the window was opened, and may go back
 * in even when packing into this type of kit is switched off. A wrong click is not final until the
 * window closes; opened again, the kit is what it is.
 *
 * Counted against the kit as it was the first time this window showed it, so switching to another
 * kit and back does not forget it.
 *
 * Arguments:
 * 0: Contents to count against <ARRAY> of [class, count]
 * 1: Item class <STRING>
 *
 * Return Value:
 * How many may go back <NUMBER>
 *
 * Example:
 * [[], "ACE_morphine"] call efak_gui_fnc_getRepackable;
 *
 * Public: No
 */

params ["_contents", "_class"];

private _start = GVAR(kitStart) getOrDefault [toLowerANSI GVAR(kitClass), []];

(([_start, _class] call EFUNC(core,countItem)) - ([_contents, _class] call EFUNC(core,countItem))) max 0
