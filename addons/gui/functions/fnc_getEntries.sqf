#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * What one of the places the kit window moves things between holds right now.
 *
 * The places are named rather than numbered, the same names the moves use:
 *   "kit"        the kit being shown
 *   "inventory"  the uniform, vest and backpack of the player together - the left list
 *   "uniform", "vest", "backpack"  one of them - the lists along the bottom
 *   "crate"      the crate or vehicle offered as the second source
 *   "ground"     the weapon holder this window puts things into, see fnc_getGroundHolder
 *
 * The kit being shown is never listed in the inventory or the crate: a kit can never go into itself,
 * whatever the nesting setting says.
 *
 * Arguments:
 * 0: Place <STRING>
 *
 * Return Value:
 * Entries <ARRAY> of [class, count]
 *
 * Example:
 * ["vest"] call efak_gui_fnc_getEntries;
 *
 * Public: No
 */

params ["_key"];

private _fnc_cargo = {
    params ["_objects", ["_skip", ""]];

    private _counts = createHashMap;
    private _order = [];

    private _fnc_collect = {
        params ["_classes", "_amounts"];

        {
            private _class = toLowerANSI _x;

            if (_class isEqualTo _skip) then {continue};

            if !(_class in _counts) then {
                _order pushBack [_class, _x];
            };

            _counts set [_class, (_counts getOrDefault [_class, 0]) + (_amounts select _forEachIndex)];
        } forEach _classes;
    };

    // Opened magazines count like full ones - the kit keeps their rounds (fnc_getPlaceCharges).
    {
        if (isNull _x) then {continue};

        (getItemCargo _x) call _fnc_collect;
        (getMagazineCargo _x) call _fnc_collect;
    } forEach _objects;

    _order apply {[_x select 1, _counts get (_x select 0)]}
};

private _kitKey = toLowerANSI GVAR(kitClass);

switch (_key) do {
    case "kit": {[GVAR(kitClass)] call EFUNC(core,getContents)};
    case "inventory": {
        [[uniformContainer ACE_player, vestContainer ACE_player, backpackContainer ACE_player], _kitKey] call _fnc_cargo
    };
    case "uniform": {[[uniformContainer ACE_player]] call _fnc_cargo};
    case "vest": {[[vestContainer ACE_player]] call _fnc_cargo};
    case "backpack": {[[backpackContainer ACE_player]] call _fnc_cargo};
    case "crate": {[[GVAR(crate)], _kitKey] call _fnc_cargo};
    case "ground": {[[[false] call FUNC(getGroundHolder)], _kitKey] call _fnc_cargo};
    default {[]};
}
