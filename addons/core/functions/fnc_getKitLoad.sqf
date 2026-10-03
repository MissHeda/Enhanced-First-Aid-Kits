#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What a kit's contents weigh.
 *
 * Everything inside counts, every time: a kit is only ever as heavy as what is actually in it. A
 * mission that writes its own default contents feels those items too, which it would not if this
 * were measured against the stock fill.
 *
 * Nested kits add their contents once, however many times their class turns up. A kit packed in
 * another one takes the room of its packed size there, so its weight offset (fnc_getWeightOffset)
 * comes along separately - that part is not scaled by the kit weight setting.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Kit classes already counted <HASHMAP> (default: new)
 *
 * Return Value:
 * 0: Mass of everything inside <NUMBER>
 * 1: Weight offsets of the kits inside <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitLoad;
 *
 * Public: No
 */

params ["_kitClass", ["_counted", createHashMap]];

private _key = toLowerANSI _kitClass;

if (_key in _counted) exitWith {[0, 0]};

_counted set [_key, true];

private _contents = [_kitClass] call FUNC(getContents);
private _load = [_contents] call FUNC(getUsedCapacity);
private _offset = 0;

{
    _x params ["_class", "_count"];

    // A packed kit is an item like any other as far as its own mass goes - what it holds on top of
    // that is not in any list the engine keeps.
    if ([_class] call FUNC(isKit)) then {
        _offset = _offset + ([_class] call FUNC(getWeightOffset)) * _count;

        if !(toLowerANSI _class in GVAR(needsConversion)) then {
            ([_class, _counted] call FUNC(getKitLoad)) params ["_innerLoad", "_innerOffset"];
            _load = _load + _innerLoad;
            _offset = _offset + _innerOffset;
        };
    };
} forEach _contents;

[_load, _offset]
