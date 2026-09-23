#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What a kit's contents weigh.
 *
 * Everything inside counts, every time: a kit is only ever as heavy as what is actually in it. A
 * mission that writes its own default contents feels those items too, which it would not if this
 * were measured against the stock fill.
 *
 * Nested kits add their contents once, however many times their class turns up.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Kit classes already counted <HASHMAP> (default: new)
 *
 * Return Value:
 * Mass of everything inside <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitLoad;
 *
 * Public: No
 */

params ["_kitClass", ["_counted", createHashMap]];

private _key = toLowerANSI _kitClass;

if (_key in _counted) exitWith {0};

_counted set [_key, true];

private _contents = [_kitClass] call FUNC(getContents);
private _load = [_contents] call FUNC(getUsedCapacity);

{
    _x params ["_class"];

    // A packed kit is an item like any other as far as its own mass goes - what it holds on top of
    // that is not in any list the engine keeps.
    if ([_class] call FUNC(isKit) && {!(toLowerANSI _class in GVAR(needsConversion))}) then {
        _load = _load + ([_class, _counted] call FUNC(getKitLoad));
    };
} forEach _contents;

_load
