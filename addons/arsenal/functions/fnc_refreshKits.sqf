#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Reads the kits the arsenal's unit carries and redraws the kit list, keeping the selected type.
 *
 * One row per kit type, however many of it the unit carries. Kits that are still being turned into
 * instances get a greyed row of their own, since there is nothing to edit on them yet.
 *
 * A kit the mission does not let the arsenal change is greyed the same way, but stays selectable:
 * its contents can still be looked at. Each row's tooltip says what the tab may do with it.
 *
 * New kits are staged from their stored contents, kits that are gone take their staged edits with
 * them, and kits that stay keep what the tab has changed on them.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_arsenal_fnc_refreshKits;
 *
 * Public: No
 */

private _display = findDisplay IDD_ACE_ARSENAL;

if (!GVAR(active) || {isNull _display}) exitWith {};

private _ctrl = _display displayCtrl IDC_EFAK_KIT_LIST;
private _unit = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

// Until the server's copy has arrived every kit reads as empty, and writing that back would wipe
// them. Nothing gets staged before then.
private _synced = EGVAR(core,contentsSynced);

private _groups = if (_synced) then {[_unit] call FUNC(getKitGroups)} else {[]};
GVAR(groups) = _groups;

private _carried = createHashMap;

{
    _x params ["", "_instances"];

    {
        private _key = toLowerANSI _x;
        _carried set [_key, _x];

        if !(_key in GVAR(pending)) then {
            private _contents = [_x] call EFUNC(core,getContents);
            GVAR(base) set [_key, _contents];
            GVAR(pending) set [_key, +_contents];
        };
    } forEach _instances;
} forEach _groups;

// A kit that left the inventory does not get written: its instance could be handed to someone
// else's kit next, and it would arrive with these contents.
{
    if !(_x in _carried) then {
        GVAR(base) deleteAt _x;
        GVAR(pending) deleteAt _x;
    };
} forEach (keys GVAR(pending));

GVAR(classNames) = _carried;

lbClear _ctrl;

private _fnc_notice = {
    params ["_text"];

    private _index = _ctrl lbAdd _text;
    _ctrl lbSetData [_index, ""];
    _ctrl lbSetValue [_index, ROW_NOTICE];
    _ctrl lbSetColor [_index, COLOR_GREYED];
};

switch (true) do {
    case (!_synced): {
        [LLSTRING(Row_Loading)] call _fnc_notice;
    };
    case (_groups isEqualTo []): {
        [["rowNoKits"] call FUNC(getText)] call _fnc_notice;
    };
};

// Kits of one type are numbered in list order, so two IFAKs read as "IFAK #1" and "IFAK #2".
private _numbers = createHashMap;

private _firstKits = -1;
private _selectedKits = -1;
private _selectedPreparing = -1;

{
    _x params ["_prototype", "_instances", "_preparing", ["_container", ""]];

    private _containerName = switch (_container) do {
        case "uniform": {LLSTRING(Container_Uniform)};
        case "vest": {LLSTRING(Container_Vest)};
        case "backpack": {LLSTRING(Container_Backpack)};
        default {""};
    };

    private _name = [_prototype] call EFUNC(core,getKitName);
    private _picture = [_prototype] call EFUNC(core,getItemPicture);

    // Where the kit is, as the icon of ACE's own tab for that container, on the right of the row.
    private _containerIcon = switch (_container) do {
        case "uniform": {"\A3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\Uniform_ca.paa"};
        case "vest": {"\A3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\Vest_ca.paa"};
        case "backpack": {"\A3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\Backpack_ca.paa"};
        default {""};
    };

    if (_instances isNotEqualTo []) then {
        private _typeKey = toLowerANSI ([_prototype] call EFUNC(core,getPrototype));
        private _number = (_numbers getOrDefault [_typeKey, 0]) + 1;
        _numbers set [_typeKey, _number];

        private _label = _name;

        // Kits with a name a player gave them (efak_core_fnc_setKitLabel) go by it; what they are is
        // in the tooltip.
        private _names = (_instances apply {[_x] call EFUNC(core,getKitLabel)}) select {_x isNotEqualTo ""};
        if (_names isNotEqualTo []) then {
            _label = _names joinString ", ";
        };

        private _editing = [_prototype] call EFUNC(core,getArsenalEditing);
        private _note = switch (_editing) do {
            case EDIT_NOTHING: {LLSTRING(Hint_EditNothing)};
            case EDIT_REMOVE: {LLSTRING(Hint_EditRemove)};
            default {LLSTRING(Row_Kits_Changes)};
        };

        private _index = _ctrl lbAdd _label;
        _ctrl lbSetData [_index, _prototype];
        _ctrl lbSetValue [_index, ROW_KITS];
        _ctrl lbSetPicture [_index, _picture];
        _ctrl lbSetTooltip [_index, format [LLSTRING(Row_Kits_Tooltip), _name, _containerName, _note]];

        if (_containerIcon isNotEqualTo "") then {
            _ctrl lbSetPictureRight [_index, _containerIcon];
            _ctrl lbSetPictureRightColor [_index, [1, 1, 1, 0.75]];
            _ctrl lbSetPictureRightColorSelected [_index, [1, 1, 1, 1]];
        };

        if (_editing == EDIT_NOTHING) then {
            _ctrl lbSetColor [_index, COLOR_GREYED];
            _ctrl lbSetPictureColor [_index, COLOR_GREYED];
        };

        if (_firstKits < 0) then {_firstKits = _index};
        if (_prototype == GVAR(selected)) then {_selectedKits = _index};
    };

    if (_preparing > 0) then {
        private _index = _ctrl lbAdd format [LLSTRING(Row_Preparing), _preparing, _name];
        _ctrl lbSetData [_index, _prototype];
        _ctrl lbSetValue [_index, ROW_PREPARING];
        _ctrl lbSetPicture [_index, _picture];
        _ctrl lbSetColor [_index, COLOR_GREYED];
        _ctrl lbSetPictureColor [_index, COLOR_GREYED];
        _ctrl lbSetTooltip [_index, LLSTRING(Hint_Preparing)];

        if (_prototype == GVAR(selected)) then {_selectedPreparing = _index};
    };
} forEach _groups;

// Stay on the row that was selected. A greyed row that is gone because its kits are ready gives way
// to the real row of the same type, and only a type that is gone entirely falls back to the top.
private _order = if (GVAR(selectedPreparing)) then {
    [_selectedPreparing, _selectedKits, _firstKits, 0]
} else {
    [_selectedKits, _selectedPreparing, _firstKits, 0]
};

private _selectIndex = _order select (_order findIf {_x >= 0});

// Selecting a row redraws the contents through the list's own event, but only if the selection
// actually moved. When it did not, the contents are redrawn here.
GVAR(kitSelectionSeen) = false;
_ctrl lbSetCurSel _selectIndex;

if (!GVAR(kitSelectionSeen)) then {
    [_ctrl, lbCurSel _ctrl] call FUNC(onKitSelected);
};
