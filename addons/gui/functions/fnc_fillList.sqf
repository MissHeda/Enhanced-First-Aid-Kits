#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Fills one of the lists of the kit window: filtered by the search box, sorted by the sort boxes,
 * keeping the selection and the scroll position.
 *
 * Each row is the item name on the left, and on the right how much it changed since the window
 * was opened in front of the count - "(+3)  8x". The count keeps the accent colour; only the change
 * is coloured, green for a gain and red for a loss, so what is there and what happened read apart. A
 * row whose items all left this list stays as "(-3)  0x", greyed, so the player sees where things
 * went. The masses are in the tooltip.
 *
 * Sorting happens on the data, not on the control: list values only hold whole numbers, and a
 * bandage weighs 0.6.
 *
 * Every move redraws every list. Keeping the scroll position is what makes clicking one item
 * at a time down a long list bearable.
 *
 * Arguments:
 * 0: List control (ListNBox) <CONTROL>
 * 1: Entries <ARRAY> of [class, count]
 * 2: The same list when the window opened <HASHMAP> lowercase class -> [class, count]
 * 3: What the rows are, ROWS_KIT / ROWS_SOURCE / ROWS_CONTAINER / ROWS_GROUND <NUMBER>
 *    (default: ROWS_KIT)
 * 4: The place the entries are from, for how full opened magazines are (fnc_getPlaceCharges)
 *    <STRING> (default: "kit")
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, [["ACE_morphine", 2]], createHashMap] call efak_gui_fnc_fillList;
 *
 * Public: No
 */

disableSerialization;

params ["_ctrl", "_entries", "_baseline", ["_mode", ROWS_KIT], ["_place", "kit"]];

private _opened = [_place] call FUNC(getPlaceCharges);

// The lists along the bottom are narrow and have no selection bar: count and change only.
private _compact = _mode in [ROWS_CONTAINER, ROWS_GROUND];

private _selected = if (!_compact && {lnbCurSelRow _ctrl >= 0}) then {_ctrl lnbData [lnbCurSelRow _ctrl, 0]} else {""};
private _scroll = ctrlScrollValues _ctrl;

// What is here now, and everything that was here when the window opened but has gone since.
private _counts = createHashMap;
private _order = [];

{
    _x params ["_class", "_count"];

    private _key = toLowerANSI _class;

    if !(_key in _counts) then {_order pushBack _key};

    _counts set [_key, [_class, ((_counts getOrDefault [_key, [_class, 0]]) select 1) + _count]];
} forEach _entries;

{
    if !(_x in _counts) then {
        _order pushBack _x;
        _counts set [_x, [_y select 0, 0]];
    };
} forEach _baseline;

// With packing into this kit switched off, every row of the left list is greyed with that reason but
// still shown - an empty list would explain nothing.
private _packing = _mode isEqualTo ROWS_SOURCE && {[GVAR(kitClass)] call EFUNC(core,canPackInto)};

// In the kit and the list on the left, an opened magazine is a row of its own - "Painkillers (7/10)"
// next to the full ones - so it is clear which one moves. Its row carries "class|rounds".
private _split = _mode in [ROWS_KIT, ROWS_SOURCE];

// [sort key, name for ties, class, count, name, mass of one, mass of the stack, movable, reason,
//  change, row data]
private _rows = [];

{
    (_counts get _x) params ["_class", "_count"];

    if !([_class] call FUNC(matchesSearch)) then {continue};

    private _change = _count - ((_baseline getOrDefault [_x, [_class, 0]]) select 1);

    // The list things are packed from knows what may go into the kit: those rows are drawn normally,
    // the rest is either left out or greyed, depending on the "show all" box. A row that changed
    // while the window is open stays either way.
    private _allowed = true;
    private _reason = "";

    if (_mode isEqualTo ROWS_SOURCE) then {
        ([[], _class, 1, true] call FUNC(getKitRoom)) params ["_fits", "_why"];

        _allowed = _fits > 0;
        _reason = _why;
    };

    if (!_allowed && {_packing} && {!GVAR(showAll)} && {_change == 0}) then {continue};

    private _itemName = [_class] call EFUNC(core,getItemName);
    private _each = [_class] call EFUNC(core,getItemMass);
    private _openRounds = _opened getOrDefault [toLowerANSI _class, []];

    // [count, rounds] per row: the full ones (rounds -1), then the opened ones by how full they are.
    // Unsplit lists keep one row per class and say how full the opened ones are behind the name.
    private _parts = [[_count, -1]];

    if (_split && {_openRounds isNotEqualTo []}) then {
        private _full = _count - count _openRounds;
        _parts = [[_full, -1]] select {_full > 0 || {_count <= 0}};

        {
            private _rounds = _x;
            private _index = _parts findIf {(_x select 1) == _rounds};

            if (_index < 0) then {
                _parts pushBack [1, _rounds];
            } else {
                (_parts select _index) set [0, ((_parts select _index) select 0) + 1];
            };
        } forEach _openRounds;
    };

    private _size = [_class] call EFUNC(core,getMagazineSize);

    {
        _x params ["_partCount", "_rounds"];

        // The change since the window opened is the class's, shown once, on its first row.
        private _partChange = [0, _change] select (_forEachIndex == 0);

        // On a container only what arrived there can move on - the player's own gear stays put.
        private _movable = _partCount > 0 && {_allowed} && {_mode != ROWS_CONTAINER || {_change > 0}};

        private _name = switch (true) do {
            case (_rounds >= 0): {format ["%1 (%2/%3)", _itemName, _rounds, _size]};
            case (_split): {_itemName};
            // An opened pill bottle says how full it is: "Painkillers (7/10)".
            default {_itemName + ([_class, _openRounds] call EFUNC(core,formatCharges))};
        };
        private _stack = _each * _partCount;
        private _data = [_class, format ["%1|%2", _class, _rounds]] select (_rounds >= 0);

        private _key = switch (GVAR(sortMode)) do {
            case SORT_MASS: {_stack};
            case SORT_AMOUNT: {_partCount};
            default {toLower _name};
        };

        _rows pushBack [_key, toLower _name, _class, _partCount, _name, _each, _stack, _movable, _reason, _partChange, _data];
    } forEach _parts;
} forEach _order;

