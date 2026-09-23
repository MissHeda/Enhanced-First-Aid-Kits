#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Switches "+" and "-" for the selected item and says why "+" is off, when it is.
 *
 * Arguments:
 * 0: Contents list control <CONTROL>
 * 1: Selected row <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, 0] call efak_arsenal_fnc_onContentSelected;
 *
 * Public: No
 */

params ["_ctrl", "_row"];

if (!GVAR(active)) exitWith {};

private _display = ctrlParent _ctrl;
private _plus = _display displayCtrl IDC_EFAK_ARROW_PLUS;
private _minus = _display displayCtrl IDC_EFAK_ARROW_MINUS;
private _instances = call FUNC(getSelectedKits);

if (_row < 0 || {_instances isEqualTo []}) exitWith {
    _plus ctrlEnable false;
    _minus ctrlEnable false;
    _plus ctrlCommit FADE_DELAY;
    _minus ctrlCommit FADE_DELAY;
};

private _class = _ctrl lnbData [_row, 0];
private _key = toLowerANSI _class;
private _mass = ([_class] call FUNC(getItemInfo)) select 3;

(GVAR(rowInfo) getOrDefault [_key, [false, ""]]) params ["_addable", "", ["_limit", -1]];

private _fits = false;
private _held = false;

{
    private _contents = GVAR(pending) getOrDefault [toLowerANSI _x, []];

    // Room in one kit for one more, and that kit still under the most its default contents allow.
    if (!_fits) then {
        private _free = ([_x] call EFUNC(core,getCapacity)) - ([_contents] call EFUNC(core,getUsedCapacity));
        _fits = _free + MASS_EPSILON >= _mass &&
            {_limit < 0 || {([_contents, _class] call EFUNC(core,countItem)) < _limit}};
    };

    if (!_held) then {
        _held = (_contents findIf {toLowerANSI (_x select 0) isEqualTo _key}) != -1;
    };
} forEach _instances;

// Locked while the kit follows the default contents or the mission keeps it as it is. A "Remove
// only" kit gets here with every row not addable, so only "-" is left.
_plus ctrlEnable (_addable && _fits && !GVAR(locked));
_minus ctrlEnable (_held && !GVAR(locked));
_plus ctrlCommit FADE_DELAY;
_minus ctrlCommit FADE_DELAY;
