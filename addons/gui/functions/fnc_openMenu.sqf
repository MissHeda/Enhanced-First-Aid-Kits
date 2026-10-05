#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Opens a drop down menu under one of the kit window's fields, in place of the engine's combo boxes:
 * a rounded panel with a row per choice, each with its picture, the current one ticked. The row under
 * the mouse lights up, a click picks it. A click anywhere else or Escape closes the menu; eight rows
 * show at a time, more scroll.
 *
 * The menu is created when it opens and deleted when it closes (fnc_closeMenu); the field it belongs
 * to is painted as chosen while it is open.
 *
 * Arguments:
 * 0: Kit window <DISPLAY>
 * 1: The field's button name, see fnc_initButtons <STRING>
 * 2: Choices, each [text, picture, picture is an icon to tint (default: false)] <ARRAY>
 * 3: Current choice, -1 for none <NUMBER>
 * 4: Called with [row, arguments] once a row is picked <CODE>
 * 5: Arguments for it <ANY> (default: [])
 * 6: Least width <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "Sort", [["Name", ""], ["Mass", ""]], 0, {GVAR(sortMode) = _this select 0}] call efak_gui_fnc_openMenu;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_base", "_choices", "_current", "_onPick", ["_arguments", []], ["_minWidth", 0], ["_afterX", -1]];

[_display] call FUNC(closeMenu);

private _field = ((_display getVariable [QGVAR(buttons), createHashMap]) getOrDefault [_base, []]) param [4, controlNull];

if (isNull _field || {_choices isEqualTo []}) exitWith {};

(ctrlPosition _field) params ["_fieldX", "_fieldY", "_fieldW", "_fieldH"];

private _count = count _choices;
private _scrolls = _count > MENU_ROWS;
private _w = _fieldW max _minWidth;
private _h = (_count min MENU_ROWS) * MENU_ROW_H + MENU_PAD * 2;

// Centred under its field and kept inside the window; above the field when there is no room below.
private _x0 = ((_fieldX + (_fieldW - _w) / 2) max (POUCH_X + PAD)) min (POUCH_X + POUCH_W - PAD - _w);
private _y0 = _fieldY + _fieldH + MENU_GAP;

if (_y0 + _h > POUCH_Y + POUCH_VISIBLE_H) then {
    _y0 = _fieldY - MENU_GAP - _h;
};

// On the screen's pixels, so the see-through rows inside meet their edges exactly (fnc_createPanel).
_x0 = SNAP_X(_x0);
_y0 = SNAP_Y(_y0);
private _inner = SNAP_H(MENU_PAD);

private _created = [];

// Under the menu, over everything else: a click there closes it.
private _catcher = _display ctrlCreate ["EFAK_MenuCatcher", -1];
_catcher ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
_catcher ctrlCommit 0;
_created pushBack _catcher;

// A pixel of light edge around the surface, so the menu stands apart from what it covers.
{
    _x params ["_rect", "_radius", "_color"];

    ([_display, controlNull, _rect, _radius, _color] call FUNC(createPanel)) params ["_rects", "_corners"];
    _created append _rects;
    _created append _corners;
} forEach [
    [[_x0 - pixelW, _y0 - pixelH, _w + 2 * pixelW, _h + 2 * pixelH], MENU_RADIUS + pixelH, S_MENU_EDGE],
    [[_x0, _y0, _w, _h], MENU_RADIUS, S_MENU]
];

private _group = _display ctrlCreate ["EFAK_MenuGroup", -1];
// Exactly as high as its rows - and two pixels more where they all fit, so a row rounded down onto
// the next pixel does not make it scroll.
_group ctrlSetPosition [_x0, _y0 + _inner, _w, (_count min MENU_ROWS) * MENU_ROW_H + ([2 * pixelH, 0] select _scrolls)];
_group ctrlCommit 0;
_created pushBack _group;

// Rows inside the group, whose corner is 0, 0. Room for the scroll bar when there is one.
private _padX = SQUARE(MENU_PAD);
private _rowW = _w - _padX * 2 - ([0, MENU_SCROLL_W] select _scrolls);
private _pictures = (_choices findIf {(_x param [1, ""]) isNotEqualTo ""}) >= 0;
private _checkW = SQUARE(MENU_CHECK_H);
private _inset = SQUARE(ROW * 0.35);

