#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many of an item a kit may hold at most when its type is set to be packed only up to the
 * default contents: the amount the defaults hold, 0 for anything not in them.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 * 1: Item class <STRING>
 *
 * Return Value:
 * Most the kit may hold, -1 for no limit <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7", "ACE_morphine"] call efak_core_fnc_getPackLimit;
 *
 * Public: Yes
 */

params ["_kitClass", "_itemClass"];

if !([_kitClass, "limitToDefaults", false] call FUNC(getKitSetting)) exitWith {-1};

[[_kitClass] call FUNC(getDefaultContents), _itemClass] call FUNC(countItem)
