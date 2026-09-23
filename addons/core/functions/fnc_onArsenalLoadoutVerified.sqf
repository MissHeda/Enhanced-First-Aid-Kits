#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * ace_arsenal_loadoutVerified handler. ACE Arsenal checks every loadout it
 * lists or imports against the items it offers, and kit instances are never
 * offered (ace_arsenal_hide), so an exported loadout loses all of its kits on
 * import. This puts the prototype back wherever EFAK's extended info says a kit
 * was, as long as the arsenal offers that kit, and reports kit contents the
 * arsenal does not offer so the loadout shows up as incomplete.
 *
 * The contents themselves are filtered when the loadout is applied (see
 * fnc_onPreLoadoutSet), not here: the extended info ACE passes can be the same
 * hashmap as the stored loadout.
 *
 * Arguments:
 * 0: Verified loadout, changed in place <ARRAY>
 * 1: Extended info <HASHMAP>
 * 2: Items that do not exist <ARRAY>
 * 3: Items the arsenal does not offer, changed in place <ARRAY>
 * 4: Extended info the arsenal could not use <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["ace_arsenal_loadoutVerified", {_this call efak_core_fnc_onArsenalLoadoutVerified}] call CBA_fnc_addEventHandler;
 *
 * Public: No
 */

params ["_loadout", "_extendedInfo", "", "_unavailable"];

// Only meaningful while an arsenal is open; without its item list there is nothing to check against.
private _available = missionNamespace getVariable QACEGVAR(arsenal,virtualItemsFlat);

if (isNil "_available" || {!(_loadout isEqualType [])} || {count _loadout != 10}) exitWith {};

private _entries = [_extendedInfo] call FUNC(parseLoadoutKits);

if (_entries isEqualTo []) exitWith {};

private _removed = [];

{
    _x params ["_slot", "_index", "_prototype", "_contents"];

    private _container = _loadout select _slot;

    if !(_container isEqualTypeArray ["", []]) then {continue};

    private _item = (_container select 1) param [_index, []];

    if !(_item isEqualTypeArray ["", 0]) then {continue};

    // Blanked by the check: put the kit back, if it was one of ours and the arsenal has it.
    if ((_item select 0) isEqualTo "") then {
        private _dropped = _unavailable findIf {
            (_x isEqualType "") &&
            {(GVAR(prototypeOf) getOrDefault [toLowerANSI _x, ""]) isEqualTo _prototype} &&
            {!((toLowerANSI _x) in GVAR(needsConversion))}
        };

        if (_dropped == -1 || {!(_prototype in _available)}) then {continue};

        _item set [0, _prototype];
        _unavailable deleteAt _dropped;
    };

    // A different item at this position means the extended info does not describe this array.
    if ((toLowerANSI (_item select 0)) isNotEqualTo (toLowerANSI _prototype)) then {continue};

    [_prototype, _contents, _available, _removed] call FUNC(filterContentsTree);
} forEach _entries;

{
    _unavailable pushBackUnique _x;
} forEach _removed;
