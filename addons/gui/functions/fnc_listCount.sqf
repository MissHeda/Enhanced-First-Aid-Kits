#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * How many of one class a [class, count] list holds.
 *
 * Arguments:
 * 0: List <ARRAY> of [class, count]
 * 1: Item class <STRING>
 *
 * Return Value:
 * Count <NUMBER>
 *
 * Example:
 * [[["ACE_morphine", 2]], "ACE_morphine"] call efak_gui_fnc_listCount;
 *
 * Public: No
 */

params ["_list", "_class"];

private _key = toLowerANSI _class;
private _index = _list findIf {toLowerANSI (_x select 0) isEqualTo _key};

if (_index < 0) exitWith {0};

(_list select _index) select 1
