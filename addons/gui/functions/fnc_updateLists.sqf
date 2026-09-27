#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Draws the scroll bars and the selection bars of the kit window's lists, every frame (the handler in
 * fnc_openPouch). The engine's own are hidden (EFAK_List): its scroll bar stops short of both ends,
 * and its selection bar is cut off before the count while the list scrolls.
 *
 * The thumb runs down the right edge of the list, in the strip the engine keeps for its scroll bar -
 * which still does the scrolling - from the top of the card to its bottom. The selection bar is round
 * and reaches to the thumb. Both follow the list's scroll position, which the engine reports as 0 to 1
 * of how far it can scroll.
 *
 * Arguments:
 * 0: Kit window <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_updateLists;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

private _thumbW = SQUARE(THUMB_W);
private _inset = SQUARE(THUMB_INSET);

// While a row is dragged, the wheel counts items (fnc_onDragAmount) - a list the wheel scrolled
// anyway goes back to where it stood when the drag began.
if (GVAR(dragging)) then {
    {
        _x params ["_idc", "_scroll"];

        private _list = _display displayCtrl _idc;

        if ((ctrlScrollValues _list) isNotEqualTo _scroll) then {
            _list ctrlSetScrollValues _scroll;
        };
    } forEach GVAR(dragScroll);
};

{
    _x params ["_idc", "_thumb", "_select", "_rowH", "_trackTop", "_trackBottom"];

    private _ctrl = _display displayCtrl _idc;

    (ctrlPosition _ctrl) params ["_listX", "_listY", "_listW", "_listH"];

    private _contentH = ((lnbSize _ctrl) select 0) * _rowH;
    private _range = (_contentH - _listH) max 0;
    private _scroll = ((ctrlScrollValues _ctrl) select 0) max 0;
    private _thumbX = _listX + _listW - _inset - _thumbW;

    // The thumb: as long as the share of the list that shows, and where the list stands.
    if (_range > 0) then {
        private _trackH = _trackBottom - _trackTop;
        private _thumbH = ((_trackH * _listH / _contentH) max THUMB_MIN_H) min _trackH;

        [_display, _thumb, [_thumbX, _trackTop + _scroll * (_trackH - _thumbH), _thumbW, _thumbH]] call FUNC(setPanelRect);
    } else {
        [_display, _thumb, []] call FUNC(setPanelRect);
    };

    if (_select isEqualTo "") then {continue};

    // The selection bar over the selected row, cut to the part of it that shows. Too little left of
    // it at an edge for the round ends, and it goes.
    private _row = lnbCurSelRow _ctrl;
    private _rect = [];

    if (_row >= 0 && {_row < ((lnbSize _ctrl) select 0)}) then {
        private _top = _listY + _row * _rowH - _scroll * _range;
        private _shownTop = _top max _listY;
        private _shownBottom = (_top + _rowH) min (_listY + _listH);
        private _right = [_listX + _listW, _thumbX - SQUARE(SELECT_GAP)] select (_range > 0);

        if (_shownBottom - _shownTop >= SELECT_RADIUS * 2) then {
            _rect = [_listX, _shownTop, _right - _listX, _shownBottom - _shownTop];
        };
    };

    [_display, _select, _rect] call FUNC(setPanelRect);
} forEach [
    [IDC_LIST_INVENTORY, "ThumbInventory", "SelectInventory", LIST_ROW, LIST_Y + THUMB_END, LIST_Y + LIST_H - THUMB_END],
    [IDC_LIST_KIT, "ThumbKit", "SelectKit", LIST_ROW, LIST_Y + THUMB_END, LIST_Y + LIST_H - THUMB_END],
    [IDC_LIST_GROUND, "ThumbGround", "", LIST_ROW * 0.9, PREVIEW_LIST_Y, PREVIEW_Y + PREVIEW_H - THUMB_END],
    [IDC_PREVIEW_LIST_UNIFORM, "ThumbUniform", "", LIST_ROW * 0.9, PREVIEW_LIST_Y, PREVIEW_Y + PREVIEW_H - THUMB_END],
    [IDC_PREVIEW_LIST_VEST, "ThumbVest", "", LIST_ROW * 0.9, PREVIEW_LIST_Y, PREVIEW_Y + PREVIEW_H - THUMB_END],
    [IDC_PREVIEW_LIST_BACKPACK, "ThumbBackpack", "", LIST_ROW * 0.9, PREVIEW_LIST_Y, PREVIEW_Y + PREVIEW_H - THUMB_END]
];
