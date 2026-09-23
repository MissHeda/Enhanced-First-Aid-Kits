#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Puts the selected item into, or takes it out of, every kit of the selected type.
 *
 * Each kit is handled on its own: "+" adds to every kit that has room and leaves full ones alone,
 * "-" takes from every kit that has one. With Shift it is five per kit, as in ACE, capped by what
 * each kit has room for, may hold or holds.
 *
 * What each kit may take is its own rules' business (see adjustContents): what the mission lets
 * the arsenal change about it, and how many of the item its default contents allow.
 *
 * Only the staged copies change. They are written shortly after the last click, when the tab
 * closes or when the arsenal closes.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 * 1: Direction, -1 to take out, 1 to put in <NUMBER>
 * 2: Shift held <BOOL> (default: ACE Arsenal's shift state)
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001, 1] call efak_arsenal_fnc_buttonCargo;
 *
 * Public: No
 */

params [
    "_display",
    "_direction",
    ["_shift", missionNamespace getVariable [QACEGVAR(arsenal,shiftState), false]]
];

if (!GVAR(active) || {isNull _display}) exitWith {};

private _ctrl = _display displayCtrl IDC_EFAK_CONTENTS;
private _row = lnbCurSelRow _ctrl;

if (_row < 0) exitWith {};

private _instances = call FUNC(getSelectedKits);

// The arrow keys too: a kit that follows the defaults, or one the mission keeps as it is, is locked.
if (_instances isEqualTo [] || {GVAR(locked)}) exitWith {};

private _class = _ctrl lnbData [_row, 0];
private _key = toLowerANSI _class;
private _amount = [1, 5] select (_shift isEqualTo true);

(GVAR(rowInfo) getOrDefault [_key, [false, ""]]) params ["_addable"];

// The row's tooltip says why, and "+" is off already. Whether the arsenal offers the item at all is
// the one thing only the row knows.
if (_direction > 0 && {!_addable}) exitWith {};

private _changed = 0;

{
    private _contents = GVAR(pending) get toLowerANSI _x;
    if (isNil "_contents") then {continue};

    if (([_contents, _class, _direction * _amount, _x] call FUNC(adjustContents)) != 0) then {
        _changed = _changed + 1;
    };
} forEach _instances;

if (_changed > 0) then {
    call FUNC(queueFlush);
};

[_display] call FUNC(updateContents);
