#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Packs everything the left panel is showing into the kit, as far as it fits.
 *
 * The mirror image of Take everything, so filling a kit at a crate is one button rather than one
 * drag per stack. Whatever does not fit stays where it is.
 *
 * A kit that is packed only up to its default contents takes no more of each item than they hold
 * and nothing else, so at a medical crate one click tops the kit up to its default contents - as far
 * as the crate has the items and the kit has the room.
 *
 * Every item leaves the source before the kit is written once, with all of it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_packAllPressed;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

private _kitClass = GVAR(kitClass);

// With packing into this type of kit switched off, only what came out of it while the window is open
// goes back (fnc_getKitRoom).
private _from = call FUNC(activeSource);
private _contents = [_kitClass] call EFUNC(core,getContents);
private _charges = [_kitClass] call EFUNC(core,getCharges);
private _moved = 0;
private _leftOver = false;
// Packing off: only what came out goes back, the fullest first (fnc_pickRounds).
private _fullestFirst = !([_kitClass] call EFUNC(core,canPackInto));

{
    _x params ["_class", "_count"];

    // Only what the search box is showing, same as Take all.
    if !([_class] call FUNC(matchesSearch)) then {continue};

    // Checked against what has been packed so far, so the room and the default amounts are shared
    // out item by item.
    private _fits = ([_contents, _class, _count] call FUNC(getKitRoom)) select 0;
    private _rounds = [_from, _class, _fits, _fullestFirst] call FUNC(pickRounds);
    private _taken = [_from, _class, _fits, _rounds] call FUNC(takeItems);

    if (_taken > 0) then {
        [_contents, _class, _taken] call FUNC(listAdjust);
        _charges = [_charges, _class, _rounds select [0, _taken]] call EFUNC(core,adjustCharges);
        _moved = _moved + _taken;
    };

    if (_taken < _count) then {_leftOver = true};
} forEach ([_from] call FUNC(getEntries));

if (_moved > 0) then {
    [_contents, _charges] call FUNC(writeKit);
};

GVAR(message) = if ([_kitClass, "limitToDefaults", false] call EFUNC(core,getKitSetting)) then {
    // Packed only up to the default contents: what matters is how much of them is still missing.
    private _missing = 0;

    {
        _x params ["_class", "_count"];
        _missing = _missing + ((_count - ([_contents, _class] call EFUNC(core,countItem))) max 0);
    } forEach ([_kitClass] call EFUNC(core,getDefaultContents));

    switch (true) do {
        case (_missing <= 0 && {_moved <= 0}): {LLSTRING(PackAll_DefaultsFull)};
        case (_missing <= 0): {format [LLSTRING(PackAll_DefaultsDone), _moved]};
        case (_moved <= 0): {format [LLSTRING(PackAll_DefaultsNone), _missing]};
        default {format [LLSTRING(PackAll_DefaultsMissing), _moved, _missing]};
    }
} else {
    switch (true) do {
        case (_moved <= 0): {LLSTRING(PackAll_None)};
        case (_leftOver): {format [LLSTRING(PackAll_Partial), _moved]};
        default {format [LLSTRING(PackAll_Done), _moved]};
    }
};

call FUNC(refreshPouch);
