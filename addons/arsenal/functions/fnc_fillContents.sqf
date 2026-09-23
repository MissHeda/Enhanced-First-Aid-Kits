#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Draws the contents list for the selected kit type.
 *
 * One row per item, the way ACE lists a backpack: first whatever the kits already hold, then
 * everything else the arsenal offers that EFAK allows into this kit. What the kits hold is always
 * listed so it can be taken out, even when it could not be put back in.
 *
 * A kit the mission only lets items out of, or does not let the arsenal change at all, still lists
 * everything, greyed with the reason - the player sees what the kit could take and why it does not.
 *
 * Redrawing the same kit type keeps the selected row and the scroll position.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_fillContents;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active) || {isNull _display}) exitWith {};

private _ctrl = _display displayCtrl IDC_EFAK_CONTENTS;
// The title row is where ACE puts search and sort; it is kept for the kit's name.
private _title = _display displayCtrl IDC_EFAK_RIGHT_TITLE;
// Why the list is empty goes on the left, in the hint line over the kits it is about.
private _hint = _display displayCtrl IDC_EFAK_LEFT_HINT;

// A different category is a different list - selection and scroll position do not carry over.
private _sameKit = GVAR(contentsShown) isEqualTo [GVAR(selected), GVAR(selectedPreparing), GVAR(category)];
private _selectedClass = "";
private _scroll = [-1, -1];

if (_sameKit) then {
    private _row = lnbCurSelRow _ctrl;
    if (_row >= 0) then {
        _selectedClass = toLowerANSI (_ctrl lnbData [_row, 0]);
    };
    _scroll = ctrlScrollValues _ctrl;
};

GVAR(contentsShown) = [GVAR(selected), GVAR(selectedPreparing), GVAR(category)];
GVAR(rowInfo) = createHashMap;

lnbClear _ctrl;

private _instances = call FUNC(getSelectedKits);

if (_instances isEqualTo []) exitWith {
    switch (true) do {
        case (GVAR(selectedPreparing)): {
            _title ctrlSetText format [LLSTRING(Header_Contents), [GVAR(selected)] call EFUNC(core,getKitName)];
            _hint ctrlSetText LLSTRING(Hint_Preparing);
        };
        case (GVAR(groups) isEqualTo []): {
            _title ctrlSetText "";
            _hint ctrlSetText LLSTRING(Hint_NoKits);
        };
        default {
            _title ctrlSetText "";
            _hint ctrlSetText LLSTRING(Hint_Kits);
        };
    };

    [_display] call FUNC(updateDefaultsBox);
    [_display] call FUNC(updateContents);
};

// Works out what the tab may change about the selected kit, which the hint and every row follow.
[_display] call FUNC(updateDefaultsBox);

_hint ctrlSetText (switch (GVAR(editing)) do {
    case EDIT_NOTHING: {LLSTRING(Hint_EditNothing)};
    case EDIT_REMOVE: {LLSTRING(Hint_EditRemove)};
    default {LLSTRING(Hint_Kits)};
});

_title ctrlSetText format [LLSTRING(Header_Contents), [GVAR(selected)] call EFUNC(core,getKitName)];

([GVAR(selected)] call FUNC(getCandidates)) params ["_candidates", "_allowed"];

// Whatever any of the kits holds, each item once.
private _contained = createHashMap;

{
    {
        private _key = toLowerANSI (_x select 0);
        if !(_key in _contained) then {
            _contained set [_key, _x select 0];
        };
    } forEach (GVAR(pending) getOrDefault [toLowerANSI _x, []]);
} forEach _instances;

private _containedSorted = (values _contained) apply {[toLower (([_x] call FUNC(getItemInfo)) select 1), _x]};
_containedSorted sort true;

private _rows = _containedSorted apply {_x select 1};

{
    if !(toLowerANSI (_x select 1) in _contained) then {
        _rows pushBack (_x select 1);
    };
} forEach _candidates;

// ----- Category, from ACE's buttons down the right edge -----

GVAR(containedKeys) = _contained;

// "Compatible magazines" depends on what the unit carries, so it is worked out per refill.
GVAR(compatibleMagazines) = createHashMap;

