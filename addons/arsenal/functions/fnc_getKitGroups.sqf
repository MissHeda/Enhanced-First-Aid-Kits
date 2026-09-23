#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Sorts the kits a unit carries by type. Kits that are still prototypes are only
 * counted: they have no contents of their own until the server has given them an instance.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Groups in kit registry order <ARRAY> of
 * - 0: Prototype class <STRING>
 * - 1: Instance classes, each once <ARRAY>
 * - 2: Kits still being prepared <NUMBER>
 *
 * Example:
 * [player] call efak_arsenal_fnc_getKitGroups;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {[]};

// [registry position, instance id, lowercase class, class]
private _kits = [];

// Which container each instance sits in, for the row label.
private _where = createHashMap;
{
    _x params ["_list", "_container"];
    {
        _where set [toLowerANSI _x, _container];
    } forEach _list;
} forEach [[uniformItems _unit, "uniform"], [vestItems _unit, "vest"], [backpackItems _unit, "backpack"]];
private _seen = createHashMap;
// lowercase prototype -> kits still waiting for their instance
private _preparing = createHashMap;

{
    private _key = toLowerANSI _x;
    private _prototype = EGVAR(core,prototypeOf) getOrDefault [_key, ""];

    if (_prototype isEqualTo "") then {continue};

    if (_key in EGVAR(core,needsConversion)) then {
        _preparing set [toLowerANSI _prototype, (_preparing getOrDefault [toLowerANSI _prototype, 0]) + 1];
        continue;
    };

    // Contents belong to the class, so a copied instance is still the same kit to edit.
    if (_key in _seen) then {continue};
    _seen set [_key, true];

    _kits pushBack [
        EGVAR(core,kitList) find _prototype,
        getNumber (configFile >> "CfgWeapons" >> _x >> "EFAK_instanceId"),
        _key,
        _x,
        _where getOrDefault [_key, ""]
    ];
} forEach (items _unit);

// Registry order, then instance id, keeps the list from reshuffling whenever a kit is added.
_kits sort true;

// Every kit is its own group of one, so it is configured on its own.
private _groups = _kits apply {[_x select 3, [_x select 3], 0, _x select 4]};

{
    private _count = _preparing getOrDefault [toLowerANSI _x, 0];
    if (_count > 0) then {
        _groups pushBack [_x, [], _count, ""];
    };
} forEach EGVAR(core,kitList);

_groups
