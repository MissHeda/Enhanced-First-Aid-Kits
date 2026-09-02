#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills one of the two lists, keeping the previous selection where possible.
 *
 * Arguments:
 * 0: Listbox control <CONTROL>
 * 1: Entries <ARRAY> of [class, count]
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, [["ACE_morphine", 2]]] call efak_gui_fnc_fillList;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl", "_entries"];

private _selected = if (lbCurSel _ctrl >= 0) then {_ctrl lbData (lbCurSel _ctrl)} else {""};

lbClear _ctrl;

{
    _x params ["_class", "_count"];

    private _mass = ([_class] call EFUNC(core,getItemMass)) * _count;
    private _index = _ctrl lbAdd format ["%1x %2", _count, [_class] call EFUNC(core,getItemName)];

    _ctrl lbSetData [_index, _class];
    _ctrl lbSetValue [_index, _count];
    _ctrl lbSetTooltip [_index, format ["%1 - %2 %3", _class, round _mass, LLSTRING(MassUnit)]];

    private _picture = [_class] call EFUNC(core,getItemPicture);
    if (_picture isNotEqualTo "") then {
        _ctrl lbSetPicture [_index, _picture];
    };

    if (_class isEqualTo _selected) then {
        _ctrl lbSetCurSel _index;
    };
} forEach _entries;
