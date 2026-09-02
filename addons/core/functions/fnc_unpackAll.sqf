#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Empties a kit into a unit's inventory.
 *
 * Arguments:
 * 0: Unit receiving the items <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Unit carrying the kit <OBJECT> (default: the receiving unit)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_core_fnc_unpackAll;
 *
 * Public: Yes
 */

params ["_unit", "_kitClass", ["_kitOwner", objNull]];

if (isNull _kitOwner) then {_kitOwner = _unit};

{
    _x params ["_itemClass", "_count"];
    [_unit, _kitClass, _itemClass, _count, _kitOwner, true] call FUNC(unpackItem);
} forEach ([_kitClass] call FUNC(getContents));

[_kitOwner, _kitClass] call FUNC(removeKit);
