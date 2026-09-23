#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills the two sort boxes and selects what was used last.
 *
 * Selecting an entry from script raises the same change event a click does, so a flag keeps the
 * change handler from refreshing the lists halfway through filling the boxes.
 *
 * Arguments:
 * 0: Pouch display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_fillSort;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

private _sort = _display displayCtrl IDC_SORT;
private _direction = _display displayCtrl IDC_SORT_DIR;

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
