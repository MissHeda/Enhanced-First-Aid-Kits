#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Makes the kits a player carries weigh what is actually in them, through ACE's virtual load.
 *
 * The load goes on the unit itself, never on the uniform, vest or backpack. ACE only ever uses
 * the sum of the four, and a container that is dropped, handed over or put in a crate would
 * otherwise walk off with EFAK's share still on it. ACE's gunbag also writes to the backpack from
 * other machines, and the unit keeps us out of its way.
 *
 * Works on the difference: EFAK remembers what it has applied, works out the new total and hands
 * ACE only the change. With the setting off the new total is zero, so switching it off removes
 * exactly what was added.
 *
 * Only runs where the unit is local - ACE turns the load into a unit trait, and those can only be
 * set by the machine that owns the unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call efak_core_fnc_updateVirtualLoad;
 *
 * Public: No
 */

params [["_unit", objNull]];

if (isNull _unit || {!local _unit} || {!hasInterface}) exitWith {};

// Before the server's contents have arrived every kit looks empty, which would be read as a big
// negative offset. Wait for the sync.
if !(GVAR(contentsSynced)) exitWith {};

// ACE movement is where virtual load lives. Without it there is nothing to add to.
if (isNil QACEFUNC(movement,addLoadToUnitContainer)) exitWith {};

private _target = 0;

// How much of what the kits hold the player is made to feel: 0 is off, 1 is the honest weight,
// anything in between or above scales it.
// A profile from before this was a slider can still hold the old on/off value, so true reads as
// the full weight and false as off.
private _factor = missionNamespace getVariable [QGVAR(kitWeight), 0];
if (_factor isEqualType false) then {_factor = parseNumber _factor};

if (_factor > 0) then {
    private _counted = createHashMap;

    {
        _target = _target + ([_x, _counted] call FUNC(getKitLoad));
    } forEach ([_unit] call FUNC(getCarriedKits));

    _target = _target * _factor;
};

private _applied = _unit getVariable [QGVAR(appliedLoad), 0];
private _delta = _target - _applied;

if (abs _delta < 0.001) exitWith {};

if ([_unit, _unit, _delta] call ACEFUNC(movement,addLoadToUnitContainer)) then {
    // Public, so it travels with the unit to whoever takes it over next and gets cleaned up there.
    _unit setVariable [QGVAR(appliedLoad), _target, true];
};
