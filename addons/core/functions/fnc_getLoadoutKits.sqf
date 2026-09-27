#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Collects the contents of every kit in a loadout array, one entry per kit, in
 * the format EFAK keeps in a CBA extended loadout.
 *
 * Extended loadout format
 * -----------------------
 * CBA_fnc_getLoadout returns [loadoutArray, extendedInfo]. EFAK adds one key to
 * extendedInfo, and only when the loadout holds at least one kit whose contents
 * are known:
 *
 *   "efak_core_loadoutKits" -> [version, entries]
 *
 *   version   LOADOUT_KITS_VERSION (currently 1). Other versions are ignored.
 *   entries   [[slot, itemIndex, prototype, contents], ...], one entry per kit
 *     slot       3 uniform, 4 vest, 5 backpack (index into loadoutArray)
 *     itemIndex  index of the kit's [class, count] pair in loadoutArray#slot#1,
 *                as it was when the loadout was read. A pair with count 2 gets
 *                two entries with the same index.
 *     prototype  kit prototype class, e.g. "efak_IFAK"
 *     contents   contents tree, see fnc_getContentsTree - or LOADOUT_KIT_DEFAULT
 *                ("default") for a kit marked to follow the default contents, see
 *                fnc_setFollowDefaults
 *
 * Only strings, numbers and arrays are used, so the value survives str and
 * parseSimpleArray (export and import), profileNamespace, the 3DEN attribute
 * and the network. Kit instance ids are not part of it: the loadout array may
 * still hold them, but applying the loadout replaces every one with its
 * prototype and a fresh id (see fnc_onPreLoadoutSet).
 *
 * Kits without an entry get the default contents of the mission the loadout is
 * applied in. That covers prototypes nobody filled yet - and every
 * kit that still holds exactly its default contents when the loadout is read. A
 * kit nobody touched is "a fresh kit", not a snapshot of whatever the defaults
 * were on the day it was saved, so changing the defaults later reaches old
 * loadouts too. Kits somebody changed keep what they held.
 *
 * The contents are only a wish either way: the server checks them against its own
 * rules - capacity, allowed items, blacklist, nesting - before anything goes in
 * (fnc_restoreContents). A loadout saved where a kit held 2000 does not carry
 * 2000 onto a server where it holds 30.
 *
 * Arguments:
 * 0: Unit the loadout belongs to, objNull if none <OBJECT>
 * 1: Loadout <ARRAY> in getUnitLoadout format
 *
 * Return Value:
 * Entries <ARRAY>
 *
 * Example:
 * [player, getUnitLoadout player] call efak_core_fnc_getLoadoutKits;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_loadout", [], [[]]]];

if (count _loadout != 10) exitWith {[]};

// A prototype the unit already asked an instance for, or that a loadout just brought along, has
// contents on the way. Reading the loadout in that moment (a save right after a load, a death
// right after a respawn) must not turn them back into the defaults.
private _pending = createHashMap;
private _queue = createHashMap;

if (!isNull _unit && {local _unit}) then {
    _pending = _unit getVariable [QGVAR(pendingConversions), createHashMap];

    (_unit getVariable [QGVAR(restoreQueue), []]) params [["_expires", -1], ["_restoreQueue", createHashMap]];

    if (_expires >= 0 && {CBA_missionTime <= _expires}) then {
        _queue = _restoreQueue;
    };

    // A unit in the Eden editor carries prototypes only; what they hold is in its attribute.
    if (is3DEN && {_unit in (all3DENEntities select 0)}) then {
        _queue = [(_unit get3DENAttribute QGVAR(kitContents)) param [0, ""]] call FUNC(parseEditorKits);
    };
};

private _taken = createHashMap;
private _entries = [];

{
    private _slot = _x;
    private _container = _loadout select _slot;

    if !(_container isEqualTypeArray ["", []]) then {continue};

    {
        if !(_x isEqualTypeArray ["", 0]) then {continue};

        _x params ["_class", "_count"];

        private _key = toLowerANSI _class;
        private _prototype = GVAR(prototypeOf) getOrDefault [_key, ""];

        if (_prototype isEqualTo "") then {continue};

        if (_key in GVAR(needsConversion)) then {
            // Requests already on their way come first, then what is still queued. Kits of one
            // type in one container are interchangeable, so the order only has to be consistent.
            private _slotKey = format ["%1:%2", _slot, _key];
            private _promised = ((_pending getOrDefault [_slotKey, []]) apply {_x select 1}) +
                (_queue getOrDefault [format ["%1:%2", _slot, toLowerANSI _prototype], []]);
            private _first = _taken getOrDefault [_slotKey, 0];

            for "_i" from _first to (_first + _count - 1) do {
                private _contents = _promised param [_i, -1];

                switch (true) do {
                    case (_contents isEqualTo LOADOUT_KIT_DEFAULT): {
                        _entries pushBack [_slot, _forEachIndex, _prototype, LOADOUT_KIT_DEFAULT];
                    };
                    case (_contents isEqualType [] && {!([_prototype, _contents] call FUNC(isDefaultContents))}): {
                        _entries pushBack [_slot, _forEachIndex, _prototype, +_contents];
                    };
                };
            };

            _taken set [_slotKey, _first + _count];
        } else {
            // Marked to follow the defaults: written down as such, whatever it holds right now.
            if (_key in GVAR(followDefaults)) then {
                for "_i" from 1 to _count do {
                    _entries pushBack [_slot, _forEachIndex, _prototype, LOADOUT_KIT_DEFAULT];
                };
                continue;
            };

            private _tree = [_class] call FUNC(getContentsTree);

            // Untouched: written down as a fresh kit, see above.
            if ([_prototype, _tree] call FUNC(isDefaultContents)) then {continue};

            for "_i" from 1 to _count do {
                _entries pushBack [_slot, _forEachIndex, _prototype, +_tree];
            };
        };
    } forEach (_container select 1);
} forEach [LOADOUT_SLOT_UNIFORM, LOADOUT_SLOT_VEST, LOADOUT_SLOT_BACKPACK];

_entries
