#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many of an item a unit has at hand for treatment: loose in uniform, vest and backpack, plus
 * what its kits hold - only kits of a type the mission lets treatments use.
 *
 * For other mods: count with this instead of ace_common_fnc_getCountOfItem, and take with
 * efak_medical_fnc_takeItem instead of removeItem, and items packed in EFAK kits work like loose
 * ones. Nothing is moved to count.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item class <STRING>
 *
 * Return Value:
 * Count <NUMBER>
 *
 * Example:
 * [player, "ACM_IV_16g"] call efak_medical_fnc_countItem;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_itemClass", "", [""]]];

if (isNull _unit || {_itemClass isEqualTo ""}) exitWith {0};

([_unit, _itemClass] call FUNC(countLoose)) + ([_unit, _itemClass] call FUNC(countInKits))
