#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Empties the kit into the left panel's source - the inventory or the crate - and whatever does not
 * fit onto the ground.
 *
 * Into the inventory it follows the same rules as a single move: the unload container first, then
 * whichever of the uniform, the vest and the backpack still has room. Everything goes where it is
 * going before the kit is written once, with what is left.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_unpackAllPressed;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

private _into = call FUNC(activeSource);
private _contents = [GVAR(kitClass)] call EFUNC(core,getContents);
private _left = +_contents;
private _charges = [GVAR(kitClass)] call EFUNC(core,getCharges);
private _moved = 0;
private _grounded = 0;
private _dropped = 0;

{
    _x params ["_class", "_count"];

    // Only what the search box is showing - "search bandage, take all" takes the bandages.
    if !([_class] call FUNC(matchesSearch)) then {continue};

    // Opened magazines come out as full as they went in.
    private _rounds = ["kit", _class, _count] call FUNC(pickRounds);

    ([_into, _class, _count, _rounds] call FUNC(putItems)) params ["_placed", "_refused"];

    private _rest = _count - _placed - _refused;

    if (_rest > 0) then {
        ["ground", _class, _rest, _rounds select [_placed + _refused, _rest]] call FUNC(putItems);
    };

    [_left, _class, -_count] call FUNC(listAdjust);
    _charges = [_charges, _class, [], _rounds] call EFUNC(core,adjustCharges);

    _moved = _moved + _count;
    _grounded = _grounded + _rest;
    _dropped = _dropped + _refused;
} forEach _contents;

if (_moved > 0) then {
    [_left, _charges] call FUNC(writeKit);
};

GVAR(message) = switch (true) do {
    case (_moved <= 0): {LLSTRING(UnpackAll_None)};
    case (_dropped > 0): {format [LLSTRING(DroppedUnexpected), _dropped]};
    case (_grounded > 0): {format [LLSTRING(UnpackAll_Ground), _moved, _grounded]};
    default {format [LLSTRING(UnpackAll_Done), _moved]};
};

call FUNC(refreshPouch);
