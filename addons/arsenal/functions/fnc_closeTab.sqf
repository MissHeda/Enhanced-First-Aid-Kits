#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Closes the kits tab: writes what is staged and hands the panels back to ACE.
 *
 * Called while ACE is in the middle of filling a panel - after it has cleared its list, before it
 * selects anything. ACE's controls are put back the way they were when the tab opened, and ACE's
 * own selection handling then shows or hides whatever the new tab needs, exactly as if it had
 * switched from its previous tab.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_closeTab;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active)) exitWith {};

call FUNC(flush);

GVAR(active) = false;
GVAR(flushToken) = GVAR(flushToken) + 1;

// Hiding a list that has focus does not always tell it so, and ACE reads these flags on every key.
if (GVAR(kitListFocus)) then {
    ACEGVAR(arsenal,leftTabFocus) = false;
    GVAR(kitListFocus) = false;
};
if (GVAR(contentsFocus)) then {
    ACEGVAR(arsenal,rightTabFocus) = false;
    GVAR(contentsFocus) = false;
};

if (isNull _display) exitWith {
    GVAR(snapshot) = [];
};

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlShow false;
    _ctrl ctrlEnable false;
    _ctrl ctrlCommit 0;
} forEach [EFAK_PANEL_IDCS, IDC_EFAK_CLEAR, IDC_EFAK_CATEGORY, IDC_EFAK_CATEGORY_BG];

private _tabBackground = _display displayCtrl IDC_EFAK_TAB_BACKGROUND;
_tabBackground ctrlSetFade 1;
_tabBackground ctrlCommit FADE_DELAY;

// ACE's category buttons get their own click handlers back before their state is restored.
[_display, false] call FUNC(hookCategoryButtons);

// While the interface is hidden (a refresh can land then) everything stays hidden - ACE shows all
// of it again itself when the interface comes back.
private _interfaceShown = ctrlShown (_display displayCtrl IDC_ACE_MENUBAR);

{
    _x params ["_idc", "_shown", "_enabled", "_fade"];

    private _ctrl = _display displayCtrl _idc;
    _ctrl ctrlShow (_shown && _interfaceShown);
    _ctrl ctrlEnable _enabled;
    _ctrl ctrlSetFade _fade;
    _ctrl ctrlCommit 0;
} forEach GVAR(snapshot);

GVAR(snapshot) = [];
GVAR(base) = createHashMap;
GVAR(pending) = createHashMap;
GVAR(classNames) = createHashMap;
GVAR(hasItems) = false;
