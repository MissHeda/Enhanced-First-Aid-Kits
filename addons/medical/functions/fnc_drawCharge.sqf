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
 * 2: What the emptied magazine leaves behind - an empty tank - put back into the same kit,
 *    "" for nothing <STRING> (default: "")
 *
 * Return Value:
 * Rounds left in that magazine, 0 when it was the last, -1 when no kit holds one <NUMBER>
 *
 * Example:
 * [player, "ACM_OxygenTank_425"] call efak_medical_fnc_drawCharge;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_itemClass", "", [""]], ["_emptyClass", "", [""]]];

if (isNull _unit || {_itemClass isEqualTo ""}) exitWith {-1};

([_unit, [_itemClass]] call FUNC(findInKits)) params ["_kitClass", "_found"];

if (_kitClass isEqualTo "") exitWith {-1};

private _left = [_unit, _kitClass, _found] call FUNC(useCharge);

// The last round: the empty one goes where the full one was. Into the unit's inventory instead when
// the kit went with it (an empty kit set to disappear) or may not hold it.
if (_left == 0 && {_emptyClass isNotEqualTo ""}) then {
    private _kits = ([_unit] call EFUNC(core,getCarriedKits)) apply {toLowerANSI _x};

    if ((toLowerANSI _kitClass) in _kits && {([_kitClass, _emptyClass, 1, true] call EFUNC(core,canPackItem)) select 0}) then {
        private _contents = [_kitClass] call EFUNC(core,getContents);
        _contents pushBack [_emptyClass, 1];
        [_kitClass, _contents] call EFUNC(core,setContents);
    } else {
        [_unit, _emptyClass] call ACEFUNC(common,addToInventory);
    };
};

_left
