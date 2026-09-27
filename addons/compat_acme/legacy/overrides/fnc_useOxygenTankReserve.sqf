#include "..\..\script_component.hpp"
/*
 * Author: Blue, Miss Heda
 * ACM's own function: draws one unit of oxygen from the emptiest portable tank the unit carries -
 * the BVM with portable oxygen and ACM Extended's non-rebreather call it once per breath.
 *
 * ACM only looks for loose tanks. With this addon the BVM offers portable oxygen as soon as a tank
 * is packed in a kit (see fnc_uniqueItems), so a tank found in no container is drawn from inside the
 * kit: it stays there, opened, one unit lighter (efak_medical_fnc_useCharge). The empty tank ACM
 * hands back for refilling goes into that kit too, where it takes one.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Oxygen drawn <BOOL>
 *
 * Example:
 * [player] call ACM_breathing_fnc_useOxygenTankReserve;
 *
 * Public: No
 */

params ["_unit"];

private _return = false;
private _found = false;

private _itemContainers = [uniformContainer _unit, vestContainer _unit, backpackContainer _unit];
private _containerString = ["uniform", "vest", "backpack"];

{
    private _container = _x;

    private _mags = magazinesAmmoCargo _container;

    private _targetMags = [];

    {
        _x params ["_magClassname", "_magCount"];

        if (_magClassname == "ACM_OxygenTank_425") then {
            _targetMags pushBack _magCount;
        };
    } forEach _mags;

    if (count _targetMags > 0) exitWith {
        _found = true;
        _targetMags sort true;

        private _targetAmmoCount = (_targetMags select 0);

        _container addMagazineAmmoCargo ["ACM_OxygenTank_425", -1, _targetAmmoCount];

        private _newCount = _targetAmmoCount - 1;

        if (_newCount < 1) then {
            [_unit, "ACM_OxygenTank_425_Empty", (_containerString select _forEachIndex)] call ace_common_fnc_addToInventory;
        } else {
            _container addMagazineAmmoCargo ["ACM_OxygenTank_425", 1, _newCount];
            _return = true;
        };
    };
} forEach _itemContainers;

// ----- EFAK -----
if (_found) exitWith {_return};

([_unit, ["ACM_OxygenTank_425"]] call efak_medical_fnc_findInKits) params ["_kitClass", "_tank"];

if (_kitClass isEqualTo "") exitWith {false};

// An opened tank is drawn from before a full one is opened.
private _left = [_unit, _kitClass, _tank] call efak_medical_fnc_useCharge;

if (_left >= 1) exitWith {true};

// Used up: ACM hands back an empty tank. Into the kit it came out of, where that kit still exists and
// takes one - the full tank that just left made the room - otherwise into the inventory.
if (
    [_unit, _kitClass] call efak_core_fnc_holderHasKit &&
    {([_kitClass, "ACM_OxygenTank_425_Empty"] call efak_core_fnc_isItemAllowed) select 0}
) then {
    private _contents = [_kitClass] call efak_core_fnc_getContents;
    _contents pushBack ["ACM_OxygenTank_425_Empty", 1];
    [_kitClass, _contents] call efak_core_fnc_setContents;
} else {
    [_unit, "ACM_OxygenTank_425_Empty"] call efak_core_fnc_addToUnit;
};

false
