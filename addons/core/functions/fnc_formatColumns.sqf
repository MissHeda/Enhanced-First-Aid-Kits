#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Lays out a small table for a tooltip: a row of labels, and under each label its value, both
 * centred in their column.
 *
 * Tooltips are drawn in a proportional font and only know plain text, so the columns are lined up
 * with spaces, from a rough table of how wide each character is. Close enough to read "3x" as
 * sitting under "Amount" - not a pixel grid.
 *
 * Arguments:
 * 0: Labels <ARRAY of STRINGs>
 * 1: Values, one per label <ARRAY of STRINGs>
 *
 * Return Value:
 * [label line, value line] <ARRAY>
 *
 * Example:
 * [["Amount", "Mass"], ["3x", "2.5"]] call efak_core_fnc_formatColumns;
 *
 * Public: No
 */

params ["_labels", "_values"];

// Widths in em, roughly those of the tooltip font. Anything not listed counts as a lowercase letter.
if (isNil QGVAR(charWidths)) then {
    GVAR(charWidths) = createHashMapFromArray [
        [" ", 0.23], [".", 0.24], [",", 0.22], ["-", 0.3], ["x", 0.44],
        ["0", 0.5], ["1", 0.5], ["2", 0.5], ["3", 0.5], ["4", 0.5],
        ["5", 0.5], ["6", 0.5], ["7", 0.5], ["8", 0.5], ["9", 0.5],
        ["i", 0.22], ["l", 0.22], ["j", 0.22], ["f", 0.28], ["t", 0.28], ["r", 0.3],
        ["m", 0.75], ["w", 0.66],
        ["A", 0.6], ["G", 0.62], ["M", 0.72], ["T", 0.54], ["W", 0.78], ["I", 0.26]
    ];
};

private _fnc_width = {
    private _width = 0;
    {
        _width = _width + (GVAR(charWidths) getOrDefault [_x, 0.47]);
    } forEach (_this splitString "");
    _width
};

private _space = GVAR(charWidths) get " ";
private _gap = 4 * _space;

private _fnc_padTo = {
    params ["_line", "_lineWidth", "_target"];

    private _count = round ((_target - _lineWidth) / _space) max 0;
    for "_i" from 1 to _count do {_line = _line + " "};

    [_line, _lineWidth + _count * _space]
};

private _labelLine = "";
private _labelWidth = 0;
private _valueLine = "";
private _valueWidth = 0;
private _column = 0;

{
    private _label = _x;
    private _value = _values param [_forEachIndex, ""];
    private _labelW = _label call _fnc_width;
    private _valueW = _value call _fnc_width;
    private _columnW = _labelW max _valueW;

    ([_labelLine, _labelWidth, _column + (_columnW - _labelW) / 2] call _fnc_padTo) params ["_l", "_lw"];
    _labelLine = _l + _label;
    _labelWidth = _lw + _labelW;

    ([_valueLine, _valueWidth, _column + (_columnW - _valueW) / 2] call _fnc_padTo) params ["_v", "_vw"];
    _valueLine = _v + _value;
    _valueWidth = _vw + _valueW;

    _column = _column + _columnW + _gap;
} forEach _labels;

[_labelLine, _valueLine]
