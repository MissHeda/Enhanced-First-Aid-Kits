#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The kit the drop key (and the "Drop" action) would put down: of the kits a unit carries that
 * treatments may use, the biggest or the smallest first - each player's own choice
 * (efak_medical_dropOrder).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Kit instance class, "" when there is none <STRING>
 *
 * Example:
 * [player] call efak_medical_fnc_getDropKit;
 *
 * Public: No
 */

params ["_unit"];

private _smallestFirst = (missionNamespace getVariable [QGVAR(dropOrder), DROP_BIGGEST]) == DROP_SMALLEST;
private _keyed = [];

{
    if ([_x] call FUNC(canUseKit)) then {
        private _capacity = [_x] call EFUNC(core,getCapacity);
        _keyed pushBack [[-_capacity, _capacity] select _smallestFirst, _forEachIndex, _x];
    };
} forEach ([_unit] call EFUNC(core,getCarriedKits));

_keyed sort true;

(_keyed param [0, []]) param [2, ""]
