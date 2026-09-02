#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Swaps one item of a unit for another, keeping it in the same container.
 * Used to turn a kit prototype into a concrete instance.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Class to remove <STRING>
 * 2: Class to add <STRING>
 *
 * Return Value:
 * Replacement succeeded <BOOL>
 *
 * Example:
 * [player, "efak_IFAK", "efak_IFAK_7"] call efak_core_fnc_replaceItem;
 *
 * Public: No
 */

params ["_unit", "_oldClass", "_newClass"];

private _isMagazine = ((_oldClass call ACEFUNC(common,getItemType)) select 0) isEqualTo "magazine";
private _container = "";
private _removed = false;

if (_isMagazine) then {
    {
        _x params ["_containerName", "_containerObject"];
        if (_oldClass in ((getMagazineCargo _containerObject) param [0, []])) exitWith {
            _container = _containerName;
        };
    } forEach [
        ["uniform", uniformContainer _unit],
        ["vest", vestContainer _unit],
        ["backpack", backpackContainer _unit]
    ];

    _removed = _oldClass in (magazines _unit);
    if (_removed) then {
        _unit removeMagazine _oldClass;
    };
} else {
    switch (true) do {
        case (_oldClass in (uniformItems _unit)): {
            _container = "uniform";
            _unit removeItemFromUniform _oldClass;
        };
        case (_oldClass in (vestItems _unit)): {
            _container = "vest";
            _unit removeItemFromVest _oldClass;
        };
        case (_oldClass in (backpackItems _unit)): {
            _container = "backpack";
            _unit removeItemFromBackpack _oldClass;
        };
        default {
            _unit removeItem _oldClass;
        };
    };

    _removed = true;
};

if !(_removed) exitWith {
    TRACE_2("nothing to replace",_oldClass,_newClass);
    false
};

([_unit, _newClass, _container] call ACEFUNC(common,addToInventory)) select 0
