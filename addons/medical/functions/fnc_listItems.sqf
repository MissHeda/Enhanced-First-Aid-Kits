#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The classes a unit has for treatment: ACE's list of its loose items, plus every item packed in
 * the unit's kits that treatments may use. For other mods that pick from a list - "which bags does
 * the medic have" - rather than ask for one item (efak_medical_fnc_countItem).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Include magazines, as ace_common_fnc_uniqueItems: 0 no, 1 yes, 2 only magazines <NUMBER>
 *    (default: 0)
 *
 * Return Value:
 * Classes <ARRAY>
 *
 * Example:
 * [player, 1] call efak_medical_fnc_listItems;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_mode", 0, [0]]];

if (isNull _unit) exitWith {[]};

private _list = +([_unit, _mode] call FUNC(looseItems));

{
    if !([_x] call FUNC(canUseKit)) then {continue};

    {
        _x params ["_class"];

        if ([_class] call EFUNC(core,isKit)) then {continue};

        private _isMagazine = isClass (configFile >> "CfgMagazines" >> _class);

        if (_isMagazine && {_mode == 0}) then {continue};
        if (!_isMagazine && {_mode == 2}) then {continue};

        _list pushBackUnique _class;
    } forEach ([_x] call EFUNC(core,getContents));
} forEach ([_unit] call EFUNC(core,getCarriedKits));

_list