{
    _x params ["_text", ["_picture", ""], ["_isIcon", false], ["_after", ""], ["_afterIsIcon", false]];

    private _top = _forEachIndex * MENU_ROW_H;
    private _chosen = _forEachIndex == _current;
    private _row = [_display, _group, [_padX, _top, _rowW, MENU_ROW_H], MENU_ROW_RADIUS, S_CLEAR] call FUNC(createPanel);

    _created append ((_row select 0) + (_row select 1));

    private _textX = _padX + _inset;

    // Every row keeps the room for a picture once one of them has one, so the words line up.
    if (_pictures) then {
        if (_picture isNotEqualTo "") then {
            private _image = _display ctrlCreate ["EFAK_Icon", -1, _group];
            _image ctrlSetPosition [_textX, _top + (MENU_ROW_H - MENU_PIC_H) / 2, SQUARE(MENU_PIC_H), MENU_PIC_H];
            _image ctrlSetText _picture;
            _image ctrlSetTextColor ([[1, 1, 1, 1], S_TEXT2] select _isIcon);
            _image ctrlCommit 0;
            _created pushBack _image;
        };

        _textX = _textX + SQUARE(MENU_PIC_H) + SQUARE(ROW * 0.3);
    };

    private _labelW = _padX + _rowW - _textX - _checkW - _inset * 1.5;
    private _afterW = [0, SQUARE(MENU_PIC_H)] select (_after isNotEqualTo "");
    private _afterGap = SQUARE(ROW * 0.25);
    private _font = ["RobotoCondensed", "RobotoCondensedBold"] select _chosen;

    // A picture behind the words (where a kit is) sits in a column of its own: centred on _afterX
    // when the caller gives one (the kit switcher: under its pencil), else right before the check.
    // The words end before it and are shortened to fit.
    private _afterLeft = if (_afterX >= 0) then {
        _afterX - _x0 - _afterW / 2
    } else {
        _padX + _rowW - _inset - _checkW - _afterGap - _afterW
    };

    if (_afterW > 0) then {
        _labelW = _afterLeft - _afterGap - _textX;
        _text = [_text, _labelW, _font, MENU_TEXT] call FUNC(fitText);
    };

    private _label = _display ctrlCreate ["EFAK_Label", -1, _group];
    _label ctrlSetPosition [_textX, _top, _labelW, MENU_ROW_H];
    _label ctrlSetFont _font;
    _label ctrlSetFontHeight MENU_TEXT;
    _label ctrlSetText _text;
    _label ctrlSetTextColor ([S_TEXT, S_ACCENT] select _chosen);
    _label ctrlCommit 0;
    _created pushBack _label;

    if (_afterW > 0) then {
        private _behind = _display ctrlCreate ["EFAK_Icon", -1, _group];
        _behind ctrlSetPosition [
            _afterLeft,
            _top + (MENU_ROW_H - MENU_PIC_H) / 2,
            _afterW,
            MENU_PIC_H
        ];
        _behind ctrlSetText _after;
        _behind ctrlSetTextColor ([[1, 1, 1, 1], S_TEXT2] select _afterIsIcon);
        _behind ctrlCommit 0;
        _created pushBack _behind;
    };

    if (_chosen) then {
        private _check = _display ctrlCreate ["EFAK_Icon", -1, _group];
        _check ctrlSetPosition [_padX + _rowW - _inset - _checkW, _top + (MENU_ROW_H - MENU_CHECK_H) / 2, _checkW, MENU_CHECK_H];
        _check ctrlSetText UI_TEX(icon_check_ca);
        _check ctrlSetTextColor S_ACCENT;
        _check ctrlCommit 0;
        _created pushBack _check;
    };

    // Last, so it is on top of the row and catches the mouse.
    private _hit = _display ctrlCreate ["EFAK_MenuRow", -1, _group];
    _hit ctrlSetPosition [_padX, _top, _rowW, MENU_ROW_H];
    _hit ctrlCommit 0;
    _hit setVariable [QGVAR(menuRow), [_forEachIndex, _row]];
    _created pushBack _hit;
} forEach _choices;

// The current choice in view.
if (_scrolls && {_current >= MENU_ROWS}) then {
    _group ctrlSetScrollValues [((_current - MENU_ROWS + 1) / (_count - MENU_ROWS)) min 1, -1];
};

// Its tooltip would pop up over the menu while the mouse is still on the field.
private _tooltip = ctrlTooltip _field;
_field ctrlSetTooltip "";

_display setVariable [QGVAR(menu), [_base, _created, _onPick, _arguments, _tooltip]];

[_display, _base, true, true] call FUNC(setButton);
