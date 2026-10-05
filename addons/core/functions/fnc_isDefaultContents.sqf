#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether a kit holds exactly what the mission's settings give a fresh one - same items, same
 * counts, in any order.
 *
 * A saved loadout writes such a kit down as "default" rather than as a list of items, so it follows
 * the mission's default contents if those are changed later. Only kits somebody actually changed
 * keep what they held.
 *
 * A kit packed inside counts as changed: its own contents would have to be compared as well, and a
 * kit in a kit is rare enough that it is simply kept as it is.
 *
 * Arguments:
 * 0: Kit prototype or instance class <STRING>
 * 1: Contents <ARRAY> of [class, count] - a contents tree works too, the tree part is ignored
 *
 * Return Value:
 * Holds the default contents <BOOL>
 *
 * Example:
 * ["efak_IFAK", [["ACE_fieldDressing", 6]]] call efak_core_fnc_isDefaultContents;
 *
 * Public: No
 */

params ["_kitClass", "_contents"];

if !(_contents isEqualType []) exitWith {false};

private _fnc_count = {
    private _counts = createHashMap;

    {
        // Items only - a saved tree also carries the kit's name as a marker (fnc_getTreeLabel).
        if !(_x isEqualType [] && {_x isEqualTypeParams ["", 0]}) then {continue};

        _x params ["_class", "_count"];

        private _key = toLowerANSI _class;
        _counts set [_key, (_counts getOrDefault [_key, 0]) + _count];
    } forEach _this;

    _counts
};

// A packed kit - instance or prototype - makes it a changed kit, and so does an opened magazine in a
// contents tree (fnc_getContentsTree): written down as "default" it would come back full.
if ((_contents findIf {(toLowerANSI (_x select 0)) in GVAR(prototypeOf)}) > -1) exitWith {false};

// A kit with a name is no plain fresh kit either: written down as "default" it would lose the name.
if ((_contents findIf {(_x param [0, ""]) isEqualTo KIT_MARK_LABEL}) > -1) exitWith {false};
if ((_contents findIf {(_x param [3, []]) isNotEqualTo []}) > -1) exitWith {false};

private _held = _contents call _fnc_count;
private _defaults = ([_kitClass] call FUNC(getDefaultContents)) call _fnc_count;

// Hashmaps compare by reference, so the counts are compared key by key.
(count _held == count _defaults) && {(keys _held) findIf {(_held get _x) != (_defaults getOrDefault [_x, -1])} == -1}
