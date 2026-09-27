#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the contents a freshly spawned kit of this type starts with.
 *
 * The default contents obey the kit's own rules like everything else: an item its blacklist or
 * item filter rejects is left out, so a mission that blacklists morphine does not hand it out in
 * every new kit. Kits packed inside (the AFAK's IFAK) stay whatever the nesting setting says - the
 * defaults are where the mission deliberately put them.
 *
 * Parsing and checking a whole list is too slow for how often this is asked, so the answer is kept
 * per kit type until the setting or the rules change.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Contents <ARRAY> of [class, count], a copy the caller may change
 *
 * Example:
 * ["efak_IFAK"] call efak_core_fnc_getDefaultContents;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {[]};

private _id = _kit select KIT_ID;

private _setting = missionNamespace getVariable [
    format [QGVAR(kit_%1_defaultContents), _id],
    _kit select KIT_DEFAULTS
];

(GVAR(defaultsCache) getOrDefault [_id, []]) params [["_cachedSetting", ""], ["_cachedStamp", -1], ["_cached", []]];

if (_cachedSetting isEqualTo _setting && {_cachedStamp isEqualTo GVAR(rulesStamp)}) exitWith {+_cached};

private _prototype = _kit select KIT_ITEM;

private _contents = ([_setting] call FUNC(parseContents)) select {
    ([_prototype, _x select 0] call FUNC(isItemAllowed)) select 0
};

GVAR(defaultsCache) set [_id, [_setting, GVAR(rulesStamp), _contents]];

+_contents
