#include "..\..\script_component.hpp"
/*
 * Author: Blue, Miss Heda
 * ACM's own function: refills an empty oxygen tank at a medical vehicle.
 *
 * ACM offers the refill when an empty tank shows up in ace_common_fnc_uniqueItems, which with this
 * addon lists what is packed in a kit too - and then took it with removeItem, which does nothing for
 * a tank in a kit, and handed out a full one all the same. The empty tank is taken the way EFAK takes
 * everything: a loose one first, otherwise straight out of the kit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ACM_breathing_fnc_refillOxygenTank;
 *
 * Public: No
 */

params ["_unit"];

// ----- EFAK -----
if !([_unit, "ACM_OxygenTank_425_Empty"] call efak_medical_fnc_takeItem) exitWith {};

_unit call ace_common_fnc_goKneeling;

[8, [_unit], {
    params ["_args"];
    _args params ["_unit"];

    [_unit, "ACM_OxygenTank_425"] call ace_common_fnc_addToInventory;
    ["STR_ACM_Breathing_RefillOxygenTank_Complete", 1.5, _unit] call ace_common_fnc_displayTextStructured;
}, {
    params ["_args"];
    _args params ["_unit"];

    [_unit, "ACM_OxygenTank_425_Empty"] call ace_common_fnc_addToInventory;
    ["STR_ACM_Breathing_RefillOxygenTank_Cancelled", 1.5, _unit] call ace_common_fnc_displayTextStructured;
}, "STR_ACM_Breathing_RefillOxygenTank_Progress"] call ace_common_fnc_progressBar;
