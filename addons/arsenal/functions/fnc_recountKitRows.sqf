#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Puts ACE Arsenal's container list right about kits: what it counts, and what it lists.
 *
 * ACE counts the items of a container by their exact class, and a kit stops being of its type's
 * class (efak_IFAK) a moment after it goes in: it becomes one of its instances (efak_IFAK_7). Its
 * row read 0 after any refresh - a loaded loadout, another tab - and "-" found nothing to take out.
 * Here the row of a type counts every kit of it, and the instances ACE lists as rows of their own
 * (unique items) go - all but the kits a player gave a name (efak_core_fnc_setKitLabel): those are
 * a row of their own under that name, wherever their type has a row, and their type does not count
 * them. The counts are kept for onCargoChanged.
 *
 * Arguments:
 * 0: ACE Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_recountKitRows;
 *
 * Public: No
 */

params ["_display"];

GVAR(kitRowCounts) = createHashMap;

private _ctrlList = _display displayCtrl IDC_ACE_RIGHT_LIST;
private _items = [] call FUNC(getContainerItems);

if (isNull _ctrlList || {isNil "_items"}) exitWith {};

// Kits without a name count for their type; those with one are counted by name.
private _plain = createHashMap;
private _named = createHashMap;

{
    private _key = toLowerANSI _x;
    private _prototype = toLowerANSI (EGVAR(core,prototypeOf) getOrDefault [_key, ""]);

    if (_prototype isEqualTo "") then {continue};

    if (([_x] call EFUNC(core,getKitLabel)) isEqualTo "") then {
        _plain set [_prototype, (_plain getOrDefault [_prototype, 0]) + 1];
    } else {
        _named set [_key, _x];
    };
} forEach _items;

private _fnc_dress = {
    params ["_row", "_class"];

    private _label = [_class] call EFUNC(core,getKitLabel);
    private _realName = [[_class] call EFUNC(core,getPrototype)] call EFUNC(core,getItemName);

    _ctrlList lnbSetText [[_row, 1], _label];
    _ctrlList lnbSetText [[_row, 2], "1"];
    _ctrlList lnbSetTooltip [[_row, 0], format ["%1\n%2\n%3", _label, _realName, _class]];
};

private _typeRows = createHashMap;
private _namedRows = createHashMap;
private _renamed = false;

// Backwards, so a deleted row does not move the ones still to come.
for "_row" from ((lnbSize _ctrlList) select 0) - 1 to 0 step -1 do {
    private _class = _ctrlList lnbData [_row, 0];
    private _key = toLowerANSI _class;

    switch (true) do {
        case (_key in EGVAR(core,needsConversion)): {
            private _count = _plain getOrDefault [_key, 0];
            private _typeName = [_class] call EFUNC(core,getTypeName);

            if (_typeName isNotEqualTo "") then {
                _ctrlList lnbSetText [[_row, 1], _typeName];
                _renamed = true;
            };

            _ctrlList lnbSetText [[_row, 2], str _count];
            GVAR(kitRowCounts) set [_key, _count];
            _typeRows set [_key, true];
        };
        case (_key in _named): {
            [_row, _class] call _fnc_dress;
            _namedRows set [_key, true];
            _renamed = true;
        };
        case (_key in EGVAR(core,prototypeOf)): {
            _ctrlList lnbDeleteRow _row;
        };
    };
};

// A named kit without a row yet gets one where its type has one - in this category, that is.
private _added = false;

{
    private _prototype = toLowerANSI (EGVAR(core,prototypeOf) get _x);

    if (_x in _namedRows || {!(_prototype in _typeRows)}) then {continue};

    private _row = _ctrlList lnbAddRow ["", "", "1"];
    _ctrlList lnbSetData [[_row, 0], _y];
    _ctrlList lnbSetPicture [[_row, 0], [_y] call EFUNC(core,getItemPicture)];
    _ctrlList lnbSetValue [[_row, 2], 1]; // one of a kind to ACE: "+" stays off
    [_row, _y] call _fnc_dress;
    _added = true;
} forEach _named;

// In among the others by ACE's own sort - which goes by the names the rows show, so a kit called
// "aaa" goes to the top.
if (_added || _renamed) then {
    [_display displayCtrl IDC_ACE_SORT_RIGHT] call ACEFUNC(arsenal,sortPanel);
};
