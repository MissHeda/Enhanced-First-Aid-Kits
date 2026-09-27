#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Moves and sizes a panel registered by fnc_initButtons, and shows or hides it: its seven pieces are
 * laid out again around the new rectangle, on the screen's pixels like EFAK_PANEL. Never smaller than
 * its four corners. Does nothing where the panel already is, so it can run every frame.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Panel name <STRING>
 * 2: Rectangle [x, y, w, h], or [] to hide the panel <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "ThumbKit", [0.9, 0.2, 0.005, 0.1]] call efak_gui_fnc_setPanelRect;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_base", "_rect"];

private _panel = (_display getVariable [QGVAR(panels), createHashMap]) getOrDefault [_base, []];

if (_panel isEqualTo []) exitWith {};

// Where it was put last time, [] for hidden.
private _placed = _display getVariable [QGVAR(panelRects), createHashMap];

if (_base in _placed && {(_placed get _base) isEqualTo _rect}) exitWith {};

_placed set [_base, _rect];
_display setVariable [QGVAR(panelRects), _placed];

_panel params ["_pieces", "", "_cap", "_rise"];

if (_rect isEqualTo []) exitWith {
    {
        _y ctrlShow false;
    } forEach _pieces;
};

_rect params ["_left", "_top", "_width", "_height"];

private _x0 = SNAP_X(_left);
private _y0 = SNAP_Y(_top);
private _x1 = _x0 + (SNAP_W(_width) max (_cap * 2));
private _y1 = _y0 + (SNAP_H(_height) max (_rise * 2));

{
    _x params ["_part", "_position"];

    private _ctrl = _pieces getOrDefault [_part, controlNull];

    _ctrl ctrlSetPosition _position;
    _ctrl ctrlCommit 0;
    _ctrl ctrlShow true;
} forEach [
    ["Mid", [_x0 + _cap, _y0, _x1 - _x0 - 2 * _cap, _y1 - _y0]],
    ["Lft", [_x0, _y0 + _rise, _cap, _y1 - _y0 - 2 * _rise]],
    ["Rgt", [_x1 - _cap, _y0 + _rise, _cap, _y1 - _y0 - 2 * _rise]],
    ["TL", [_x0, _y0, _cap, _rise]],
    ["TR", [_x1 - _cap, _y0, _cap, _rise]],
    ["BL", [_x0, _y1 - _rise, _cap, _rise]],
    ["BR", [_x1 - _cap, _y1 - _rise, _cap, _rise]]
];