if (GVAR(category) == ACE_BUTTON_MAG) then {
    private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

    {
        {
            GVAR(compatibleMagazines) set [toLowerANSI _x, true];
        } forEach (compatibleMagazines _x);
    } forEach ([primaryWeapon _center, handgunWeapon _center, secondaryWeapon _center, binocular _center] select {_x != ""});
};

_rows = _rows select {[_x] call FUNC(matchesCategory)};

// ----- Search and sort, the way ACE's right panel does them -----

if (GVAR(searchText) isNotEqualTo "") then {
    private _needle = toLower GVAR(searchText);

    _rows = _rows select {
        ((toLower (([_x] call FUNC(getItemInfo)) select 1)) find _needle) > -1 ||
            {((toLower _x) find _needle) > -1}
    };
};

// How many of each the selected kit holds, for sorting by amount.
private _amounts = createHashMap;

{
    {
        _x params ["_class", "_count"];
        private _key = toLowerANSI _class;
        _amounts set [_key, (_amounts getOrDefault [_key, 0]) + _count];
    } forEach (GVAR(pending) getOrDefault [toLowerANSI _x, []]);
} forEach _instances;

private _keyed = _rows apply {
    private _info = [_x] call FUNC(getItemInfo);

    [
        switch (GVAR(sortMode)) do {
            case SORT_MASS: {_info select 3};
            case SORT_AMOUNT: {_amounts getOrDefault [toLowerANSI _x, 0]};
            default {toLower (_info select 1)};
        },
        toLower (_info select 1),
        _x
    ]
};

// Numbers descending are sorted as negative numbers ascending, so ties still read A to Z.
if (GVAR(sortMode) != SORT_NAME && {!GVAR(sortAscending)}) then {
    {
        _x set [0, -(_x select 0)];
    } forEach _keyed;

    _keyed sort true;
} else {
    _keyed sort GVAR(sortAscending);
};

_rows = _keyed apply {_x select 2};

private _selectRow = -1;

{
    ([_x] call FUNC(getItemInfo)) params ["_class", "_name", "_picture"];

    private _key = toLowerANSI _class;
    private _addable = _key in _allowed;
    private _reason = "";

    switch (true) do {
        // What the mission lets the arsenal change comes first: it is the reason for every row.
        case (GVAR(editing) == EDIT_NOTHING): {
            _addable = false;
            _reason = LLSTRING(Hint_EditNothing);
        };
        case (GVAR(editing) == EDIT_REMOVE): {
            _addable = false;
            _reason = LLSTRING(Hint_EditRemove);
        };
        // Only items already in a kit can be listed without being allowed in. Say why "+" is off.
        case (!_addable): {
            ([GVAR(selected), _class, 0, true] call EFUNC(core,canPackItem)) params ["_allowedByRules", "_rulesReason"];

            _reason = switch (true) do {
                case (_allowedByRules): {LLSTRING(Reason_NotInArsenal)};
                case (_rulesReason isNotEqualTo ""): {_rulesReason};
                default {LLSTRING(Reason_NotAllowed)};
            };
        };
    };

    // The most of it a kit of this type may hold, -1 for no limit. The same for every kit of the
    // type, and it does not change with what is staged, so it is worked out once per row.
    private _limit = if (_addable) then {[GVAR(selected), _class] call EFUNC(core,getPackLimit)} else {-1};

    GVAR(rowInfo) set [_key, [_addable, _reason, _limit]];

    private _row = _ctrl lnbAddRow ["", _name, ""];
    _ctrl lnbSetData [[_row, 0], _class];
    _ctrl lnbSetPicture [[_row, 0], _picture];
    // Same marker ACE puts on items the arsenal does not offer.
    _ctrl lnbSetValue [[_row, 2], parseNumber !_addable];
    _ctrl lnbSetTooltip [[_row, 0], [format ["%1\n%2", _name, _class], format ["%1\n%2\n%3", _name, _class, _reason]] select !_addable];

    if (_key isEqualTo _selectedClass) then {
        _selectRow = _row;
    };
} forEach _rows;

[_display] call FUNC(updateContents);

if (_selectRow >= 0) then {
    _ctrl lnbSetCurSelRow _selectRow;
};

if ((_scroll select 0) >= 0) then {
    _ctrl ctrlSetScrollValues _scroll;
};
