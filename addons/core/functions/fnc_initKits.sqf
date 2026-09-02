#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads the kit registry from config and builds the runtime lookup tables.
 * Called once from preInit, before any setting is registered.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_initKits;
 *
 * Public: No
 */

GVAR(kits) = createHashMap;             // lowercase prototype class -> kit data
GVAR(kitList) = [];                     // prototype classes, registry order
GVAR(prototypeOf) = createHashMap;      // lowercase kit class (any) -> prototype class
GVAR(needsConversion) = createHashMap;  // lowercase prototype/legacy class -> prototype class

private _cfgWeapons = configFile >> "CfgWeapons";

{
    private _kitId = configName _x;
    private _item = getText (_x >> "item");

    if !(isClass (_cfgWeapons >> _item)) then {
        WARNING_2("Kit '%1' references unknown item '%2' - skipped.",_kitId,_item);
        continue;
    };

    private _instances = (getNumber (_x >> "instances")) max 1;

    GVAR(kits) set [toLowerANSI _item, [
        _kitId,
        _item,
        getText (_x >> "icon"),
        getText (_x >> "iconContents"),
        (getNumber (_x >> "capacity")) max 1,
        _instances,
        getText (_x >> "defaultContents"),
        getText (_cfgWeapons >> _item >> "displayName")
    ]];

    GVAR(kitList) pushBack _item;

    // The prototype itself and every legacy classname have to be converted into
    // a real instance as soon as a player carries them.
    GVAR(prototypeOf) set [toLowerANSI _item, _item];
    GVAR(needsConversion) set [toLowerANSI _item, _item];

    {
        GVAR(prototypeOf) set [toLowerANSI _x, _item];
        GVAR(needsConversion) set [toLowerANSI _x, _item];
    } forEach (getArray (_x >> "legacyClasses"));

    // Instances are already unique - they only need to resolve back to their kit.
    for "_i" from 1 to _instances do {
        GVAR(prototypeOf) set [toLowerANSI format ["%1_%2", _item, _i], _item];
    };
} forEach ("true" configClasses (configFile >> "EFAK_Kits"));

TRACE_1("kits registered",GVAR(kitList));
