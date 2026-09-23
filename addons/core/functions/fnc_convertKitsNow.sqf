#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Turns every kit prototype a unit carries into a kit instance on the spot. The Eden editor's
 * version of fnc_convertKits.
 *
 * The editor runs CBA's pre-init but never its frame loop, so nothing that waits a frame or sends
 * a request to the server ever comes back there. This does the whole round trip in one go:
 * allocate, fill, swap. Meant for the stand-in unit ACE Arsenal dresses in the editor, which the
 * kits tab then edits like any other.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Contents per container and kit type <HASHMAP> "slot:prototype" -> [contents, ...], see
 *    fnc_onPreLoadoutSet (default: none, every kit gets the defaults)
 *
 * Return Value:
 * None
 *
 * Example:
 * [ace_arsenal_center] call efak_core_fnc_convertKitsNow;
 *
 * Public: No
 */

params ["_unit", ["_queue", createHashMap]];

if (isNull _unit) exitWith {};

{
    _x params ["_slot", "_classes"];

    {
        private _prototype = GVAR(needsConversion) getOrDefault [toLowerANSI _x, ""];

        if (_prototype isEqualTo "") then {continue};

        private _promised = _queue getOrDefault [format ["%1:%2", _slot, toLowerANSI _prototype], []];
        private _contents = if (_promised isEqualTo []) then {-1} else {_promised deleteAt 0};
        private _instance = [_prototype] call FUNC(allocateInstance);

        if (_instance isEqualTo "") then {continue};

        [_instance, _contents] call FUNC(fillNewInstance);
        [_unit, _x, _instance, _slot] call FUNC(replaceItem);
    } forEach _classes;
} forEach [
    // Copies of the lists, so swapping items while going through them is fine.
    [LOADOUT_SLOT_UNIFORM, uniformItems _unit],
    [LOADOUT_SLOT_VEST, vestItems _unit],
    [LOADOUT_SLOT_BACKPACK, backpackItems _unit]
];
