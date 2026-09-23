#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills the contents window (fnc_showContents) with the kit it shows, as it is right now.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_fillContentsPopup;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(contentsDisplay), displayNull];

if (isNull _display) exitWith {};

private _kitClass = GVAR(contentsKit);

// The kit was taken away, dropped or thrown away once empty: nothing left to show.
// Closed a frame later: this runs inside the change event, whose handler the closing removes.
if !([GVAR(contentsHolder), _kitClass] call EFUNC(core,holderHasKit)) exitWith {
    [{(_this select 0) closeDisplay 2}, [_display]] call CBA_fnc_execNextFrame;
};

private _contents = [_kitClass] call EFUNC(core,getContents);
private _used = [_contents] call EFUNC(core,getUsedCapacity);
private _capacity = [_kitClass] call EFUNC(core,getCapacity);

(_display displayCtrl IDC_CONTENTS_PICTURE) ctrlSetText ([_kitClass] call EFUNC(core,getItemPicture));

(_display displayCtrl IDC_CONTENTS_TITLE) ctrlSetStructuredText parseText format [
    "<t size='1.15' color='#FFC84D'>%1</t><br/><t size='0.8' color='#B3B3B3'>%2 %3 / %4 %5</t>",
    [_kitClass] call EFUNC(core,getKitName),
    LELSTRING(core,Capacity),
    round _used,
    round _capacity,
    LLSTRING(MassUnit)
];

(_display displayCtrl IDC_CONTENTS_BAR) progressSetPosition ((_used / (_capacity max 1)) min 1);

private _list = _display displayCtrl IDC_CONTENTS_LIST;
private _scroll = ctrlScrollValues _list;
private _selected = [_list lbData (lbCurSel _list), ""] select (lbCurSel _list < 0);
private _labels = [LELSTRING(core,Tooltip_Amount), LELSTRING(core,Tooltip_Mass), LELSTRING(core,Tooltip_TotalMass)];

private _fnc_mass = {
    str ((round (_this * 100)) / 100)
};

lbClear _list;

if (_contents isEqualTo []) then {
    private _index = _list lbAdd LELSTRING(core,Empty);
    _list lbSetColor [_index, [1, 1, 1, 0.5]];
};

// An opened magazine is a row of its own, see efak_core_fnc_getKitRows. The row carries "class|which".
{
    _x params ["_class", "_count", "_which", "_name"];

    private _each = [_class] call EFUNC(core,getItemMass);
    private _index = _list lbAdd _name;

    _list lbSetData [_index, format ["%1|%2", _class, _which]];
    _list lbSetTextRight [_index, format ["%1x", _count]];
    _list lbSetColorRight [_index, COLOR_COUNT];
    _list lbSetSelectColorRight [_index, COLOR_COUNT];
    _list lbSetPicture [_index, [_class] call EFUNC(core,getItemPicture)];

    private _table = [_labels, [format ["%1x", _count], _each call _fnc_mass, (_each * _count) call _fnc_mass]] call EFUNC(core,formatColumns);
    _list lbSetTooltip [_index, format ["%1\n%2\n\n%3\n%4", _name, _class, _table select 0, _table select 1]];
} forEach ([_kitClass] call EFUNC(core,getKitRows));

// The same item stays selected while it is still there.
private _row = -1;

if (_selected isNotEqualTo "") then {
    for "_i" from 0 to (lbSize _list - 1) do {
        if ((_list lbData _i) == _selected) exitWith {_row = _i};
    };
};

_list lbSetCurSel _row;
_list ctrlSetScrollValues _scroll;

call FUNC(onContentsSelect);
