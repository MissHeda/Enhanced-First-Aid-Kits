#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts on something straight out of a kit - the suit, the mask and the breathing set of a CBRN bag.
 *
 * What it replaces goes back into the same kit if the kit takes it and has the room, else into the
 * unit's inventory, else onto the ground. A uniform or vest keeps what was in the old one. A
 * backpack it replaces is set down on the ground with everything in it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Item class <STRING>
 *
 * Return Value:
 * Put on <BOOL>
 *
 * Example:
 * [player, "eup_CBRNBag_3", "U_B_CBRN_Suit_01_MTP_F"] call efak_core_fnc_wearItem;
 *
 * Public: No
 */

params ["_unit", "_kitClass", "_itemClass"];

if (!local _unit || {!alive _unit} || {!isNull objectParent _unit}) exitWith {false};

private _slot = [_itemClass] call FUNC(getWearSlot);

if (_slot isEqualTo []) exitWith {false};

if !([_kitClass, _itemClass, -1] call FUNC(changeKitItem)) exitWith {false};

_slot params ["_index", "_linked"];

private _loadout = getUnitLoadout _unit;
private _old = "";

switch (_index) do {
    // Uniform and vest: the new one takes what the old one held.
    case 3;
    case 4: {
        private _entry = _loadout select _index;
        _old = _entry param [0, ""];
        _loadout set [_index, [_itemClass, _entry param [1, []]]];
    };
    // Backpack: the old one is set down, full, next to the unit.
    case 5: {
        private _entry = _loadout select 5;

        if (_entry isNotEqualTo []) then {
            _entry params ["_bagClass", ["_bagItems", []]];

            private _holder = createVehicle ["GroundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];
            _holder setPosATL (getPosATL _unit);
            _holder addBackpackCargoGlobal [_bagClass, 1];

            private _bag = (everyBackpack _holder) param [0, objNull];

            {
                switch (true) do {
                    // [weapon, muzzle, flashlight, optics, [magazine], [magazine], bipod], count
                    case (_x isEqualTypeParams [[], 0]): {
                        _bag addWeaponWithAttachmentsCargoGlobal [_x select 0, _x select 1];
                    };
                    // [magazine, count, rounds]
                    case (_x isEqualTypeParams ["", 0, 0]): {
                        _bag addMagazineAmmoCargo [_x select 0, _x select 1, _x select 2];
                    };
                    // [backpack, true]
                    case (_x isEqualTypeParams ["", true]): {
                        _bag addBackpackCargoGlobal [_x select 0, 1];
                    };
                    case (_x isEqualTypeParams ["", 0]): {
                        _bag addItemCargoGlobal [_x select 0, _x select 1];
                    };
                };
            } forEach _bagItems;
        };

        _loadout set [5, [_itemClass, []]];
    };
    case 6;
    case 7: {
        _old = _loadout select _index;
        _loadout set [_index, _itemClass];
    };
    case 8: {
        _old = (_loadout select 8) param [0, ""];
        _loadout set [8, [_itemClass, "", "", "", [], [], ""]];
    };
    case 9: {
        private _items = _loadout select 9;
        _old = _items select _linked;
        _items set [_linked, _itemClass];
    };
};

_unit setUnitLoadout _loadout;

if (_old isNotEqualTo "") then {
    if (([_kitClass, _old, 1] call FUNC(canPackItem)) select 0) then {
        [_kitClass, _old, 1] call FUNC(changeKitItem);
    } else {
        [_unit, _old] call FUNC(addToUnit);
    };
};

true