// Numbers descending are sorted as negative numbers ascending, so rows that tie still come out
// A to Z by name rather than Z to A.
if (GVAR(sortMode) != SORT_NAME && {!GVAR(sortAscending)}) then {
    {
        _x set [0, -(_x select 0)];
    } forEach _rows;

    _rows sort true;
} else {
    _rows sort GVAR(sortAscending);
};

private _fnc_mass = {
    str ((round (_this * 100)) / 100)
};

private _labels = [LELSTRING(core,Tooltip_Amount), LELSTRING(core,Tooltip_Mass), LELSTRING(core,Tooltip_TotalMass)];

lnbClear _ctrl;

{
    _x params ["", "", "_class", "_count", "_name", "_each", "_stack", "_movable", "_reason", "_change", "_data"];

    private _changeText = switch (true) do {
        case (_change > 0): {format ["(+%1)", _change]};
        case (_change < 0): {format ["(%1)", _change]};
        default {""};
    };

    private _row = _ctrl lnbAddRow [_name, _changeText];

    // The count right-aligned at the edge of the second column, the change in front of it.
    _ctrl lnbSetTextRight [[_row, 1], format ["%1x", _count]];

    private _color = [COLOR_GREYED, COLOR_NAME] select _movable;

    _ctrl lnbSetColor [[_row, 0], _color];
    _ctrl lnbSetColor [[_row, 1], [COLOR_LOSS, COLOR_GAIN] select (_change > 0)];
    _ctrl lnbSetColorRight [[_row, 1], [COLOR_GREYED, COLOR_COUNT] select _movable];

    // The same table as in the arsenal: what each number is on one line, the numbers centred under
    // it on the next.
    private _table = [_labels, [format ["%1x", _count], _each call _fnc_mass, _stack call _fnc_mass]] call EFUNC(core,formatColumns);
    private _tooltip = format ["%1\n%2\n\n%3\n%4", _name, _class, _table select 0, _table select 1];

    // Greyed rows say why they cannot move; what arrived on a container says where it can go.
    switch (true) do {
        case (_count <= 0): {_tooltip = format ["%1\n\n%2", _tooltip, LLSTRING(Row_Gone)]};
        case (_reason isNotEqualTo ""): {_tooltip = format ["%1\n\n%2", _tooltip, _reason]};
        case (_mode isEqualTo ROWS_CONTAINER && {_movable}): {_tooltip = format ["%1\n\n%2", _tooltip, LLSTRING(Preview_Movable)]};
    };

    // On both columns: the tooltip wherever the mouse is, and the class and the movable amount
    // wherever the engine reads a dragged row from. How many may move is all of it, only what
    // arrived on a container, or none; a drag picks up no more than that.
    private _value = [0, [_count, _change] select (_mode isEqualTo ROWS_CONTAINER)] select _movable;

    {
        _ctrl lnbSetData [[_row, _x], _data];
        _ctrl lnbSetValue [[_row, _x], _value];
        _ctrl lnbSetTooltip [[_row, _x], _tooltip];
    } forEach [0, 1];

    private _picture = [_class] call EFUNC(core,getItemPicture);

    if (_picture isNotEqualTo "") then {
        _ctrl lnbSetPicture [[_row, 0], _picture];

        // A row with nothing left is greyed as a whole.
        if (_count <= 0) then {
            _ctrl lnbSetPictureColor [[_row, 0], COLOR_GREYED];
        };
    };

    if (_data isEqualTo _selected) then {
        _ctrl lnbSetCurSelRow _row;
    };
} forEach _rows;

// Rows along the bottom are dragged or double clicked, never picked.
if (_compact) then {
    _ctrl lnbSetCurSelRow -1;
};

_ctrl ctrlSetScrollValues _scroll;
