#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts a carried kit down on the ground at the unit's feet, as an item - with what it holds, which
 * lives on its class and goes with it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * The kit was put down <BOOL>
 *
 * Example:
 * [player, "efak_MFAK_7"] call efak_core_fnc_dropKit;
 *
 * Public: No
 */

params ["_unit", "_kitClass"];

if (!local _unit || {!isNull objectParent _unit}) exitWith {false};

private _key = toLowerANSI _kitClass;
private _index = (items _unit) findIf {(toLowerANSI _x) isEqualTo _key};

if (_index == -1) exitWith {false};

_kitClass = (items _unit) select _index;

// Onto what already lies at the unit's feet, or a new pile there.
private _holder = nearestObject [_unit, "GroundWeaponHolder"];

if (isNull _holder || {_unit distance _holder > 1.5}) then {
    _holder = createVehicle ["GroundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _holder setPosATL (getPosATL _unit);
};

_unit removeItem _kitClass;
_holder addItemCargoGlobal [_kitClass, 1];

_unit playActionNow "PutDown";

true
