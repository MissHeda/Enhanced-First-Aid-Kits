#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Whether an item passes the search box - by its name or by its classname, ignoring case.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * Matches <BOOL>
 *
 * Example:
 * ["ACE_morphine"] call efak_gui_fnc_matchesSearch;
 *
 * Public: No
 */

params ["_class"];

if (GVAR(searchText) isEqualTo "") exitWith {true};

private _needle = toLower GVAR(searchText);

((toLower ([_class] call EFUNC(core,getItemName))) find _needle) > -1 ||
    {((toLower _class) find _needle) > -1}
