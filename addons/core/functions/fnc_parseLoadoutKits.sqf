#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads the kit entries EFAK stored in a CBA extended loadout (format in
 * fnc_getLoadoutKits). The data may come from a profile, the clipboard or
 * another modpack, so anything that does not have the expected shape is
 * skipped. Contents trees are only checked for their type here; the server
 * checks what is inside them before any kit is filled.
 *
 * Arguments:
 * 0: Extended info <HASHMAP or ARRAY of [key, value] pairs>
 *
 * Return Value:
 * Entries [[slot, itemIndex, prototype, contents], ...], prototypes in config case <ARRAY>
 *
 * Example:
 * [(player call CBA_fnc_getLoadout) select 1] call efak_core_fnc_parseLoadoutKits;
 *
 * Public: Yes
 */

params [["_extendedInfo", createHashMap, [createHashMap, []]]];

// A loadout that went through str and parseSimpleArray holds its extended info as pairs.
if (_extendedInfo isEqualType []) then {
    private _pairs = _extendedInfo;
    _extendedInfo = createHashMap;

    {
        if (_x isEqualType [] && {_x isEqualTypeParams ["", []]} && {(_x select 0) isEqualTo QGVAR(loadoutKits)}) exitWith {
            _extendedInfo set [QGVAR(loadoutKits), _x select 1];
        };
    } forEach _pairs;
};

private _value = _extendedInfo getOrDefault [QGVAR(loadoutKits), []];

if !(_value isEqualType [] && {_value isEqualTypeArray [0, []]}) exitWith {[]};

_value params ["_version", "_entries"];

if (_version != LOADOUT_KITS_VERSION) exitWith {
    WARNING_2("Ignoring kit contents saved in format %1, this version reads format %2.",_version,LOADOUT_KITS_VERSION);
    []
};

private _result = [];

{
    if !(_x isEqualType [] && {_x isEqualTypeParams [0, 0, ""]} && {count _x == 4}) then {continue};

    _x params ["_slot", "_index", "_class", "_contents"];

    // Either a contents tree or the marker for a kit that follows the defaults.
    if !(_contents isEqualType [] || {_contents isEqualTo LOADOUT_KIT_DEFAULT}) then {continue};

    if !(_slot in [LOADOUT_SLOT_UNIFORM, LOADOUT_SLOT_VEST, LOADOUT_SLOT_BACKPACK]) then {continue};
    if (_index < 0) then {continue};

    private _prototype = GVAR(prototypeOf) getOrDefault [toLowerANSI _class, ""];

    // A kit type this modpack does not know.
    if (_prototype isEqualTo "") then {continue};

    _result pushBack [_slot, floor _index, _prototype, _contents];
} forEach _entries;

_result
