#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Points the open kit window at a kit: on opening, from the switcher at the top, and when the kit
 * being shown is gone.
 *
 * Every list starts counting its changes afresh, so the "(+3)" and "(-2)" of the rows are always
 * about the kit on screen. A kit lying in the crate is filled from the crate; any other kit keeps
 * whichever side the left panel was showing, so restocking several kits at a crate is one tab click
 * rather than one per kit.
 *
 * Arguments:
 * 0: Unit or crate holding the kit <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Message for the hint line <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_gui_fnc_selectKit;
 *
 * Public: No
 */

disableSerialization;

params ["_owner", "_kitClass", ["_message", ""]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

GVAR(owner) = _owner;
GVAR(kitClass) = _kitClass;
GVAR(message) = _message;

// The first time this window shows the kit, not every time it switches back to it.
if !((toLowerANSI _kitClass) in GVAR(kitStart)) then {
    GVAR(kitStart) set [toLowerANSI _kitClass, [_kitClass] call EFUNC(core,getContents)];
    GVAR(kitStartCharges) set [toLowerANSI _kitClass, [_kitClass] call EFUNC(core,getCharges)];
};

if (!(_owner isKindOf "CAManBase") && {!isNull GVAR(crate)}) then {
    GVAR(leftSource) = SOURCE_CRATE;
};

call FUNC(takeBaseline);

// The unload container is chosen per type of kit.
[_display] call FUNC(fillTakeInto);

call FUNC(refreshPouch);
