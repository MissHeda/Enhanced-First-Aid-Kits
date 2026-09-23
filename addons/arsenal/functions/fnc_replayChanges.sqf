#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Replays what the tab changed on a kit - the difference between two contents lists - on top of a
 * third list, keeping to the kit's rules the whole way (see adjustContents).
 *
 * Writing replays the staged edits on what the kit held, so nothing the rules forbid is ever
 * stored, whatever the list on screen says. A change made somewhere else replays them on the new
 * contents instead.
 *
 * Removals go first, so whatever they free up is there for the additions. Resetting the kit to its
 * default contents is taken as it is, not as a pile of additions: "Remove only" allows it by name,
 * and the defaults are the mission's own choice, a kit packed inside included.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents the edits started from <ARRAY> of [class, count]
 * 2: Contents with the edits <ARRAY> of [class, count]
 * 3: Contents to replay the edits on <ARRAY> of [class, count]
 *
 * Return Value:
 * 0: Result, a new list <ARRAY> of [class, count]
 * 1: Every edit made it <BOOL>
 *
 * Example:
 * ["efak_IFAK_7", _base, _pending, _base] call efak_arsenal_fnc_replayChanges;
 *
 * Public: No
 */

params ["_kit", "_from", "_to", "_onto"];

// lowercase class -> [class as written, count]
private _fnc_counts = {
    private _map = createHashMap;
    {
        _x params ["_item", "_count"];
        private _entry = _map getOrDefaultCall [toLowerANSI _item, {[_item, 0]}, true];
        _entry set [1, (_entry select 1) + _count];
    } forEach _this;
    _map
};

private _before = _from call _fnc_counts;
private _after = _to call _fnc_counts;
private _reset = false;

// Only when the edits go back onto the list they were made against (a flush). Merged onto contents
// somebody else changed in the meantime, "equals the defaults" says nothing about a reset any more -
// it would throw away the other change, a bandage a medic just used out of this kit included.
if (_onto isEqualTo _from && {([_kit] call EFUNC(core,getArsenalEditing)) != EDIT_NOTHING}) then {
    private _defaults = ([_kit] call EFUNC(core,getDefaultContents)) call _fnc_counts;

    // Hashmaps compare by reference, so the counts are compared key by key.
    _reset = count _defaults == count _after &&
        {(keys _after) findIf {((_after get _x) select 1) != ((_defaults getOrDefault [_x, ["", -1]]) select 1)} == -1};
};

if (_reset) exitWith {[+_to, true]};

// In the order the edited list has them, so new items end up packed in the order they were added.
private _removals = [];
private _additions = [];
private _seen = createHashMap;

{
    private _key = toLowerANSI (_x select 0);
    if (_key in _seen) then {continue};
    _seen set [_key, true];

    (_after get _key) params ["_item", "_count"];
    private _delta = _count - ((_before getOrDefault [_key, ["", 0]]) select 1);

    if (_delta < 0) then {_removals pushBack [_item, _delta]};
    if (_delta > 0) then {_additions pushBack [_item, _delta]};
} forEach _to;

// Whatever the edits took out completely.
{
    if !(_x in _after) then {
        _removals pushBack [_y select 0, -(_y select 1)];
    };
} forEach _before;

private _result = +_onto;
private _complete = true;

{
    _x params ["_item", "_delta"];

    if (([_result, _item, _delta, _kit] call FUNC(adjustContents)) != _delta) then {
        _complete = false;
    };
} forEach (_removals + _additions);

[_result, _complete]
