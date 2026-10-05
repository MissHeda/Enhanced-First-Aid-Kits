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

// A card's header: the picture - the worn item's own, or an icon in the colour of the words - the
// name on the left and the amount on the right.
private _fnc_header = {
    params ["_pictureIdc", "_headerIdc", "_valueIdc", "_picture", "_isIcon", "_text", "_color", ["_amount", ""]];

    private _image = _display displayCtrl _pictureIdc;

    _image ctrlSetText _picture;
    _image ctrlSetTextColor ([[1, 1, 1, 1], _color] select _isIcon);

    private _header = _display displayCtrl _headerIdc;

    _header ctrlSetText _text;
    _header ctrlSetTextColor _color;

    (_display displayCtrl _valueIdc) ctrlSetText _amount;
};

// ----- Uniform, vest, backpack -----

{
    _x params ["_key", "_listIdc", "_pictureIdc", "_headerIdc", "_valueIdc", "_fill", "_label", "_container", "_worn", "_cfg"];

    if (isNull _container) then {
        // Nothing worn there: the game's own picture of the empty slot.
        [_pictureIdc, _headerIdc, _valueIdc, format ["\A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_%1_gs.paa", _key], true, format ["%1 - %2", _label, LLSTRING(Preview_None)], S_MUTED] call _fnc_header;
        [_display, _fill, 0, S_INFO] call FUNC(setBar);
    } else {
        private _max = maxLoad _container;
        private _load = (load _container) * _max;

        [
            _pictureIdc, _headerIdc, _valueIdc,
            getText (configFile >> _cfg >> _worn >> "picture"),
            false,
            _label,
            S_TEXT,
            format ["%1 / %2", round _load, round _max]
        ] call _fnc_header;

        [_display, _fill, if (_max > 0) then {_load / _max} else {0}, S_INFO] call FUNC(setBar);
    };

    [
        _display displayCtrl _listIdc,
        [_key] call FUNC(getEntries),
        GVAR(baseline) getOrDefault [_key, createHashMap],
        ROWS_CONTAINER,
        _key
    ] call FUNC(fillList);
} forEach [
    ["uniform", IDC_PREVIEW_LIST_UNIFORM, IDC_PREVIEW_PICTURE_UNIFORM, IDC_PREVIEW_HEADER_UNIFORM, IDC_PREVIEW_VALUE_UNIFORM, "UniformFill", LELSTRING(core,Container_Uniform), uniformContainer ACE_player, uniform ACE_player, "CfgWeapons"],
    ["vest", IDC_PREVIEW_LIST_VEST, IDC_PREVIEW_PICTURE_VEST, IDC_PREVIEW_HEADER_VEST, IDC_PREVIEW_VALUE_VEST, "VestFill", LELSTRING(core,Container_Vest), vestContainer ACE_player, vest ACE_player, "CfgWeapons"],
    ["backpack", IDC_PREVIEW_LIST_BACKPACK, IDC_PREVIEW_PICTURE_BACKPACK, IDC_PREVIEW_HEADER_BACKPACK, IDC_PREVIEW_VALUE_BACKPACK, "BackpackFill", LELSTRING(core,Container_Backpack), backpackContainer ACE_player, backpack ACE_player, "CfgVehicles"]
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

// No limit on the ground: its bar is full in the accent colour while anything lies there.
[_display, "GroundFill", parseNumber (_count > 0), S_ACCENT, false] call FUNC(setBar);

if (_count > 0) then {
    [IDC_PREVIEW_PICTURE_GROUND, IDC_HEADER_GROUND, IDC_PREVIEW_VALUE_GROUND, UI_TEX(icon_ground_ca), true, LLSTRING(Preview_Ground), S_ACCENT, str _count] call _fnc_header;
} else {
    [IDC_PREVIEW_PICTURE_GROUND, IDC_HEADER_GROUND, IDC_PREVIEW_VALUE_GROUND, UI_TEX(icon_ground_ca), true, LLSTRING(Preview_Ground), S_MUTED] call _fnc_header;
};
