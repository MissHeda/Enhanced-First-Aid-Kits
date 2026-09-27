#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Brings the contents list up to date with what is staged: the count on every row, which rows can
 * still be added, the load bar and the clear button.
 *
 * A row shows "3" when every kit of the type holds three, and "1-3" when they differ. Like ACE's
 * container lists, a row is dimmed when "+" would do nothing - here, when no kit has room for one
 * more, every kit already holds as many as its default contents allow, or the item cannot be added
 * at all.
 *
 * The load bar shows the fullest kit, since that is the one that stops "+" first.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_updateContents;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active) || {isNull _display}) exitWith {};

private _ctrl = _display displayCtrl IDC_EFAK_CONTENTS;
private _instances = call FUNC(getSelectedKits);

// Per kit: lowercase class -> count, and the space it has left.
private _counts = [];
private _free = [];
private _fullest = -1;
private _fullestUsed = 0;
private _fullestCapacity = 0;

{
    private _contents = GVAR(pending) getOrDefault [toLowerANSI _x, []];
    private _map = createHashMap;

    {
        _x params ["_class", "_count"];
        private _key = toLowerANSI _class;
        _map set [_key, (_map getOrDefault [_key, 0]) + _count];
    } forEach _contents;

    _counts pushBack _map;

    private _capacity = [_x] call EFUNC(core,getCapacity);
    private _used = [_contents] call EFUNC(core,getUsedCapacity);
    _free pushBack (_capacity - _used);

    private _ratio = if (_capacity > 0) then {_used / _capacity} else {1};
    if (_ratio > _fullest) then {
        _fullest = _ratio;
        _fullestUsed = _used;
        _fullestCapacity = _capacity;
    };
} forEach _instances;

private _hasItems = false;

// Informational only: the tab still edits what the kit holds right now, but whoever loads a loadout
// with this kit type gets the defaults anyway.
private _forced = _instances isNotEqualTo [] && {[GVAR(selected)] call EFUNC(core,isContentsForced)};

for "_row" from 0 to ((lnbSize _ctrl) select 0) - 1 do {
    private _class = _ctrl lnbData [_row, 0];
    private _key = toLowerANSI _class;
    private _mass = ([_class] call FUNC(getItemInfo)) select 3;

    (GVAR(rowInfo) getOrDefault [_key, [false, ""]]) params ["_addable", ["_reason", ""], ["_limit", -1]];

    private _min = -1;
    private _max = 0;

    {
        private _count = _x getOrDefault [_key, 0];
        _min = [_min min _count, _count] select (_min < 0);
        _max = _max max _count;
    } forEach _counts;

    _min = _min max 0;
    if (_max > 0) then {_hasItems = true};

    // One more has to fit into the same kit twice over: in its space, and under the most of it the
    // default contents allow. Packed kits count by type, the way core counts them.
    private _canAdd = false;
    private _belowLimit = false;

    if (_addable) then {
        {
            private _below = _limit < 0 || {([GVAR(pending) getOrDefault [toLowerANSI _x, []], _class] call EFUNC(core,countItem)) < _limit};

            if (_below) then {
                _belowLimit = true;

                if ((_free select _forEachIndex) + MASS_EPSILON >= _mass) then {
                    _canAdd = true;
                };
            };
        } forEach _instances;
    };

    // A kit that follows the defaults, or that the mission keeps as it is, is locked - every row as
    // greyed as one that cannot go in.
    private _alpha = [0.25, 1] select (_canAdd && {!GVAR(locked)});

    _ctrl lnbSetText [[_row, 2], [format ["%1-%2", _min, _max], str _max] select (_min == _max)];
    _ctrl lnbSetColor [[_row, 1], [1, 1, 1, _alpha]];
    _ctrl lnbSetColor [[_row, 2], [1, 1, 1, _alpha]];

    // The same count and masses the pouch shows, on hover, rebuilt with the count so it never lags
    // behind a click. Each number sits under the word that says what it is.
    private _table = [
        [LELSTRING(core,Tooltip_Amount), LELSTRING(core,Tooltip_Mass), LELSTRING(core,Tooltip_TotalMass)],
        [format ["%1x", _max], str ((round (_mass * 100)) / 100), str ((round (_mass * _max * 100)) / 100)]
    ] call EFUNC(core,formatColumns);

    private _tooltip = format [
        "%1\n%2\n\n%3\n%4",
        ([_class] call FUNC(getItemInfo)) select 1,
        _class,
        _table select 0,
        _table select 1
    ];

    // Anything about the row goes under the numbers, after a blank line.
    private _notes = [];

    if (!_addable && {_reason isNotEqualTo ""}) then {
        _notes pushBack _reason;
    };

    // Why "+" stops although the item may go in.
    if (_addable && {_limit >= 0} && {!_belowLimit}) then {
        _notes pushBack LELSTRING(core,Error_DefaultsReached);
    };

    // A kit the mission keeps as it is says so as the reason above already, and unticking the box
    // would not unlock it.
    if (GVAR(locked) && {GVAR(editing) != EDIT_NOTHING}) then {
        _notes pushBack LLSTRING(Hint_Locked);
    };

    if (_forced) then {
        _notes pushBack LLSTRING(Hint_Forced);
    };

    if (_notes isNotEqualTo []) then {
        _tooltip = format ["%1\n\n%2", _tooltip, _notes joinString "\n"];
    };

    {
        _ctrl lnbSetTooltip [[_row, _x], _tooltip];
    } forEach [0, 1, 2];
};

// Items without mass still count as something to clear.
if (!_hasItems) then {
    _hasItems = _counts findIf {count _x > 0} != -1;
};

private _formatMass = {
    str ((round (_this * 100)) / 100)
};

// Like ACE's weight box: the number on its own, the word next to it is the label.
private _loadText = if (_instances isEqualTo []) then {""} else {
    format ["%1/%2", _fullestUsed call _formatMass, _fullestCapacity call _formatMass]
};

(_display displayCtrl IDC_EFAK_LOAD_BAR) progressSetPosition ((_fullest max 0) min 1);
(_display displayCtrl IDC_EFAK_LOAD_TEXT) ctrlSetText _loadText;

// Shown only while there is something to take out, like ACE's "remove all".
GVAR(hasItems) = _hasItems;

private _clear = _display displayCtrl IDC_EFAK_CLEAR;
_clear ctrlSetFade 0;
_clear ctrlShow (_hasItems && {ctrlShown (_display displayCtrl IDC_ACE_MENUBAR)});
// A locked kit cannot be cleared either. "Remove only" can: emptying is taking out.
_clear ctrlEnable (_hasItems && !GVAR(locked));
_clear ctrlCommit FADE_DELAY;

[_ctrl, lnbCurSelRow _ctrl] call FUNC(onContentSelected);
