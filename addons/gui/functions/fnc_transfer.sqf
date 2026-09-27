#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Moves items between two lists of the kit window, right now.
 *
 * A move is clamped to what the other side can actually hold, so dragging 200 bandages into a
 * vest with room for twelve moves twelve and leaves the rest where they were. Asking again once
 * nothing more fits on the player is taken as "then put them on the ground", which is the only way
 * items end up on the ground without being dragged there.
 *
 * Only what came out of the kit or off the ground while the window is open can be placed on one of
 * the uniform, vest and backpack lists or moved on from one - the player's own gear stays where it
 * is. A double click there puts it back into the kit.
 *
 * Into the kit, the items leave where they are first and the kit is written with what actually
 * arrived. Out of it, they go where they are going first and the kit is written with what actually
 * left. Either way the kit is written once, and nothing is lost on the way.
 *
 * Arguments:
 * 0: Source list IDC <NUMBER>
 * 1: Row index <NUMBER>
 * 2: Amount, or AMOUNT_ALL / AMOUNT_HALF <NUMBER> (default: AMOUNT_ALL)
 * 3: Destination list IDC, -1 for the obvious one <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [IDC_LIST_KIT, 0, 1] call efak_gui_fnc_transfer;
 *
 * Public: No
 */

disableSerialization;

params ["_sourceIdc", "_index", ["_amount", AMOUNT_ALL], ["_destIdc", -1]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display || {_index < 0}) exitWith {};

// An opened magazine's own row carries "class|rounds" (fnc_fillList): it moves just those.
(((_display displayCtrl _sourceIdc) lnbData [_index, 0]) splitString "|") params [["_class", ""], ["_rowRounds", ""]];

if (_class isEqualTo "") exitWith {};

_rowRounds = [-1, parseNumber _rowRounds] select (_rowRounds isNotEqualTo "");

// Out of the kit goes to the left, everything else into the kit - something on the ground or on a
// container was most likely taken out of the kit a moment ago.
if (_destIdc < 0) then {
    _destIdc = [IDC_LIST_KIT, IDC_LIST_INVENTORY] select (_sourceIdc isEqualTo IDC_LIST_KIT);
};

if (_destIdc isEqualTo _sourceIdc) exitWith {};

private _places = createHashMapFromArray [
    [IDC_LIST_INVENTORY, call FUNC(activeSource)],
    [IDC_LIST_KIT, "kit"],
    [IDC_LIST_GROUND, "ground"],
    [IDC_PREVIEW_LIST_UNIFORM, "uniform"],
    [IDC_PREVIEW_LIST_VEST, "vest"],
    [IDC_PREVIEW_LIST_BACKPACK, "backpack"]
];

private _from = _places getOrDefault [_sourceIdc, ""];
private _to = _places getOrDefault [_destIdc, ""];

// The left list on the ground tab and the ground card are the same pile.
if (_from isEqualTo "" || {_to isEqualTo ""} || {_from isEqualTo _to}) exitWith {};

// The kit may have left since the lists were drawn - taken out of a crate by somebody else, emptied
// and removed on another machine. Nothing moves into or out of a kit that is not there any more.
if (
    "kit" in [_from, _to] &&
    {!([GVAR(owner), GVAR(kitClass)] call EFUNC(core,holderHasKit)) || {(toLowerANSI GVAR(kitClass)) in GVAR(removedKits)}}
) exitWith {
    call FUNC(refreshPouch);
};

private _worn = ["uniform", "vest", "backpack"];

GVAR(message) = "";

// The player's own gear stays where it is: a container only takes what comes out of the kit, off the
// ground or off another container.
if (_to in _worn && {!(_from in (_worn + ["kit", "ground"]))}) exitWith {
    GVAR(message) = LLSTRING(Preview_OnlyKitItems);
    call FUNC(refreshPouch);
};

// Off a container and onto the list on the left: it is in the inventory already.
if (_from in _worn && {_to isEqualTo "inventory"}) exitWith {};

// How many of this row may move. Off a container that is only what arrived there - the "+3".
private _stack = [[_from] call FUNC(getEntries), _class] call FUNC(listCount);

if (_from in _worn) then {
    private _before = (((GVAR(baseline) getOrDefault [_from, createHashMap]) getOrDefault [toLowerANSI _class, [_class, 0]]) select 1);

    _stack = _stack min (_stack - _before);
};

// The kit and the list on the left show opened magazines apart from the full ones: the row is either
// the full ones or the opened ones of one fill, and only those move.
private _size = [_class] call EFUNC(core,getMagazineSize);
private _splitRow = _size > 1 && {_sourceIdc in [IDC_LIST_KIT, IDC_LIST_INVENTORY]};

if (_splitRow) then {
    private _openedHere = ([_from] call FUNC(getPlaceCharges)) getOrDefault [toLowerANSI _class, []];

    _stack = if (_rowRounds < 0) then {_stack - count _openedHere} else {{_x == _rowRounds} count _openedHere};
};

