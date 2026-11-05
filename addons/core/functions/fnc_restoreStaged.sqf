#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Puts the items fnc_stageItems laid out back into their kits. An item that is no longer in the
 * inventory was used up (or handed on, dropped, packed by hand), so its kit is charged one.
 *
 * Waits while an ACE progress bar runs: digging, cutting a fence, defusing - those actions check
 * their item until they are done.
 *
 * Arguments:
 * 0: Put back right now, without waiting <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call efak_core_fnc_restoreStaged;
 *
 * Public: No
 */

params [["_now", false]];

if (GVAR(staged) isEqualTo []) exitWith {};

if (!_now) exitWith {
    private _generation = GVAR(stagedGeneration);

    // The action has already run when ACE reports the menu closed; the short wait is for those
    // that start a progress bar in a frame of their own.
    [{
        [{
            isNull (uiNamespace getVariable ["ace_common_dlgProgress", displayNull])
        }, {
            // The menu was opened again in the meantime - this one is not needed any more.
            if (_this == GVAR(stagedGeneration)) then {[true] call FUNC(restoreStaged)};
        }, _this] call CBA_fnc_waitUntilAndExecute;
    }, _generation, 0.5] call CBA_fnc_waitAndExecute;
};

private _unit = GVAR(stagedUnit);
private _staged = GVAR(staged);

GVAR(staged) = [];
GVAR(stagedUnit) = objNull;

private _carried = (items _unit) apply {toLowerANSI _x};

{
    _x params ["_kitClass", "_itemClass"];

    private _index = _carried find (toLowerANSI _itemClass);

    // Still there: back it goes, the kit never lost it.
    if (_index > -1) then {
        _carried deleteAt _index;
        _unit removeItem _itemClass;
        continue;
    };

    // Gone: the kit pays for it.
    private _contents = [_kitClass] call FUNC(getContents);
    private _entry = _contents findIf {(_x select 0) == _itemClass};

    if (_entry < 0) then {continue};

    private _stored = (_contents select _entry) select 1;

    if (_stored <= 1) then {
        _contents deleteAt _entry;
    } else {
        _contents set [_entry, [_itemClass, _stored - 1]];
    };

    [_kitClass, _contents] call FUNC(setContents);

    if (_contents isEqualTo []) then {
        [_unit, _kitClass] call FUNC(removeKit);
    };
} forEach _staged;

ace_common_uniqueItemsCache = nil;
