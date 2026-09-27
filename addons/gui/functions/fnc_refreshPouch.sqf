#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Redraws the kit window: the kit switcher, every list, both bars and the message line.
 *
 * Everything is read from the kit, the player and the crate as they are right now - every move is
 * applied the moment it is made, so there is nothing else to draw from. What changed since the
 * window was opened comes from the snapshot fnc_takeBaseline took.
 *
 * The kit on screen can be gone by the time this runs - emptied and removed, dropped, packed into
 * another kit, or taken by somebody else. The window then moves on to the next kit it can reach, and
 * closes when there is none.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_refreshPouch;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

// A crate that was destroyed is no source any more - the second tab is the ground from then on.
if (!isNull GVAR(crate) && {!alive GVAR(crate)}) then {
    GVAR(crate) = objNull;
};

private _kits = call FUNC(getReachableKits);
private _kitKey = toLowerANSI GVAR(kitClass);
private _current = _kits findIf {(toLowerANSI (_x select 1)) isEqualTo _kitKey};

if (_current < 0) exitWith {
    if (_kits isEqualTo []) exitWith {
        _display closeDisplay 2;
    };

    (_kits select 0) params ["_holder", "_kitClass"];

    [_holder, _kitClass, LLSTRING(KitGone)] call FUNC(selectKit);
};

// The kit may have changed hands without leaving reach - from the player into the crate, say.
GVAR(owner) = (_kits select _current) select 0;

[_display, _kits] call FUNC(fillKitSwitch);

private _kitClass = GVAR(kitClass);
private _contents = [_kitClass] call EFUNC(core,getContents);
private _capacity = [_kitClass] call EFUNC(core,getCapacity);
private _used = [_contents] call EFUNC(core,getUsedCapacity);

// Over the kit list: the kit's own picture and what the list is, and how many things are in it.
private _kitPicture = [_kitClass] call EFUNC(core,getItemPicture);
private _items = 0;

{
    _items = _items + (_x select 1);
} forEach _contents;

(_display displayCtrl IDC_HEADER_KIT_PICTURE) ctrlSetText _kitPicture;
(_display displayCtrl IDC_HEADER_KIT) ctrlSetText toUpper LLSTRING(Header_Kit);
(_display displayCtrl IDC_HEADER_KIT_COUNT) ctrlSetText format [LLSTRING(Items_Count), _items];

// Artwork behind the lists, when the mission has any. The kit picture comes from the registry so
// every kit type can look like itself; the left one is one setting for all of them.
{
    _x params ["_idc", "_texture"];

    private _ctrl = _display displayCtrl _idc;

    if (_texture isEqualTo "") then {
        _ctrl ctrlShow false;
    } else {
        _ctrl ctrlSetText _texture;
        _ctrl ctrlSetTextColor [1, 1, 1, 0.55];
        _ctrl ctrlShow true;
    };
} forEach [
    [IDC_BG_SOURCE, ""],
    [IDC_BG_KIT, ([_kitClass] call EFUNC(core,getKitData)) param [KIT_BACKGROUND, ""]]
];

// Tabs: a segmented switch, the side you are on raised. The second is what the player looks into -
// a crate, a vehicle, or the ground - with its icon and how many things are in it.
private _crate = GVAR(crate);
private _onCrate = GVAR(leftSource) isEqualTo SOURCE_CRATE;
private _second = ["ground", "crate"] select !isNull _crate;
private _secondName = switch (true) do {
    case (isNull _crate): {LLSTRING(Preview_Ground)};
    case (_crate isKindOf "AllVehicles"): {LLSTRING(Header_Vehicle)};
    default {LLSTRING(Header_Crate)};
};
private _secondCount = 0;

{
    _secondCount = _secondCount + (_x select 1);
} forEach ([_second] call FUNC(getEntries));

(_display displayCtrl IDC_TAB_CRATE_LABEL) ctrlSetText format ["%1 (%2)", _secondName, _secondCount];

