#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Puts items into one of the places the kit window moves things between (see fnc_getEntries), right
 * now, as far as there is room.
 *
 * Into the inventory as a whole goes into the unload container chosen for this kit first - or the
 * one the mission decided - and then into whichever of the uniform, the vest and the backpack still
 * has room, in that order. Whether an item fits is the engine's call, item by item, so what it says
 * fits really goes in. Into one of the three goes there or nowhere.
 *
 * The kit takes what it is given: the caller has already checked it against the kit's room and
 * rules (fnc_getKitRoom). The crate takes what its load allows, the ground everything.
 *
 * Arguments:
 * 0: Place <STRING>
 * 1: Item class <STRING>
 * 2: How many <NUMBER>
 * 3: Rounds of each magazine, as fnc_pickRounds gave them - [] for full ones <ARRAY> (default: [])
 *
 * Return Value:
 * 0: How many went in <NUMBER>
 * 1: How many the engine refused after all and put on the ground at the player's feet <NUMBER>
 *
 * Example:
 * ["inventory", "ACE_morphine", 2] call efak_gui_fnc_putItems;
 *
 * Public: No
 */

params ["_key", "_class", "_count", ["_rounds", []]];

if (_count <= 0) exitWith {[0, 0]};

if (_key isEqualTo "kit") exitWith {
    private _contents = [GVAR(kitClass)] call EFUNC(core,getContents);
    private _charges = [[GVAR(kitClass)] call EFUNC(core,getCharges), _class, _rounds select [0, _count]] call EFUNC(core,adjustCharges);

    [_contents, _class, _count] call FUNC(listAdjust);
    [_contents, _charges] call FUNC(writeKit);

    [_count, 0]
};

private _isMagazine = ((_class call ACEFUNC(common,getItemType)) select 0) isEqualTo "magazine";
private _isBackpack = getNumber (configFile >> "CfgVehicles" >> _class >> "isBackpack") == 1;

// The crate and the ground are cargo rather than carried items, and answer to their own commands.
if (_key in ["crate", "ground"]) exitWith {
    private _object = if (_key isEqualTo "ground") then {[true] call FUNC(getGroundHolder)} else {GVAR(crate)};

    if (isNull _object) exitWith {[0, 0]};

    private _fits = _count;
    private _mass = [_class] call EFUNC(core,getItemMass);

    // The cargo commands would overfill a crate without complaint, so its load is checked here.
    if (_key isEqualTo "crate" && {_mass > 0}) then {
        ([SOURCE_CRATE] call FUNC(getSourceLoad)) params ["_load", "_maxLoad"];

        _fits = _count min ((floor ((_maxLoad - _load + MASS_EPSILON) / _mass)) max 0);
    };

    if (_fits > 0) then {
        switch (true) do {
            // Opened magazines one by one, with their rounds.
            case (_rounds isNotEqualTo []): {
                for "_i" from 0 to (_fits - 1) do {
                    private _ammo = _rounds param [_i, -1];

                    if (_ammo < 0) then {
                        _object addMagazineCargoGlobal [_class, 1];
                    } else {
                        _object addMagazineAmmoCargo [_class, 1, _ammo];
                    };
                };
            };
            case (_isMagazine): {_object addMagazineCargoGlobal [_class, _fits]};
            case (_isBackpack): {_object addBackpackCargoGlobal [_class, _fits]};
            default {_object addItemCargoGlobal [_class, _fits]};
        };
    };

    [_fits, 0]
};

// A backpack fits in no container: onto the player's back while it is free, the rest on the ground.
if (_isBackpack) exitWith {
    private _placed = 0;
    private _dropped = 0;

    for "_i" from 1 to _count do {
        if (backpack ACE_player isEqualTo "") then {
            ACE_player addBackpackGlobal _class;
            _placed = _placed + 1;
        } else {
            private _holder = [true] call FUNC(getGroundHolder);
            if (isNull _holder) exitWith {};
            _holder addBackpackCargoGlobal [_class, 1];
            _dropped = _dropped + 1;
        };
    };

    [_placed, _dropped]
};

private _names = [_key];

if (_key isEqualTo "inventory") then {
    _names = ["uniform", "vest", "backpack"];

    private _preferred = [GVAR(kitClass)] call EFUNC(core,getKitContainer);

    if (_preferred in _names) then {
        _names = [_preferred] + (_names - [_preferred]);
    };
};

private _fnc_container = {
    switch (_this) do {
        case "uniform": {uniformContainer ACE_player};
        case "vest": {vestContainer ACE_player};
        default {backpackContainer ACE_player};
    };
};

private _placed = 0;
private _dropped = 0;

for "_i" from 1 to _count do {
    private _index = _names findIf {
        private _container = _x call _fnc_container;
        !isNull _container && {_container canAdd _class}
    };

    if (_index < 0) exitWith {};

    // ACE puts an item the engine refuses after all at the player's feet rather than losing it.
    if (([ACE_player, _class, _names select _index, _rounds param [_i - 1, -1]] call ACEFUNC(common,addToInventory)) select 0) then {
        _placed = _placed + 1;
    } else {
        _dropped = _dropped + 1;
    };
};

[_placed, _dropped]
