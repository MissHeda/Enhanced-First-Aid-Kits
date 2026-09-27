#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The "Use CBA default" box was ticked or cleared: marks the selected kit to come back from a
 * saved loadout with the mission's default contents, or not.
 *
 * Ticking it also fills the kit with the default contents right away and locks the list: what the
 * tab shows is then exactly what the kit comes back with. Clearing it unlocks the list and leaves
 * the contents as they are.
 *
 * A "Remove only" kit may be reset this way too - the defaults are a complete kit, not items added
 * by hand - and cleared again to take things out. A kit the mission keeps as it is has its box
 * greyed, and a click that still gets here changes nothing.
 *
 * Arguments:
 * 0: Checkbox <CONTROL>
 * 1: Checked (1) or not (0) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_box, 1] call efak_arsenal_fnc_onUseDefaultsChanged;
 *
 * Public: No
 */

params ["_box", "_checked"];

if (!GVAR(active) || {GVAR(settingDefaultsBox)}) exitWith {};

private _instances = call FUNC(getSelectedKits);

if (count _instances != 1) exitWith {};

private _kit = _instances select 0;

// Drawing the list again puts the box back the way it was.
if (([_kit] call EFUNC(core,getArsenalEditing)) == EDIT_NOTHING) exitWith {
    [ctrlParent _box] call FUNC(fillContents);
};

private _follow = _checked == 1;

[_kit, _follow] call EFUNC(core,setFollowDefaults);

if (_follow) then {
    GVAR(pending) set [toLowerANSI _kit, [_kit] call EFUNC(core,getDefaultContents)];

    // Written right away rather than after the usual pause: on a "Remove only" kit, everything taken
    // out after clearing the box again is measured against what the kit holds, and that has to be
    // the defaults by then.
    call FUNC(flush);
};

[ctrlParent _box] call FUNC(fillContents);
