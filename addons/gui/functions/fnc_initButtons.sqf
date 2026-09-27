#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Finds the pieces of a window's buttons and stretchable panels by their class names -
 * <Name>_Mid/_Lft/_Rgt (the surface's rectangles), <Name>_TL/_TR/_BL/_BR (its corners), <Name>_Icon,
 * <Name>_Label and <Name>_Hit - and paints every button in its normal look.
 *
 * Buttons are the names in GVAR(buttonStyles), which fnc_paintButton recolours. Stretchable panels are
 * those in GVAR(stretchPanels), which fnc_setPanelRect moves and sizes: the fills of the bars, the
 * lists' selection bars and scroll bar thumbs. Each keeps the place the config gave it.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_initButtons;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

private _buttons = createHashMap;
private _panels = createHashMap;
private _rects = ["Mid", "Lft", "Rgt"];
private _corners = ["TL", "TR", "BL", "BR"];

{
    private _name = ctrlClassName _x;
    private _split = _name find "_";

    if (_split < 1) then {continue};

    private _base = _name select [0, _split];
    private _part = _name select [_split + 1];

    if (_base in GVAR(buttonStyles)) then {
        // [rectangles, corners, icons, labels, hit area]
        private _entry = _buttons getOrDefault [_base, [[], [], [], [], controlNull], true];

        switch (true) do {
            case (_part in _rects): {(_entry select 0) pushBack _x};
            case (_part in _corners): {(_entry select 1) pushBack _x};
            case (_part isEqualTo "Icon"): {(_entry select 2) pushBack _x};
            case (_part isEqualTo "Label"): {(_entry select 3) pushBack _x};
            case (_part isEqualTo "Hit"): {_entry set [4, _x]};
        };
    };

    if (_base in GVAR(stretchPanels) && {_part in _rects || {_part in _corners}}) then {
        (_panels getOrDefault [_base, createHashMap, true]) set [_part, _x];
    };
} forEach (allControls _display);

// Each panel as the config placed it - [pieces by part, [x, y, w, h], corner width, corner height] -
// so a bar's fill knows its full length. No panel may get smaller than its four corners.
private _placed = createHashMap;

{
    private _topLeft = _y getOrDefault ["TL", controlNull];
    private _bottomRight = _y getOrDefault ["BR", controlNull];

    if (isNull _topLeft || {isNull _bottomRight}) then {continue};

    (ctrlPosition _topLeft) params ["_x0", "_y0", "_cap", "_rise"];
    (ctrlPosition _bottomRight) params ["_x1", "_y1", "_w1", "_h1"];

    _placed set [_x, [_y, [_x0, _y0, _x1 + _w1 - _x0, _y1 + _h1 - _y0], _cap, _rise]];
} forEach _panels;

_display setVariable [QGVAR(buttons), _buttons];
_display setVariable [QGVAR(buttonActive), createHashMap];
_display setVariable [QGVAR(panels), _placed];

{
    [_display, _x, BUTTON_NORMAL] call FUNC(paintButton);
} forEach (keys _buttons);
