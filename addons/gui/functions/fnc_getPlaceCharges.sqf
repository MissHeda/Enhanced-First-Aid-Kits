#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The opened magazines at one of the places the kit window moves things between (see
 * fnc_getEntries): pill bottles, oxygen tanks and the like that are no longer full, to show how full
 * they are behind their name.
 *
 * Arguments:
 * 0: Place <STRING>
 *
 * Return Value:
 * Lowercase class -> rounds of each opened one, the emptiest first <HASHMAP>
 *
 * Example:
 * ["inventory"] call efak_gui_fnc_getPlaceCharges;
 *
 * Public: No
 */

params ["_key"];

private _result = createHashMap;

private _fnc_add = {
    params ["_class", "_rounds"];

    private _size = [_class] call EFUNC(core,getMagazineSize);

    if (_size > 1 && {_rounds < _size}) then {
        (_result getOrDefault [toLowerANSI _class, [], true]) pushBack _rounds;
    };
};

if (_key isEqualTo "kit") then {
    {
        _x call _fnc_add;
    } forEach ([GVAR(kitClass)] call EFUNC(core,getCharges));
} else {
    private _objects = switch (_key) do {
        case "crate": {[GVAR(crate)]};
        case "ground": {[[false] call FUNC(getGroundHolder)]};
        case "inventory": {[uniformContainer ACE_player, vestContainer ACE_player, backpackContainer ACE_player]};
        case "uniform": {[uniformContainer ACE_player]};
        case "vest": {[vestContainer ACE_player]};
        default {[backpackContainer ACE_player]};
    };

    {
        if (isNull _x) then {continue};

        {
            _x call _fnc_add;
        } forEach (magazinesAmmoCargo _x);
    } forEach _objects;
};

{
    _y sort true;
} forEach _result;

_result
