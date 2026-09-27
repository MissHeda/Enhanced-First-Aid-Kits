#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Marks a kit to come back with the mission's default contents whenever it comes out of a saved
 * loadout - an arsenal load, a respawn with the gear you died with, a copied loadout.
 *
 * What the kit holds right now is not touched: the player can still take things out and put
 * things in. Only what a saved loadout writes down for it changes, from a list of items to
 * "default". That is what makes a change to the default contents reach every kit set up this way,
 * however long ago its loadout was saved.
 *
 * Replicated like the contents, so it follows the kit to whoever carries it.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Follow the default contents <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", true] call efak_core_fnc_setFollowDefaults;
 *
 * Public: Yes
 */

params [["_class", "", [""]], ["_follow", true, [true]]];

// Prototypes have no identity to hang a flag on.
if !([_class] call FUNC(isKit)) exitWith {};
if ((toLowerANSI _class) in GVAR(needsConversion)) exitWith {};

// Nothing to tell anybody.
if (((toLowerANSI _class) in GVAR(followDefaults)) isEqualTo _follow) exitWith {};

[QGVAR(followDefaultsChanged), [_class, _follow]] call CBA_fnc_globalEvent;
