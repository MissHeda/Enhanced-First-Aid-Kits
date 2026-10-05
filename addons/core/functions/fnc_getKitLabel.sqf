#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The name a player gave one kit - "Ammo spare", "Team 2 bag" - or "" when it has none.
 *
 * The engine knows one display name per class, so the name lives in a table of its own, on the
 * kit's instance class like its contents (setKitLabel). The kit window, its quick access window,
 * the ACE menu and the arsenal's kits tab show it.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 *
 * Return Value:
 * Name <STRING>
 *
 * Example:
 * ["eup_UtilityPouch_7"] call efak_core_fnc_getKitLabel;
 *
 * Public: Yes
 */

params [["_kitClass", "", [""]]];

GVAR(labels) getOrDefault [toLowerANSI _kitClass, ""]