// The rounds of each magazine that moves: those of the row, or on a list of whole classes the
// emptiest first (fnc_pickRounds).
private _fnc_rounds = {
    params ["_n", ["_fullestFirst", false]];

    if !(_splitRow) exitWith {[_from, _class, _n, _fullestFirst] call FUNC(pickRounds)};

    private _rounds = [];

    for "_i" from 1 to _n do {
        _rounds pushBack ([_size, _rowRounds] select (_rowRounds >= 0));
    };

    _rounds
};

if (_stack <= 0) exitWith {
    if (_from in _worn) then {
        GVAR(message) = LLSTRING(Preview_OnlyKitItems);
    };

    call FUNC(refreshPouch);
};

private _want = switch (_amount) do {
    case AMOUNT_ALL: {_stack};
    case AMOUNT_HALF: {(floor (_stack / 2)) max 1};
    default {_amount};
};

_want = (floor _want) min _stack;

if (_want <= 0) exitWith {};

// ----- Into the kit -----

if (_to isEqualTo "kit") exitWith {
    ([[GVAR(kitClass)] call EFUNC(core,getContents), _class, _want] call FUNC(getKitRoom)) params ["_fits", "_why"];

    private _packing = [GVAR(kitClass)] call EFUNC(core,canPackInto);

    // Packing off: only what came out goes back, and only as full as it came out - the full ones as
    // full ones, an opened one with the rounds it had (the kit as the window first showed it).
    if (_splitRow && {!_packing}) then {
        private _kitKey = toLowerANSI GVAR(kitClass);
        private _startOpened = ((GVAR(kitStartCharges) getOrDefault [_kitKey, []]) select {(_x select 0) == _class}) apply {_x select 1};
        private _nowOpened = [GVAR(kitClass), _class] call EFUNC(core,getCharges);

        private _back = if (_rowRounds < 0) then {
            (([GVAR(kitStart) getOrDefault [_kitKey, []], _class] call EFUNC(core,countItem)) - count _startOpened)
                - (([[GVAR(kitClass)] call EFUNC(core,getContents), _class] call EFUNC(core,countItem)) - count _nowOpened)
        } else {
            ({_x == _rowRounds} count _startOpened) - ({_x == _rowRounds} count _nowOpened)
        };

        if (_back < _fits) then {
            _fits = _back max 0;
            _why = LELSTRING(core,Error_PackingDisabled);
        };
    };

    // Where the kit takes back only what came out of it and the list does not say which one - off a
    // container - the fullest go first, so nobody swaps an empty bottle for a full one.
    private _rounds = [_fits, !_packing || {_from in _worn}] call _fnc_rounds;
    private _moved = [_from, _class, _fits, _rounds] call FUNC(takeItems);

    [_to, _class, _moved, _rounds select [0, _moved]] call FUNC(putItems);

    GVAR(message) = _why;

    call FUNC(refreshPouch);
};

// ----- Anywhere else -----

// The magazines that leave, with their rounds: put down as full as they were, then taken exactly.
private _rounds = [_want] call _fnc_rounds;

([_to, _class, _want, _rounds] call FUNC(putItems)) params ["_placed", "_dropped"];

// Nothing more fits on the left and it came out of the kit: this is the second attempt, so take it
// as a decision to put them down rather than as another failed move.
if (_placed + _dropped <= 0 && {_from isEqualTo "kit"} && {_to in ["inventory", "crate"]}) then {
    _to = "ground";
    _placed = ([_to, _class, _want, _rounds] call FUNC(putItems)) select 0;
};

private _moved = _placed + _dropped;

[_from, _class, _moved, _rounds select [0, _moved]] call FUNC(takeItems);

private _name = [_class] call EFUNC(core,getItemName);
private _labels = createHashMapFromArray [
    ["uniform", LELSTRING(core,Container_Uniform)],
    ["vest", LELSTRING(core,Container_Vest)],
    ["backpack", LELSTRING(core,Container_Backpack)]
];

GVAR(message) = switch (true) do {
    case (_dropped > 0): {format [LLSTRING(DroppedUnexpected), _dropped]};
    case (_to isEqualTo "ground"): {format [LLSTRING(Moved_Ground), _moved, _name]};
    case (_moved >= _want): {""};
    case (_to in _worn): {format [LLSTRING(Preview_NoRoomIn), _labels get _to]};
    case (_moved <= 0): {format [LLSTRING(NoRoom), _name]};

    // Only worth telling somebody to move it again when moving it again would put it down. Off the
    // ground or off a container it is not coming out of the kit.
    case (_from isEqualTo "kit"): {
        format [[LLSTRING(Partial_Inventory), LLSTRING(Partial_CrateKit)] select (_to isEqualTo "crate"), _moved, _name]
    };
    case (_to isEqualTo "crate"): {format [LLSTRING(Partial_Crate), _moved, _name]};
    default {format [LLSTRING(Partial_Simple), _moved, _name]};
};

call FUNC(refreshPouch);
