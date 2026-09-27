#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Makes sure every category button a mod has registered exists in this arsenal.
 *
 * ACE creates those buttons the first time its right panel becomes a container - open the arsenal,
 * go straight to the kits tab and they have never been made, so the tab came up with a category
 * row missing pieces. Clicking a uniform, vest or backpack tab first made them appear, which is
 * exactly the "sometimes" in the bug report.
 *
 * Same classes, same positions and the same "only if it is not there yet" check ACE uses, so ACE
 * finds nothing left to do when it gets round to it.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_ensureCategoryButtons;
 *
 * Public: No
 */

params ["_display"];

if (isNull _display) exitWith {};

private _custom = missionNamespace getVariable [QACEGVAR(arsenal,customRightPanelButtons), []];

if (_custom isEqualTo []) exitWith {};

// How many rows the custom buttons take up. Misc items sits under the last of them.
private _rows = 0;

{
    // A slot no mod has taken is nil.
    if (isNil "_x") then {continue};

    _x params ["", "_picture", "_tooltip"];

    _rows = _forEachIndex + 1;

    private _idc = 61 + _forEachIndex * 2;
    private _top = safeZoneY + (88 + 10 * _forEachIndex) * GRID_H;

    if (isNull (_display displayCtrl (_idc - 1))) then {
        private _ctrl = _display ctrlCreate [QACEGVAR(arsenal,customArsenalButton_Background), _idc - 1];
        _ctrl ctrlSetPosition [safeZoneW + safeZoneX - 13 * GRID_W, _top];
        _ctrl ctrlCommit 0;
    };

    if (isNull (_display displayCtrl _idc)) then {
        private _ctrl = _display ctrlCreate [QACEGVAR(arsenal,customArsenalButton_Button), _idc];
        _ctrl ctrlSetPosition [safeZoneW + safeZoneX - 10 * GRID_W, _top];
        _ctrl ctrlSetText _picture;
        _ctrl ctrlSetTooltip _tooltip;
        _ctrl ctrlCommit 0;
    };
} forEach _custom;

if (_rows == 0) exitWith {};

// Misc items moves out from under them, the way ACE moves it itself.
{
    private _ctrl = _display displayCtrl _x;
    (ctrlPosition _ctrl) params ["", "", "_w", "_h"];

    _ctrl ctrlSetPosition [
        safeZoneW + safeZoneX - (10 + 3 * _forEachIndex) * GRID_W,
        safeZoneY + (88 + 10 * _rows) * GRID_H,
        _w,
        _h
    ];
    _ctrl ctrlCommit 0;
} forEach [ACE_BUTTON_MISC, ACE_BUTTON_MISC - 1];
