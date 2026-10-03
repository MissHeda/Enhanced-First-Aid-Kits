#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Takes items out of one of the places the kit window moves things between (see fnc_getEntries),
 * right now.
 *
 * Each place is changed the way it has to be in multiplayer: the kit only through its contents,
 * the player's own clothing directly, since the player is local here, and the crate and the ground
 * with the global cargo commands. Out of the inventory as a whole comes out of the uniform first,
 * then the vest, then the backpack.
 *
 * Magazines go by their rounds: the emptiest first, or exactly the ones given (fnc_pickRounds), so
 * an opened pill bottle moves as it is and the kit keeps count of it.
 *
 * Never takes more than is there.
 *
 * Arguments:
 * 0: Place <STRING>
 * 1: Item class <STRING>
 * 2: How many <NUMBER>
 * 3: Rounds of each magazine to take, [] for the emptiest ones <ARRAY> (default: [])
 *
 * Return Value:
 * How many were taken <NUMBER>
 *
 * Example:
 * ["inventory", "ACE_morphine", 2] call efak_gui_fnc_takeItems;
 *
 * Public: No
 */

params ["_key", "_class", "_count", ["_rounds", []]];

if (_count <= 0) exitWith {0};

if (_key isEqualTo "kit") exitWith {
    private _contents = [GVAR(kitClass)] call EFUNC(core,getContents);
    private _taken = _count min ([_contents, _class] call FUNC(listCount));

    if (_taken > 0) then {
        if (_rounds isEqualTo []) then {
            _rounds = [GVAR(kitClass), _class, _taken] call EFUNC(core,pickCharges);
        };

        private _charges = [[GVAR(kitClass)] call EFUNC(core,getCharges), _class, [], _rounds select [0, _taken]] call EFUNC(core,adjustCharges);

        [_contents, _class, -_taken] call FUNC(listAdjust);
        [_contents, _charges] call FUNC(writeKit);
    };

    _taken
};

private _isMagazine = ((_class call ACEFUNC(common,getItemType)) select 0) isEqualTo "magazine";
private _isBackpack = getNumber (configFile >> "CfgVehicles" >> _class >> "isBackpack") == 1;
private _classKey = toLowerANSI _class;

// The crate and the ground are cargo rather than carried items, and answer to their own commands.
private _objects = switch (_key) do {
    case "crate": {[GVAR(crate)]};
    case "ground": {[[false] call FUNC(getGroundHolder)]};
    case "inventory": {[uniformContainer ACE_player, vestContainer ACE_player, backpackContainer ACE_player]};
    case "uniform": {[uniformContainer ACE_player]};
    case "vest": {[vestContainer ACE_player]};
    default {[backpackContainer ACE_player]};
};

// Magazines are taken out one by one, by their rounds, as cargo of whatever holds them.
if (_isMagazine) exitWith {
    private _magazines = [];

    {
        private _where = _forEachIndex;

        if (isNull _x) then {continue};

        {
            _x params ["_magazine", "_ammo"];

            if ((toLowerANSI _magazine) isEqualTo _classKey) then {
                _magazines pushBack [_ammo, _where];
            };
        } forEach (magazinesAmmoCargo _x);
    } forEach _objects;

    // The emptiest first - the same order fnc_pickRounds hands out.
    _magazines sort true;

    private _chosen = if (_rounds isEqualTo []) then {
        _magazines select [0, _count]
    } else {
        private _picked = [];

        {
            private _want = _x;
            private _index = _magazines findIf {(_x select 0) == _want};

            if (_index >= 0) then {
                _picked pushBack (_magazines deleteAt _index);
            };
        } forEach (_rounds select [0, _count]);

        _picked
    };

    {
        _x params ["_ammo", "_where"];

        (_objects select _where) addMagazineAmmoCargo [_class, -1, _ammo];
    } forEach _chosen;

    count _chosen
};

if (_key in ["crate", "ground"]) exitWith {
    private _object = _objects select 0;

    if (isNull _object) exitWith {0};

    ([getItemCargo _object, getBackpackCargo _object] select _isBackpack) params ["_classes", "_counts"];

    private _have = 0;

    {
        if ((toLowerANSI _x) isEqualTo _classKey) then {
            _have = _have + (_counts select _forEachIndex);
        };
    } forEach _classes;

    private _taken = _count min _have;

    if (_taken > 0) then {
        if (_isBackpack) then {
            [_object, _class, _taken] call CBA_fnc_removeBackpackCargo;
        } else {
            _object addItemCargoGlobal [_class, -_taken];
        };
    };

    _taken
};

private _names = [[_key], ["uniform", "vest", "backpack"]] select (_key isEqualTo "inventory");
private _left = _count;

{
    if (_left <= 0) exitWith {};

    private _name = _x;
    private _container = _objects select _forEachIndex;

    if (isNull _container) then {continue};

    (getItemCargo _container) params ["_classes", "_counts"];

    private _have = 0;

    {
        if ((toLowerANSI _x) isEqualTo _classKey) then {
            _have = _have + (_counts select _forEachIndex);
        };
    } forEach _classes;

    private _take = _left min _have;

    if (_take <= 0) then {continue};

    for "_i" from 1 to _take do {
        switch (_name) do {
            case "uniform": {ACE_player removeItemFromUniform _class};
            case "vest": {ACE_player removeItemFromVest _class};
            default {ACE_player removeItemFromBackpack _class};
        };
    };

    _left = _left - _take;
} forEach _names;

_count - _left
