#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * A few well known containers and how much they hold, appended to the capacity setting so a
 * number in mass units means something to whoever is dragging the slider.
 *
 * Read from config rather than written down, so it stays right when a mod changes the values.
 * Each entry is a list of candidates - the first one that exists wins, because the exact
 * classname of a given bag differs between the base game and its DLC.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Reference block, one container per line <STRING>, "" when none of the classes exist
 *
 * Example:
 * call efak_core_fnc_capacityHint;
 *
 * Public: No
 */

private _fnc_capacity = {
    params ["_class"];

    // Backpacks are vehicles and carry the number themselves. Uniforms and vests are weapons
    // that point at a vehicle class for their cargo space.
    private _vehicle = configFile >> "CfgVehicles" >> _class;

    // Only what a player can actually pick in the arsenal. The base game still ships hidden
    // legacy bags under almost the same names - B_Bergen_mcamo holds 280, the Bergen everybody
    // knows is B_Bergen_mcamo_F and holds 480 - and those must never be the reference.
    if (isClass _vehicle) exitWith {
        if (getNumber (_vehicle >> "scope") != 2) exitWith {[]};

        [getText (_vehicle >> "displayName"), getNumber (_vehicle >> "maximumLoad")]
    };

    private _weapon = configFile >> "CfgWeapons" >> _class;

    if !(isClass _weapon) exitWith {[]};

    private _container = getText (_weapon >> "ItemInfo" >> "containerClass");

    if (_container isEqualTo "") exitWith {[]};

    [getText (_weapon >> "displayName"), getNumber (configFile >> "CfgVehicles" >> _container >> "maximumLoad")]
};

// "Assault Pack (Khaki)" is one bag out of eight that hold the same amount. The colour is noise
// in a comparison, so everything from the first bracket on is cut.
private _fnc_trim = {
    params ["_name"];

    private _cut = _name find "(";

    if (_cut < 1) exitWith {_name};

    trim (_name select [0, _cut])
};

private _lines = [];

{
    private _found = [];

    {
        private _entry = _x call _fnc_capacity;

        if (_entry isNotEqualTo [] && {(_entry select 1) > 0}) exitWith {_found = _entry};
    } forEach _x;

    if (_found isNotEqualTo []) then {
        _found params ["_name", "_load"];

        _lines pushBack format ["    %1 %2", round _load, _name call _fnc_trim];
    };
} forEach [
    // Smallest to largest. Values as shipped: 160, 300, 320, 480.
    ["B_AssaultPack_khk", "B_AssaultPack_blk"],
    ["B_ViperHarness_oli_F", "B_ViperHarness_blk_F"],
    ["B_Carryall_oli", "B_Carryall_khk"],
    ["B_Bergen_mcamo_F", "B_Bergen_dgtl_F"]
];

if (_lines isEqualTo []) exitWith {""};

// One per line - four figures on one line is a wall of text nobody reads in a tooltip.
format ["%1%2%3", LLSTRING(Setting_Capacity_Reference), "\n", _lines joinString "\n"]
