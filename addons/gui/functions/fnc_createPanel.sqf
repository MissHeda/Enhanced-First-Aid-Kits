#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Creates a rounded panel at run time - the seven pieces EFAK_PANEL declares in config (RscBase.hpp):
 * three rectangles and four corners, on the screen's pixels and meeting without overlapping, so a
 * see-through panel shows no seams.
 *
 * In a controls group the position is relative to the group, which must itself sit on the pixels.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Controls group to create it in, or controlNull for the display <CONTROL>
 * 2: Position [x, y, w, h] <ARRAY>
 * 3: Corner radius, as a height <NUMBER>
 * 4: Colour <ARRAY>
 *
 * Return Value:
 * [rectangles, corners] <ARRAY>
 *
 * Example:
 * [_display, controlNull, [0.1, 0.1, 0.3, 0.2], 0.01, [0.1, 0.1, 0.1, 1]] call efak_gui_fnc_createPanel;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_group", "_position", "_radius", "_color"];
_position params ["_left", "_top", "_width", "_height"];

// Edges on whole pixels, corners a whole number of pixels big. Inside a group the origin is the
// group's corner rather than the screen's.
private _fnc_snapX = {round (_this / pixelW) * pixelW};
private _fnc_snapY = {round (_this / pixelH) * pixelH};
private _originX = [safezoneX, 0] select !isNull _group;
private _originY = [safezoneY, 0] select !isNull _group;
private _x0 = _originX + ((_left - _originX) call _fnc_snapX);
private _y0 = _originY + ((_top - _originY) call _fnc_snapY);
private _x1 = _originX + ((_left + _width - _originX) call _fnc_snapX);
private _y1 = _originY + ((_top + _height - _originY) call _fnc_snapY);
private _cap = floor (SQUARE(_radius) / pixelW) * pixelW;
private _rise = floor (_radius / pixelH) * pixelH;
private _fnc_create = {
    params ["_class", "_rect"];

    private _ctrl = if (isNull _group) then {
        _display ctrlCreate [_class, -1]
    } else {
        _display ctrlCreate [_class, -1, _group]
    };

    _ctrl ctrlSetPosition _rect;
    _ctrl ctrlCommit 0;
    _ctrl
};

private _rects = [
    [_x0 + _cap, _y0, _x1 - _x0 - 2 * _cap, _y1 - _y0],
    [_x0, _y0 + _rise, _cap, _y1 - _y0 - 2 * _rise],
    [_x1 - _cap, _y0 + _rise, _cap, _y1 - _y0 - 2 * _rise]
] apply {
    private _ctrl = ["EFAK_PanelRect", _x] call _fnc_create;
    _ctrl ctrlSetBackgroundColor _color;
    _ctrl
};

private _corners = [
    [UI_TEX(corner_tl_ca), [_x0, _y0, _cap, _rise]],
    [UI_TEX(corner_tr_ca), [_x1 - _cap, _y0, _cap, _rise]],
    [UI_TEX(corner_bl_ca), [_x0, _y1 - _rise, _cap, _rise]],
    [UI_TEX(corner_br_ca), [_x1 - _cap, _y1 - _rise, _cap, _rise]]
] apply {
    _x params ["_texture", "_rect"];

    private _ctrl = ["EFAK_PanelCorner", _rect] call _fnc_create;
    _ctrl ctrlSetText _texture;
    _ctrl ctrlSetTextColor _color;
    _ctrl
};

[_rects, _corners]
