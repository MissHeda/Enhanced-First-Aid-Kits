#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Tells the server which kits a unit carries, so ids it put back in the pool while the unit was
 * gone are taken out again (fnc_claimInstances). Kits that came back with a saved loadout - a
 * reconnect, a respawn script - are the ones this is for.
 *
 * Each kit is reported once per unit: the loadout event this runs from fires for every magazine.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call efak_core_fnc_claimCarriedKits;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit || {!local _unit}) exitWith {};

private _claimed = _unit getVariable [QGVAR(claimedKits), []];
private _new = (([_unit] call FUNC(getCarriedKits)) apply {toLowerANSI _x}) - _claimed;

if (_new isEqualTo []) exitWith {};

_unit setVariable [QGVAR(claimedKits), _claimed + _new];

[QGVAR(claimInstances), [_new]] call CBA_fnc_serverEvent;
