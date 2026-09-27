#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many of one item a unit has across all the kits they are carrying.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class <STRING>
 *
 * Return Value:
 * Count <NUMBER>
 *
 * Example:
 * [player, "ACE_morphine"] call efak_medical_fnc_countInKits;
 *
 * Public: No
 */

params ["_unit", "_itemClass"];

if (isNull _unit) exitWith {0};

// ACE asks for one item at a time while the medical menu is open, so the answer comes out of the
// table that was built for the whole unit.
([_unit] call FUNC(kitCounts)) getOrDefault [toLowerANSI _itemClass, 0]