{
    _x ctrlSetText ([UI_TEX(icon_ground_ca), UI_TEX(icon_crate_ca)] select !isNull _crate);
} forEach ((((_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault ["TabCrate", []]) param [2, []]));

[_display, "TabInventory", true, !_onCrate] call FUNC(setButton);
[_display, "TabCrate", true, _onCrate] call FUNC(setButton);

// The meters under the lists: what it is on the left, how much on the right, and a bar that turns
// amber when nearly full and red when full (fnc_setBar).
private _fnc_meter = {
    params ["_textIdc", "_valueIdc", "_fill", "_label", "_value", "_max", "_color"];

    (_display displayCtrl _textIdc) ctrlSetText _label;
    (_display displayCtrl _valueIdc) ctrlSetText format ["%1 / %2 %3", round _value, round _max, LLSTRING(MassUnit)];

    [_display, _fill, if (_max > 0) then {_value / _max} else {0}, _color] call FUNC(setBar);
};

[IDC_CAPACITY_TEXT, IDC_CAPACITY_VALUE, "CapacityFill", LLSTRING(Capacity), _used, _capacity, S_GAIN] call _fnc_meter;

// What the player can still carry, so the two bars answer the two questions somebody has open
// in front of them: will it fit in the kit, and will it fit on me. The ground has no limit: how many
// things lie there, and no bar.
if (_onCrate && {isNull _crate}) then {
    (_display displayCtrl IDC_LOAD_TEXT) ctrlSetText _secondName;
    (_display displayCtrl IDC_LOAD_VALUE) ctrlSetText format [LLSTRING(Items_Count), _secondCount];
    [_display, "LoadFill", 0, S_INFO] call FUNC(setBar);
} else {
    ([GVAR(leftSource)] call FUNC(getSourceLoad)) params ["_load", "_maxLoad"];

    [IDC_LOAD_TEXT, IDC_LOAD_VALUE, "LoadFill", [LLSTRING(Load), _secondName] select _onCrate, _load, _maxLoad, S_INFO] call _fnc_meter;
};

// The switch for the left list, and the way the lists are sorted.
(_display displayCtrl IDC_SHOW_ALL_ICON) ctrlSetText ([UI_TEX(toggle_off_ca), UI_TEX(toggle_on_ca)] select GVAR(showAll));
(_display displayCtrl IDC_SORT_DIR_ICON) ctrlSetText ([UI_TEX(icon_sort_desc_ca), UI_TEX(icon_sort_asc_ca)] select GVAR(sortAscending));

private _left = call FUNC(activeSource);

[_display displayCtrl IDC_LIST_KIT, _contents, GVAR(baseline) getOrDefault ["kit", createHashMap], ROWS_KIT, "kit"] call FUNC(fillList);
[
    _display displayCtrl IDC_LIST_INVENTORY,
    [_left] call FUNC(getEntries),
    GVAR(baseline) getOrDefault [_left, createHashMap],
    ROWS_SOURCE,
    _left
] call FUNC(fillList);
[_display] call FUNC(fillPreview);

// The selection bars and scroll bars at once, not a frame late.
[_display] call FUNC(updateLists);

// Two lines on the controls until something has to be said about a move, in the middle of the strip
// under the window. Structured text starts at the top of its control, so the control is moved down by
// half of what the words leave free - measured from where the config put it.
private _hint = _display displayCtrl IDC_HINT;
private _box = _hint getVariable [QGVAR(box), []];

if (_box isEqualTo []) then {
    _box = ctrlPosition _hint;
    _hint setVariable [QGVAR(box), _box];
};

_box params ["_hintX", "_hintY", "_hintW", "_hintH"];

_hint ctrlSetPosition _box;
_hint ctrlCommit 0;

if (GVAR(message) isEqualTo "") then {
    _hint ctrlSetStructuredText parseText LLSTRING(Hint_Controls);
} else {
    _hint ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", HEX_ACCENT, GVAR(message)];
};

private _free = ((_hintH - ctrlTextHeight _hint) / 2) max 0;

_hint ctrlSetPosition [_hintX, _hintY + _free, _hintW, _hintH - _free];
_hint ctrlCommit 0;

// Packing is switched on or off per type of kit. Even off, what came out of the kit while the window
// is open may go back, so the buttons stay usable; the rows say what may go in and why not.
private _packAll = _display displayCtrl IDC_BUTTON_PACKALL;

_packAll ctrlSetTooltip ([LLSTRING(PackAll_Tooltip), LLSTRING(PackAll_Tooltip_Defaults)] select
    ([_kitClass, "limitToDefaults", false] call EFUNC(core,getKitSetting)));
