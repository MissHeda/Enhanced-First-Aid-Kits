#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How much lighter (or heavier) a kit is than the room it takes.
 *
 * The engine knows one mass per item, which is both its weight and its room in a container. A kit
 * takes the room of its packed size, and weighs EFAK_emptyWeight from its config when it has one.
 * The difference is what the virtual load has to add to make it weigh that.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Weight minus mass, 0 for a kit without EFAK_emptyWeight <NUMBER>
 *
 * Example:
 * ["efak_MFAKPlus_7"] call efak_core_fnc_getWeightOffset;
 *
 * Public: No
 */

params ["_kitClass"];

private _key = toLowerANSI _kitClass;
private _cached = GVAR(weightOffsetCache) getOrDefault [_key, ""];

if (_cached isEqualType 0) exitWith {_cached};

private _config = configFile >> "CfgWeapons" >> _kitClass >> "EFAK_emptyWeight";
private _offset = 0;

if (isNumber _config) then {
    _offset = (getNumber _config) - ([_kitClass] call FUNC(getItemMass));
};

GVAR(weightOffsetCache) set [_key, _offset];

_offset
