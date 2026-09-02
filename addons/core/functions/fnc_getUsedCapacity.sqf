#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns how much of a kit's capacity its contents take up.
 *
 * Arguments:
 * 0: Kit instance class <STRING> or contents <ARRAY>
 *
 * Return Value:
 * Used mass <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getUsedCapacity;
 *
 * Public: Yes
 */

params ["_kitOrContents"];

private _contents = if (_kitOrContents isEqualType "") then {
    [_kitOrContents] call FUNC(getContents)
} else {
    _kitOrContents
};

private _used = 0;

{
    _x params ["_class", "_count"];
    _used = _used + (([_class] call FUNC(getItemMass)) * _count);
} forEach _contents;

_used
