#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills a bar: its fill panel (fnc_initButtons) grows from the left with round ends, as long as the
 * bar is full, and disappears when it is empty. By default its colour says how full it is - its own
 * colour, amber from LEVEL_WARN, red from LEVEL_FULL.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Fill panel name <STRING>
 * 2: How full, 0 to 1 <NUMBER>
 * 3: Colour <ARRAY>
 * 4: Turn amber and red when nearly full <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "LoadFill", 0.4, [0.29, 0.61, 0.96, 1]] call efak_gui_fnc_setBar;
 *
 * Public: No
 */

disableSerialization;

params ["_display", "_base", "_ratio", "_color", ["_levels", true]];

private _panel = (_display getVariable [QGVAR(panels), createHashMap]) getOrDefault [_base, []];

if (_panel isEqualTo []) exitWith {};

_panel params ["_pieces", "_full"];

if (_levels) then {
    _color = switch (true) do {
        case (_ratio >= LEVEL_FULL): {S_LOSS};
        case (_ratio >= LEVEL_WARN): {S_ACCENT};
        default {_color};
    };
};

{
    if (_x in ["TL", "TR", "BL", "BR"]) then {
        _y ctrlSetTextColor _color;
    } else {
        _y ctrlSetBackgroundColor _color;
    };
} forEach _pieces;

_full params ["_left", "_top", "_width", "_height"];

[
    _display,
    _base,
    [[], [_left, _top, _width * (_ratio min 1), _height]] select (_ratio > 0)
] call FUNC(setPanelRect);
