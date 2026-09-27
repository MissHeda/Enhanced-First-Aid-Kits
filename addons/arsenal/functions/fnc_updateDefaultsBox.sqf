#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Sets the "Use CBA default" box to the selected kit, and works out what the tab may change about
 * that kit (GVAR(editing), from efak_core_fnc_getArsenalEditing).
 *
 * Only a kit that has an identity can be marked, so the box is off and greyed while nothing or a
 * kit still being prepared is selected.
 *
 * A ticked kit is locked: its contents are the mission's defaults, and the list says so by being
 * greyed out with "+" and "-" off until the box is cleared. A kit the mission does not let the
 * arsenal change at all is locked the same way, box included - it can only be looked at.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001] call efak_arsenal_fnc_updateDefaultsBox;
 *
 * Public: No
 */

params ["_display"];

if (!GVAR(active) || {isNull _display}) exitWith {};

private _instances = call FUNC(getSelectedKits);
private _kit = if (count _instances == 1) then {_instances select 0} else {""};
private _usable = _kit isNotEqualTo "";

// Per kit type, and everything else in the tab follows it: rows, arrows, clear button, hints.
GVAR(editing) = [GVAR(selected)] call EFUNC(core,getArsenalEditing);

private _follows = _usable && {(toLowerANSI _kit) in EGVAR(core,followDefaults)};

GVAR(locked) = _usable && {_follows || {GVAR(editing) == EDIT_NOTHING}};

private _box = _display displayCtrl IDC_EFAK_DEFAULTS;

// Setting the box by script must not read as the player ticking it.
GVAR(settingDefaultsBox) = true;
_box cbSetChecked _follows;
GVAR(settingDefaultsBox) = false;

// Ticking resets the kit to its defaults, which "Remove only" allows. Only a kit the mission keeps
// as it is keeps its box as well.
private _enabled = _usable && {GVAR(editing) != EDIT_NOTHING};

// With the contents forced, a loadout brings the defaults whichever way the box is set - the box
// then only decides what the kit holds right now.
private _tooltip = LLSTRING(UseDefaults_Tooltip);

if (_usable && {[_kit] call EFUNC(core,isContentsForced)}) then {
    _tooltip = format ["%1\n\n%2", _tooltip, LLSTRING(UseDefaults_Tooltip_Forced)];
};

_box ctrlEnable _enabled;
_box ctrlSetTooltip _tooltip;
_box ctrlCommit 0;

private _label = _display displayCtrl IDC_EFAK_DEFAULTS_LABEL;
_label ctrlSetTextColor [1, 1, 1, [0.4, 1] select _enabled];
_label ctrlSetTooltip _tooltip;
