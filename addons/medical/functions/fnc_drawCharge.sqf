#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Uses one round of a magazine with several - a breath from an oxygen tank - out of whichever of a
 * unit's kits holds one, right inside the kit (efak_medical_fnc_useCharge). For other mods that draw
 * from a magazine themselves rather than through an ACE treatment.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Magazine class <STRING>
 *
 * Return Value:
 * Rounds left in that magazine, 0 when it was the last, -1 when no kit holds one <NUMBER>
 *
 * Example:
 * [player, "ACM_OxygenTank_425"] call efak_medical_fnc_drawCharge;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_itemClass", "", [""]]];

if (isNull _unit || {_itemClass isEqualTo ""}) exitWith {-1};

([_unit, [_itemClass]] call FUNC(findInKits)) params ["_kitClass", "_found"];

if (_kitClass isEqualTo "") exitWith {-1};

[_unit, _kitClass, _found] call FUNC(useCharge)
