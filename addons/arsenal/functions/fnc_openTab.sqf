#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Opens the kits tab over ACE Arsenal's panels.
 *
 * ACE is never told: its current tab stays what it was, so none of its panel functions ever meets
 * a tab it does not know. The tab notes how ACE's controls looked, covers them, and closeTab puts
 * them back the moment ACE fills a panel again.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_openTab;
 *
 * Public: No
 */

params ["_display"];

if (isNull _display) exitWith {};
if ((call FUNC(getTabBlocker)) isNotEqualTo "") exitWith {};

// Clicking the tab again reads the inventory again.
if (GVAR(active)) exitWith {
    call FUNC(refreshKits);
};

GVAR(snapshot) = [];

{
    private _ctrl = _display displayCtrl _x;
    if (isNull _ctrl) then {continue};

    // ACE fades its panels in and out, so a click in the middle of that would catch a value in
    // between. Its panels are only ever fully in or fully out.
    GVAR(snapshot) pushBack [_x, ctrlShown _ctrl, ctrlEnabled _ctrl, parseNumber (ctrlFade _ctrl > 0.5)];
} forEach [ACE_COVERED_IDCS, ACE_CATEGORY_IDCS];

// Every category button other mods registered, whether or not ACE has got round to making them.
[_display] call FUNC(ensureCategoryButtons);

// The category that shows what the selected kit holds is always the tab's own button, never the
// one ACE registered for the kits: ACE creates that one the first time its right panel is a
// container, so a player who goes straight to this tab would find it missing.
GVAR(kitsButtonIdc) = IDC_EFAK_CATEGORY;
GVAR(category) = IDC_EFAK_CATEGORY;
GVAR(categoryIdcs) = [ACE_CATEGORY_BUTTONS];

// ACE's kit button lists the kits themselves, which is not what this tab is for. Where it exists
// the tab's own button takes its place, and the snapshot puts it back on close.
GVAR(aceKitsButtonIdc) = -1;

if (missionNamespace getVariable [QGVAR(ownCategory), true] && {GVAR(kitsButtonSlot) >= 0}) then {
    GVAR(aceKitsButtonIdc) = [ACE_CUSTOM_BUTTONS] select GVAR(kitsButtonSlot);

    private _index = GVAR(categoryIdcs) find GVAR(aceKitsButtonIdc);
    if (_index > -1) then {GVAR(categoryIdcs) deleteAt _index};
};

GVAR(categoryIdcs) pushBack IDC_EFAK_CATEGORY;

// Over ACE's kit button where there is one, under ACE's last category button where there is not.
private _anchor = ACE_BUTTON_MISC;
private _below = 10 * GRID_H;

if (GVAR(aceKitsButtonIdc) > -1 && {!isNull (_display displayCtrl GVAR(aceKitsButtonIdc))}) then {
    _anchor = GVAR(aceKitsButtonIdc);
    _below = 0;
};

{
    _x params ["_idc", "_anchorIdc"];

    private _ctrl = _display displayCtrl _idc;
    (ctrlPosition (_display displayCtrl _anchorIdc)) params ["_bx", "_by", "_bw", "_bh"];

    _ctrl ctrlSetPosition [_bx, _by + _below, _bw, _bh];
    _ctrl ctrlShow true;
    _ctrl ctrlCommit 0;
} forEach [[IDC_EFAK_CATEGORY, _anchor], [IDC_EFAK_CATEGORY_BG, _anchor - 1]];

// Whichever button the tab's own one is standing in for goes away while it does.
if (GVAR(aceKitsButtonIdc) > -1) then {
    {
        private _ctrl = _display displayCtrl _x;
        _ctrl ctrlShow false;
        _ctrl ctrlCommit 0;
    } forEach [GVAR(aceKitsButtonIdc), GVAR(aceKitsButtonIdc) - 1];
};

// Search starts empty each time, the sort choice is kept.
GVAR(searchText) = "";
(_display displayCtrl IDC_EFAK_SEARCH) ctrlSetText "";
[_display] call FUNC(fillSort);

// Move the highlight from ACE's tab to this one, the same way ACE switches between its own tabs.
if !(isNil QACEGVAR(arsenal,currentLeftPanel)) then {
    private _aceTabBackground = _display displayCtrl (ACEGVAR(arsenal,currentLeftPanel) - 1);
    _aceTabBackground ctrlSetFade 1;
    _aceTabBackground ctrlCommit FADE_DELAY;
};

private _tabBackground = _display displayCtrl IDC_EFAK_TAB_BACKGROUND;
_tabBackground ctrlSetFade 0;
_tabBackground ctrlCommit FADE_DELAY;

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlSetFade 0;
    _ctrl ctrlEnable true;
    _ctrl ctrlCommit FADE_DELAY;
} forEach [EFAK_PANEL_IDCS];

GVAR(active) = true;

// The category buttons down the right edge now filter the kit contents. The tab always opens on
// the kits button, which here means what the kit holds right now.
[_display, true] call FUNC(hookCategoryButtons);

[_display] call FUNC(applyVisibility);

// Whatever had focus is about to be hidden - a search bar keeping it would leave ACE believing the
// player is still typing.
ctrlSetFocus (_display displayCtrl IDC_EFAK_KIT_LIST);

// Kits the editor's stand-in was given through ACE's own tabs are still prototypes, and nothing
// there would ever convert them.
if (is3DEN) then {
    [missionNamespace getVariable [QACEGVAR(arsenal,center), objNull]] call EFUNC(core,convertKitsNow);
};

call FUNC(refreshKits);
