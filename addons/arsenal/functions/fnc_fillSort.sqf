#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills the two sort boxes above the contents list and selects the last choice.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_fillSort;
 *
 * Public: No
 */

params ["_display"];

private _sort = _display displayCtrl IDC_EFAK_SORT;
private _direction = _display displayCtrl IDC_EFAK_SORT_DIR;

GVAR(fillingSort) = true;

lbClear _sort;
{
    _sort lbAdd _x;
} forEach [LLSTRING(Sort_Name), LLSTRING(Sort_Mass), LLSTRING(Sort_Amount)];
_sort lbSetCurSel GVAR(sortMode);

lbClear _direction;
_direction lbAdd LLSTRING(Sort_Ascending);
_direction lbAdd LLSTRING(Sort_Descending);
// Ascending is the first entry, descending the second.
_direction lbSetCurSel parseNumber !GVAR(sortAscending);

GVAR(fillingSort) = false;
