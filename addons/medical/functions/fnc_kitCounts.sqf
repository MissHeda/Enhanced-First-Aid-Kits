#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What a unit has across the kits ACE treatments may use, as lowercase class -> count - in total,
 * or per line of the medical menu: per kit type, the kits lying nearby apart (fnc_kitSourceKey).
 *
 * Only kits of a type the mission lets treatments use count (fnc_canUseKit); the others are not
 * there as far as ACE medical is concerned.
 *
 * ACE asks whether an item is there, and how many there are, for every item of every treatment
 * whenever the medical menu draws - many times a frame, every frame the menu is open. One walk
 * fills both tables instead. They are kept until the kits, their contents or the settings change,
 * and within a frame they are handed back without even looking at what the unit carries.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Per kit type <BOOL> (default: false)
 *
 * Return Value:
 * Lowercase class -> count <HASHMAP>, or kit type ("<id>" or "<id>@ground") -> (lowercase class ->
 * count) <HASHMAP> - do not modify either
 *
 * Example:
 * ([player] call efak_medical_fnc_kitCounts) getOrDefault ["ace_morphine", 0];
 *
 * Public: No
 */

params ["_unit", ["_byType", false]];

if (isNull _unit) exitWith {createHashMap};

private _cache = _unit getVariable [QGVAR(countCache), []];
_cache params [["_frame", -1], ["_stamp", -1], ["_kits", []], ["_counts", createHashMap], ["_perType", createHashMap]];

private _result = [_counts, _perType] select _byType;

// Asked again in the same frame, and no kit's contents changed since: the same answer. A change within
// the frame counts - ACM Extended counts, takes one and counts again to see that it worked.
if (_frame isEqualTo diag_frameNo && {_stamp isEqualTo EGVAR(core,contentsStamp)}) exitWith {_result};

// A kit type switched off drops out of this list, so a settings change is a different list. Where a
// kit is belongs to it too: one set down on the ground counts on a line of its own from then on.
private _carried = ([_unit, KITS_CARRIED] call FUNC(usableKits)) select {[_x] call FUNC(canUseKit)};
private _ground = ([_unit, KITS_GROUND] call FUNC(usableKits)) select {[_x] call FUNC(canUseKit)};
private _now = _carried + (_ground apply {_x + "@ground"});

if (_stamp isEqualTo EGVAR(core,contentsStamp) && {_kits isEqualTo _now}) exitWith {
    _cache set [0, diag_frameNo];
    _result
};

private _fresh = createHashMap;
private _freshPerType = createHashMap;

{
    _x params ["_kits", "_suffix"];

    {
        private _type = (([_x] call EFUNC(core,getKitData)) select KIT_ID) + _suffix;
        private _ofType = _freshPerType getOrDefault [_type, createHashMap, true];

        // Only read here, so it comes straight out of the store rather than through a copy.
        {
            _x params ["_class", "_count"];

            private _key = toLowerANSI _class;
            _fresh set [_key, (_fresh getOrDefault [_key, 0]) + _count];
            _ofType set [_key, (_ofType getOrDefault [_key, 0]) + _count];
        } forEach (EGVAR(core,contents) getOrDefault [toLowerANSI _x, []]);
    } forEach _kits;
} forEach [[_carried, ""], [_ground, "@ground"]];

_unit setVariable [QGVAR(countCache), [diag_frameNo, EGVAR(core,contentsStamp), _now, _fresh, _freshPerType]];

[_fresh, _freshPerType] select _byType
