#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts one item into a unit's clothing: the preferred container first, then whichever of the
 * others has room - uniform, vest, backpack - and only onto the ground when none does.
 *
 * ACE's own function drops an item straight on the ground when it does not fit the one container
 * it was asked for, even with the backpack half empty.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class <STRING>
 * 2: Preferred container: "uniform", "vest", "backpack" or "" for none <STRING> (default: "")
 *
 * Return Value:
 * [ended up on the unit <BOOL>, holder it went into <OBJECT>] - as ace_common_fnc_addToInventory
 *
 * Example:
 * [player, "ACE_fieldDressing", "vest"] call efak_core_fnc_addToUnit;
 *
 * Public: No
 */

params ["_unit", "_class", ["_preferred", ""], ["_rounds", -1]];

// A backpack fits in no container: it goes on the unit's back, or on the ground beside them when
// they already wear one - which counts as not reaching the unit, like any other dropped item.
if (getNumber (configFile >> "CfgVehicles" >> _class >> "isBackpack") == 1) exitWith {
    if (backpack _unit isEqualTo "") exitWith {
        _unit addBackpackGlobal _class;
        [true, _unit]
    };

    private _holder = nearestObject [_unit, "WeaponHolder"];

    if (isNull _holder || {_unit distance _holder > 2}) then {
        _holder = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0, "CAN_COLLIDE"];
    };

    _holder addBackpackCargoGlobal [_class, 1];
    [false, _holder]
};

private _order = ["uniform", "vest", "backpack"];

if (_preferred in _order) then {
    _order = [_preferred] + (_order - [_preferred]);
};

private _fnc_container = {
    switch (_this) do {
        case "uniform": {uniformContainer _unit};
        case "vest": {vestContainer _unit};
        default {backpackContainer _unit};
    };
};

private _index = _order findIf {
    private _container = _x call _fnc_container;
    !isNull _container && {_container canAdd _class}
};

if (_index < 0) exitWith {
    // No room anywhere: ACE puts it on the ground at the unit's feet.
    [_unit, _class, "", _rounds] call ACEFUNC(common,addToInventory)
};

[_unit, _class, _order select _index, _rounds] call ACEFUNC(common,addToInventory)
