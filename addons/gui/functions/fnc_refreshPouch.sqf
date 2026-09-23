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

// A crate that was destroyed is no source any more.
if (!isNull GVAR(crate) && {!alive GVAR(crate)}) then {
    GVAR(crate) = objNull;
};

if (isNull GVAR(crate)) then {
    GVAR(leftSource) = SOURCE_INVENTORY;
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

// The kit's own picture in front of its list, like the containers along the bottom.
private _kitPicture = [_kitClass] call EFUNC(core,getItemPicture);

(_display displayCtrl IDC_HEADER_KIT) ctrlSetStructuredText parseText format [
    "<t align='center' valign='middle' color='#CCCCCC'>%1%2</t>",
    ["", format ["<img image='%1' size='1.3'/> ", _kitPicture]] select (_kitPicture isNotEqualTo ""),
    LLSTRING(Header_Kit)
];

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

// Tabs. The one you are on is switched off rather than recoloured: a shortcut button draws its
// label through a subcontrol, so dimming it is the one highlight that reliably shows.
private _crate = GVAR(crate);
private _onCrate = GVAR(leftSource) isEqualTo SOURCE_CRATE;
private _tabInventory = _display displayCtrl IDC_TAB_INVENTORY;
private _tabCrate = _display displayCtrl IDC_TAB_CRATE;

_tabInventory ctrlSetText LLSTRING(Header_Inventory);
_tabInventory ctrlEnable _onCrate;

_tabCrate ctrlSetText (
    if (isNull _crate) then {
        LLSTRING(Header_Crate_None)
    } else {
        format ["%1 (%2)", LLSTRING(Header_Crate), count (["crate"] call FUNC(getEntries))]
    }
);
_tabCrate ctrlEnable (!isNull _crate && {!_onCrate});

(_display displayCtrl IDC_CAPACITY_TEXT) ctrlSetText format [
    "%1 %2 / %3 %4", LLSTRING(Capacity), round _used, round _capacity, LLSTRING(MassUnit)
];
(_display displayCtrl IDC_CAPACITY_BAR) progressSetPosition (
    if (_capacity > 0) then {(_used / _capacity) min 1} else {0}
);

// What the player can still carry, so the two bars answer the two questions somebody has open
// in front of them: will it fit in the kit, and will it fit on me.
([GVAR(leftSource)] call FUNC(getSourceLoad)) params ["_load", "_maxLoad"];

(_display displayCtrl IDC_LOAD_TEXT) ctrlSetText format [
    "%1 %2 / %3 %4",
    [LLSTRING(Load), LLSTRING(Header_Crate)] select _onCrate,
    round _load, round _maxLoad, LLSTRING(MassUnit)
];
(_display displayCtrl IDC_LOAD_BAR) progressSetPosition (
    if (_maxLoad > 0) then {(_load / _maxLoad) min 1} else {0}
);

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

// One line, used for the controls until something has to be said about a move.
private _hint = _display displayCtrl IDC_HINT;

if (GVAR(message) isEqualTo "") then {
    _hint ctrlSetStructuredText parseText LLSTRING(Hint_Controls);
} else {
    _hint ctrlSetStructuredText parseText format ["<t color='#FFB84D'>%1</t>", GVAR(message)];
};

// Packing is switched on or off per type of kit. Even off, what came out of the kit while the window
// is open may go back, so the buttons stay usable; the rows say what may go in and why not.
private _packAll = _display displayCtrl IDC_BUTTON_PACKALL;

_packAll ctrlSetTooltip ([LLSTRING(PackAll_Tooltip), LLSTRING(PackAll_Tooltip_Defaults)] select
    ([_kitClass, "limitToDefaults", false] call EFUNC(core,getKitSetting)));
