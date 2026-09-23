#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Returns what a row of the contents list shows for an item. Cached for the arsenal session - the
 * list can hold every item the arsenal offers and is redrawn on every kit switch.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * 0: Class <STRING>
 * 1: Display name <STRING>
 * 2: Picture <STRING>
 * 3: Mass <NUMBER>
 *
 * Example:
 * ["ACE_fieldDressing"] call efak_arsenal_fnc_getItemInfo;
 *
 * Public: No
 */

params ["_class"];

GVAR(itemInfo) getOrDefaultCall [toLowerANSI _class, {
    [
        _class,
        [_class] call EFUNC(core,getItemName),
        [_class] call EFUNC(core,getItemPicture),
        [_class] call EFUNC(core,getItemMass)
    ]
}, true]
