#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The kits a unit carries, in the order a treatment reaches into them: the smallest first - the IFAK
 * before the MFAK, so the big bag stays full the longest - or the biggest first, as the mission sets
 * it (efak_medical_kitSizeOrder). By capacity; kits of one size keep the order they are carried in.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Kit instance classes <ARRAY>
 *
 * Example:
 * [player] call efak_medical_fnc_sortKits;
 *
 * Public: No
 */

params ["_unit"];

private _biggestFirst = (missionNamespace getVariable [QGVAR(kitSizeOrder), KIT_SIZE_SMALLEST]) == KIT_SIZE_BIGGEST;

private _keyed = [];

// Always sorted ascending, the biggest first by a negative capacity, so kits of one size stay in the
// order they are carried in either way.
{
    private _capacity = [_x] call EFUNC(core,getCapacity);
    _keyed pushBack [[_capacity, -_capacity] select _biggestFirst, _forEachIndex, _x];
} forEach ([_unit] call EFUNC(core,getCarriedKits));

_keyed sort true;

_keyed apply {_x select 2}
