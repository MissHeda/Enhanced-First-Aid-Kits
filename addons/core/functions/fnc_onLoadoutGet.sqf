#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * CBA_loadoutGet handler. Writes the contents of every kit in the loadout into
 * the extended info, so they travel with it: ACE Arsenal saves, default and
 * shared loadouts, export, ACE respawn gear and anything else built on
 * CBA_fnc_getLoadout. Format in fnc_getLoadoutKits.
 *
 * The loadout array itself is left alone. Other handlers and callers read it,
 * ACE Arsenal replaces instances with their prototype when it saves anyway, and
 * whatever applies it again goes through fnc_onPreLoadoutSet.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Loadout <ARRAY>
 * 2: Extended info <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["CBA_loadoutGet", {_this call efak_core_fnc_onLoadoutGet}] call CBA_fnc_addEventHandler;
 *
 * Public: No
 */

params ["_unit", "_loadout", "_extendedInfo"];

if !(_extendedInfo isEqualType createHashMap) exitWith {};

private _entries = [_unit, _loadout] call FUNC(getLoadoutKits);

// No key at all rather than an empty one: most loadouts in a mission carry no kit with known contents.
if (_entries isEqualTo []) exitWith {};

_extendedInfo set [QGVAR(loadoutKits), [LOADOUT_KITS_VERSION, _entries]];
