#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the inventory mass of an item or magazine. Result is cached.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * Mass <NUMBER>
 *
 * Example:
 * ["ACE_fieldDressing"] call efak_core_fnc_getItemMass;
 *
 * Public: Yes
 */

params ["_class"];

private _key = toLowerANSI _class;
private _cached = GVAR(massCache) getOrDefault [_key, -1];

if (_cached >= 0) exitWith {_cached};

private _config = _class call CBA_fnc_getItemConfig;
private _mass = 0;

if !(isNull _config) then {
    // Magazines and backpacks carry the mass directly, weapons and items nest it.
    if (isNumber (_config >> "mass")) then {
        _mass = getNumber (_config >> "mass");
    };
    if (isNumber (_config >> "ItemInfo" >> "mass")) then {
        _mass = getNumber (_config >> "ItemInfo" >> "mass");
    };
    if (isNumber (_config >> "WeaponSlotsInfo" >> "mass")) then {
        _mass = getNumber (_config >> "WeaponSlotsInfo" >> "mass");
    };
    if (isNumber (_config >> "maximumLoad")) then {
        // Backpacks: their own mass plus what they could carry would be a lie,
        // so only count the empty bag.
        _mass = _mass max 1;
    };
};

_mass = _mass max 0;
GVAR(massCache) set [_key, _mass];

_mass
