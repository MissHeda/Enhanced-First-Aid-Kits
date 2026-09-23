#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Draws the row along the bottom of the kit window: the ground, the uniform, the vest and the
 * backpack as they are right now.
 *
 * Every container lists all it holds, with how full it is. What changed since the window was opened
 * carries "(+3)" or "(-2)"; an item taken out completely stays on the list as 0 so it is clear where
 * it came from. The ground list is the pile this window puts things into - the player drags things
 * onto it on purpose, and back off it.
 *
 * Arguments:
 * 0: Kit window <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_fillPreview;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

// A column header: the picture, if there is one, and the words, centred together.
private _fnc_header = {
    params ["_ctrl", "_picture", "_text", "_color"];

    private _image = ["", format ["<img image='%1' size='1.3'/> ", _picture]] select (_picture isNotEqualTo "");

    _ctrl ctrlSetStructuredText parseText format [
        "<t align='center' valign='middle' color='%1'>%2%3</t>", _color, _image, _text
    ];
};

// ----- Uniform, vest, backpack -----

{
    _x params ["_key", "_listIdc", "_headerIdc", "_barIdc", "_label", "_container", "_worn", "_cfg"];

    private _header = _display displayCtrl _headerIdc;
    private _bar = _display displayCtrl _barIdc;

    if (isNull _container) then {
        [_header, "", format ["%1 - %2", _label, LLSTRING(Preview_None)], "#8C8C8C"] call _fnc_header;
        _bar progressSetPosition 0;
    } else {
        private _max = maxLoad _container;
        private _load = (load _container) * _max;

        [
            _header,
            getText (configFile >> _cfg >> _worn >> "picture"),
            format ["%1   %2 / %3", _label, round _load, round _max],
            "#CCCCCC"
        ] call _fnc_header;

        _bar progressSetPosition (if (_max > 0) then {(_load / _max) min 1} else {0});
    };

    [
        _display displayCtrl _listIdc,
        [_key] call FUNC(getEntries),
        GVAR(baseline) getOrDefault [_key, createHashMap],
        ROWS_CONTAINER,
        _key
    ] call FUNC(fillList);
} forEach [
    ["uniform", IDC_PREVIEW_LIST_UNIFORM, IDC_PREVIEW_HEADER_UNIFORM, IDC_PREVIEW_BAR_UNIFORM, LELSTRING(core,Container_Uniform), uniformContainer ACE_player, uniform ACE_player, "CfgWeapons"],
    ["vest", IDC_PREVIEW_LIST_VEST, IDC_PREVIEW_HEADER_VEST, IDC_PREVIEW_BAR_VEST, LELSTRING(core,Container_Vest), vestContainer ACE_player, vest ACE_player, "CfgWeapons"],
    ["backpack", IDC_PREVIEW_LIST_BACKPACK, IDC_PREVIEW_HEADER_BACKPACK, IDC_PREVIEW_BAR_BACKPACK, LELSTRING(core,Container_Backpack), backpackContainer ACE_player, backpack ACE_player, "CfgVehicles"]
];

// ----- The ground -----

private _ground = ["ground"] call FUNC(getEntries);
private _count = 0;

{
    _count = _count + (_x select 1);
} forEach _ground;

[
    _display displayCtrl IDC_LIST_GROUND,
    _ground,
    GVAR(baseline) getOrDefault ["ground", createHashMap],
    ROWS_GROUND,
    "ground"
] call FUNC(fillList);

private _header = _display displayCtrl IDC_HEADER_GROUND;

(_display displayCtrl IDC_PREVIEW_BAR_GROUND) progressSetPosition parseNumber (_count > 0);

if (_count > 0) then {
    [_header, "", format ["%1   %2", LLSTRING(Preview_Ground), _count], "#FFB84D"] call _fnc_header;
} else {
    [_header, "", LLSTRING(Preview_Ground), "#8C8C8C"] call _fnc_header;
};
