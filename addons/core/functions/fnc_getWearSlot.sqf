#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Where on the body an item is worn, as its place in getUnitLoadout - or nowhere.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * [loadout index, index in the linked items or -1], [] for something that is not worn <ARRAY>
 *
 * Example:
 * ["U_B_CBRN_Suit_01_MTP_F"] call efak_core_fnc_getWearSlot; // [3, -1]
 *
 * Public: No
 */

params ["_class"];

if (getNumber (configFile >> "CfgVehicles" >> _class >> "isBackpack") == 1) exitWith {[5, -1]};

(_class call ACEFUNC(common,getItemType)) params ["_type", "_subtype"];

switch (true) do {
    case (_subtype == "uniform"): {[3, -1]};
    case (_subtype == "vest"): {[4, -1]};
    case (_subtype == "headgear"): {[6, -1]};
    case (_subtype in ["glasses", "goggles"]): {[7, -1]};
    case (_type == "weapon" && {_subtype == "binocular"}): {[8, -1]};
    case (_subtype == "map"): {[9, 0]};
    case (_subtype in ["gps", "uav_terminal"]): {[9, 1]};
    case (_subtype == "radio"): {[9, 2]};
    case (_subtype == "compass"): {[9, 3]};
    case (_subtype == "watch"): {[9, 4]};
    case (_subtype in ["hmd", "nvgoggles"]): {[9, 5]};
    default {[]};
}
