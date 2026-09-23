#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * A kit's contents as they are listed to the player: one row per item, but an opened magazine - a
 * pill bottle, an oxygen tank no longer full - apart from the full ones, one row per fill.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 *
 * Return Value:
 * [[class, count, which, name], ...] <ARRAY> - which, as fnc_unpackItem takes it: -1 an item or a
 * magazine of one round, 0 the full ones, more than 0 the opened ones with that many rounds; the
 * name says how full: "Painkillers (7/10)"
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitRows;
 *
 * Public: Yes
 */

params ["_kitClass"];

private _rows = [];

{
    _x params ["_class", "_count"];

    private _name = [_class] call FUNC(getItemName);
    private _size = [_class] call FUNC(getMagazineSize);

    if (_size <= 1) then {
        _rows pushBack [_class, _count, -1, _name];
        continue;
    };

    private _opened = [_kitClass, _class] call FUNC(getCharges);
    private _full = _count - count _opened;

    if (_full > 0) then {
        _rows pushBack [_class, _full, 0, _name];
    };

    private _fills = [];

    {
        private _rounds = _x;
        private _index = _fills findIf {(_x select 0) == _rounds};

        if (_index < 0) then {
            _fills pushBack [_rounds, 1];
        } else {
            (_fills select _index) set [1, ((_fills select _index) select 1) + 1];
        };
    } forEach _opened;

    {
        _x params ["_rounds", "_n"];
        _rows pushBack [_class, _n, _rounds, format ["%1 (%2/%3)", _name, _rounds, _size]];
    } forEach _fills;
} forEach ([_kitClass] call FUNC(getContents));

_rows
