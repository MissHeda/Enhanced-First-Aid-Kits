#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Lists everything in a unit's containers that is allowed into the given kit.
 * Items that would not fit right now are still listed - the transfer clamps to
 * whatever space is left.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * Items <ARRAY> of [class, count]
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_gui_fnc_getPackableItems;
 *
 * Public: No
 */

params ["_unit", "_kitClass"];

private _counts = createHashMap;
private _order = [];

private _fnc_collect = {
    params ["_classes", "_amounts"];

    {
        private _key = toLowerANSI _x;

        if !(_key in _counts) then {
            // A kit can never go into itself, whatever the nesting setting says.
            if (_x == _kitClass) then {continue};
            if !(([_kitClass, _x, 0] call EFUNC(core,canPackItem)) select 0) then {continue};
            _order pushBack [_key, _x];
        };

        _counts set [_key, (_counts getOrDefault [_key, 0]) + (_amounts select _forEachIndex)];
    } forEach _classes;
};

{
    (getItemCargo _x) call _fnc_collect;
    (getMagazineCargo _x) call _fnc_collect;
} forEach [uniformContainer _unit, vestContainer _unit, backpackContainer _unit];

_order apply {[_x select 1, _counts get (_x select 0)]}
