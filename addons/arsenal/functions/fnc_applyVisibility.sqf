#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Shows or hides the kits tab together with the rest of the arsenal interface.
 *
 * ACE hides the interface by hiding its menu bar along with everything else, and brings every one
 * of its panels back when it shows it again - including the ones the kits tab is covering. So
 * whenever the interface comes back, those are covered again.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_applyVisibility;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active) || {isNull _display}) exitWith {};

private _shown = ctrlShown (_display displayCtrl IDC_ACE_MENUBAR);

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlShow _shown;
    _ctrl ctrlCommit 0;
} forEach [EFAK_PANEL_IDCS];

// The clear button only ever shows while there is something to clear.
private _clear = _display displayCtrl IDC_EFAK_CLEAR;
_clear ctrlShow (_shown && GVAR(hasItems));
_clear ctrlEnable !GVAR(locked);
_clear ctrlCommit 0;

// ACE's category buttons, the way ACE shows them for a backpack. Custom buttons only exist once some
// mod has registered them. The highlight follows the tab's category, not ACE's right panel.
private _custom = missionNamespace getVariable [QACEGVAR(arsenal,customRightPanelButtons), []];
private _customIdcs = [ACE_CUSTOM_BUTTONS];

{
    private _customIndex = _customIdcs find _x;
    private _available = _shown;

    if (_customIndex > -1) then {
        private _entry = _custom param [_customIndex];
        _available = _available && {!isNil "_entry"};
    };

    private _button = _display displayCtrl _x;
    _button ctrlShow _available;
    _button ctrlEnable _available;
    _button ctrlSetFade 0;
    _button ctrlCommit 0;

    private _background = _display displayCtrl (_x - 1);
    _background ctrlShow _available;
    _background ctrlSetFade parseNumber (_x != GVAR(category));
    _background ctrlCommit 0;
} forEach GVAR(categoryIdcs);

if !(_shown) exitWith {};

{
    private _ctrl = _display displayCtrl _x;
    _ctrl ctrlShow false;
    _ctrl ctrlEnable false;
    _ctrl ctrlCommit 0;
} forEach [ACE_COVERED_IDCS];
