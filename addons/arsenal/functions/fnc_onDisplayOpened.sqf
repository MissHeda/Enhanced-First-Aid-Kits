#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Prepares the kits tab when ACE Arsenal opens: starts a clean session, keeps the tab's panels out
 * of sight, and switches the tab button on only where kits can actually be edited.
 *
 * Runs from ACE's own onLoad, before ACE fills its first tab.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_onDisplayOpened;
 *
 * Public: No
 */

params ["_display"];

// The kits' own category down ACE's right edge. In a mission postInit registers it; the Eden editor
// never runs postInit, so its arsenal does it here, where every other mod's button exists as well.
if (is3DEN) then {
    call FUNC(applyCategorySetting);
};

GVAR(active) = false;
GVAR(snapshot) = [];
GVAR(base) = createHashMap;
GVAR(pending) = createHashMap;
GVAR(classNames) = createHashMap;
GVAR(groups) = [];
GVAR(selected) = "";
GVAR(selectedPreparing) = false;
GVAR(contentsShown) = [];
GVAR(hasItems) = false;
GVAR(candidates) = createHashMap;
GVAR(available) = createHashMap;
GVAR(availableSource) = createHashMap;
GVAR(itemInfo) = createHashMap;
GVAR(rowInfo) = createHashMap;
GVAR(kitListFocus) = false;
GVAR(contentsFocus) = false;
GVAR(writing) = false;

// A write still waiting from the last arsenal belongs to a closed session.
GVAR(flushToken) = GVAR(flushToken) + 1;

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlShow false;
    _ctrl ctrlEnable false;
    _ctrl ctrlCommit 0;
} forEach [EFAK_PANEL_IDCS, IDC_EFAK_CLEAR, IDC_EFAK_CATEGORY, IDC_EFAK_CATEGORY_BG];

// The same text size the player picked for ACE's lists.
private _fontHeight = missionNamespace getVariable [QACEGVAR(arsenal,fontHeight), 4.5];

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlSetFontHeight (_fontHeight * GRID_H);
    _ctrl ctrlCommit 0;
} forEach [IDC_EFAK_KIT_LIST, IDC_EFAK_CONTENTS];

// Kits only get contents on the player's own unit in a running mission. Anywhere else the tab
// stays greyed out like ACE's identity tabs, and the tooltip says why.
private _blocker = call FUNC(getTabBlocker);
private _tab = _display displayCtrl IDC_EFAK_TAB;

_tab ctrlEnable (_blocker isEqualTo "");
_tab ctrlSetFade ([0.6, 0] select (_blocker isEqualTo ""));
_tab ctrlSetTooltip ([_blocker, LLSTRING(Tab_Tooltip)] select (_blocker isEqualTo ""));
_tab ctrlCommit 0;

private _tabBackground = _display displayCtrl IDC_EFAK_TAB_BACKGROUND;
_tabBackground ctrlSetFade 1;
_tabBackground ctrlCommit 0;

// The tab only takes a slot while there is a kit to show. Checked twice a second rather than hooked
// to every way an item can arrive - the arsenal adds items, loadouts load, kits finish converting.
GVAR(tabSlotShown) = -1;
GVAR(tabConfigTop) = createHashMap;
[_display] call FUNC(updateTabSlot);

if (GVAR(tabSlotPFH) != -1) then {[GVAR(tabSlotPFH)] call CBA_fnc_removePerFrameHandler};
GVAR(tabSlotPFH) = [{
    params ["_display", "_handle"];

    if (isNull _display) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        GVAR(tabSlotPFH) = -1;
    };

    [_display] call FUNC(updateTabSlot);
}, 0.5, _display] call CBA_fnc_addPerFrameHandler;

// ACE's key handler only knows its own lists. This one adds the arrow keys for the contents list
// and stays out of the way otherwise.
_display displayAddEventHandler ["KeyDown", {call FUNC(onKeyDown)}];
