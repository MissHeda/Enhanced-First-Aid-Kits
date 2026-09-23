#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Takes in a kit contents change made somewhere else while the kits tab is open - the server
 * filling a freshly converted kit, or another player using something out of it.
 *
 * A kit the tab has not touched simply takes the new contents. A kit with staged edits keeps them,
 * replayed on top of the new contents under the kit's rules (see replayChanges). Where an edit no
 * longer fits - no room left, or the default contents limit reached - the other change wins and
 * that part of the staged edits is dropped.
 *
 * The tab's own writes come back through here too and are ignored.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents <ARRAY> of [class, count]
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", [["ACE_morphine", 2]]] call efak_arsenal_fnc_onContentsChanged;
 *
 * Public: No
 */

params ["_class", ["_contents", []]];

if (GVAR(writing) || {!GVAR(active)}) exitWith {};

private _key = toLowerANSI _class;
private _pending = GVAR(pending) get _key;

if (isNil "_pending") exitWith {};

private _base = GVAR(base) getOrDefault [_key, []];
private _stored = +_contents;

if (_pending isEqualTo _base) then {
    GVAR(pending) set [_key, +_stored];
} else {
    // What the tab changed, item by item, applied to the new contents.
    GVAR(pending) set [_key, ([_class, _base, _pending, _stored] call FUNC(replayChanges)) select 0];
};

GVAR(base) set [_key, _stored];

// Only the kits on screen need redrawing.
if ((call FUNC(getSelectedKits)) findIf {toLowerANSI _x isEqualTo _key} != -1) then {
    [findDisplay IDD_ACE_ARSENAL] call FUNC(fillContents);
};
