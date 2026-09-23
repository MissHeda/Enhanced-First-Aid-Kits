#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Lists everything the open arsenal offers that EFAK's rules let into a kit type.
 *
 * Capacity and amounts are left out on purpose: the tab stages its edits, and EFAK's own checks
 * read the stored contents. The tab measures space and the default contents limit against what it
 * has staged instead (see adjustContents).
 *
 * So is what the arsenal may change about the kit: a kit that only lets items out, or none at all,
 * still lists what could go in, greyed with the reason (see fillContents).
 *
 * Checking every item the arsenal offers is not cheap, so the result is kept per kit type for the
 * session, and only worked out again when the arsenal's item list is replaced or that kit type's
 * rules change.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * 0: Items sorted by name <ARRAY> of [lowercase name, class]
 * 1: Lowercase class -> true <HASHMAP>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_arsenal_fnc_getCandidates;
 *
 * Public: No
 */

params ["_kitClass"];

// ACE builds a new flat item list whenever the arsenal's items change, so a different list means
// every cached answer is stale.
private _flat = missionNamespace getVariable [QACEGVAR(arsenal,virtualItemsFlat), createHashMap];

if !(_flat isEqualRef GVAR(availableSource)) then {
    GVAR(availableSource) = _flat;
    GVAR(available) = createHashMap;
    GVAR(candidates) = createHashMap;

    {
        GVAR(available) set [toLowerANSI _x, true];
    } forEach (if (_flat isEqualType createHashMap) then {keys _flat} else {_flat});
};

// EFAK's rules can change while the arsenal is open too. Core bumps its rules stamp whenever an
// item filter, whitelist or blacklist changes; nesting and the default contents limit are read
// here. The default contents belong in the stamp as well: with the limit on, whatever they do not
// hold stays out.
private _stamp = [
    EGVAR(core,rulesStamp),
    missionNamespace getVariable [QEGVAR(core,allowNesting), false],
    [_kitClass, "limitToDefaults", false] call EFUNC(core,getKitSetting),
    [_kitClass, "defaultContents", ""] call EFUNC(core,getKitSetting)
];

private _key = toLowerANSI ([_kitClass] call EFUNC(core,getPrototype));

(GVAR(candidates) getOrDefault [_key, []]) params [["_cachedStamp", []], ["_cachedList", []], ["_cachedLookup", createHashMap]];

if (_cachedStamp isEqualTo _stamp) exitWith {[_cachedList, _cachedLookup]};

private _list = [];
private _lookup = createHashMap;

{
    if !(_x isEqualType "") then {continue};
    if !(([_kitClass, _x, 0, true] call EFUNC(core,canPackItem)) select 0) then {continue};

    private _item = [_x] call FUNC(getItemInfo);

    _list pushBack [toLower (_item select 1), _item select 0];
    _lookup set [toLowerANSI _x, true];
} forEach (if (_flat isEqualType createHashMap) then {keys _flat} else {_flat});

_list sort true;

GVAR(candidates) set [_key, [_stamp, _list, _lookup]];

[_list, _lookup]
