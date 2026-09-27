#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Uses one round of a magazine with several - a pill out of a bottle, a breath out of an oxygen
 * tank - right inside a kit. The magazine stays in the kit, opened, with a round less; only the last
 * round takes it out. An opened one is used before a full one is opened, the emptiest first.
 *
 * Arguments:
 * 0: Unit carrying the kit <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Item class, a magazine of several rounds <STRING>
 *
 * Return Value:
 * Rounds left in that magazine, 0 when it was the last <NUMBER>
 *
 * Example:
 * [player, "efak_IFAK_7", "ACE_painkillers"] call efak_medical_fnc_useCharge;
 *
 * Public: Yes
 */

params ["_unit", "_kitClass", "_itemClass"];

private _rounds = ([_kitClass, _itemClass, 1] call EFUNC(core,pickCharges)) param [0, 0];

if (_rounds <= 0) exitWith {0};

// The last round: the magazine is gone, like a loose one ACE empties.
if (_rounds <= 1) exitWith {
    [_unit, _kitClass, _itemClass, 1] call FUNC(takeFromKit);
    0
};

private _charges = [[_kitClass] call EFUNC(core,getCharges), _itemClass, [_rounds - 1], [_rounds]] call EFUNC(core,adjustCharges);

[_kitClass, [_kitClass] call EFUNC(core,getContents), _charges] call EFUNC(core,setContents);

_rounds - 1
