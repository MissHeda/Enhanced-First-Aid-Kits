#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * How many of an item may go into the kit being shown, and why not more.
 *
 * In order: whether packing into this type of kit is switched on at all, whether the kit takes this
 * kind of item (its rules, see efak_core_fnc_canPackItem), how many its default contents allow when
 * the kit is packed only up to them, and how much room is left.
 *
 * The amount and the room are counted against the contents passed in rather than the stored ones,
 * so Pack all can check one item after the other against what it has packed so far.
 *
 * Arguments:
 * 0: Contents to count against <ARRAY> of [class, count]
 * 1: Item class <STRING>
 * 2: How many are wanted <NUMBER> (default: 1)
 * 3: Only ask whether this kind of item may go in at all <BOOL> (default: false)
 *
 * Return Value:
 * 0: How many may go in <NUMBER>
 * 1: Why not all of them, "" when they all may <STRING>
 *
 * Example:
 * [[], "ACE_morphine", 1, true] call efak_gui_fnc_getKitRoom;
 *
 * Public: No
 */

params ["_contents", "_class", ["_want", 1], ["_rulesOnly", false]];

private _kitClass = GVAR(kitClass);

// Packing into this type of kit is switched off - but what came out of it while the window is open
// may go back, a wrong click is not final until the window closes. Counted against the kit as it is
// when only the rules are asked about.
if !([_kitClass] call EFUNC(core,canPackInto)) then {
    private _against = [_contents, [_kitClass] call EFUNC(core,getContents)] select _rulesOnly;
    _want = _want min ([_against, _class] call FUNC(getRepackable));
};

if (_want <= 0) exitWith {[0, LLSTRING(Error_PackingOff)]};

// A kit can never go into itself, whatever the nesting setting says.
if ((toLowerANSI _class) isEqualTo (toLowerANSI _kitClass)) exitWith {[0, LLSTRING(Row_NotAllowed)]};

// The amount and the space are checked below against the contents passed in, so this is only about
// whether this kit takes this kind of item at all.
([_kitClass, _class, 1, true] call EFUNC(core,canPackItem)) params ["_allowed", "_reason"];

if !(_allowed) exitWith {[0, [_reason, LLSTRING(Row_NotAllowed)] select (_reason isEqualTo "")]};

if (_rulesOnly) exitWith {[_want, ""]};

private _name = [_class] call EFUNC(core,getItemName);
private _fits = _want;
private _why = "";

// Packed only up to the default contents: no more than they hold. Packed kits count by type.
private _limit = [_kitClass, _class] call EFUNC(core,getPackLimit);

if (_limit >= 0) then {
    private _room = (_limit - ([_contents, _class] call EFUNC(core,countItem))) max 0;

    if (_room < _fits) then {
        _fits = _room;
        _why = [format [LLSTRING(Partial_Defaults), _fits, _name], LELSTRING(core,Error_DefaultsReached)] select (_fits <= 0);
    };
};

private _mass = [_class] call EFUNC(core,getItemMass);

// Masses are decimals: three bandages at 0.4 must still fit into 1.2 of space.
if (_mass > 0 && {_fits > 0}) then {
    private _free = ([_kitClass] call EFUNC(core,getCapacity)) - ([_contents] call EFUNC(core,getUsedCapacity));
    private _room = (floor ((_free + MASS_EPSILON) / _mass)) max 0;

    if (_room < _fits) then {
        _fits = _room;
        _why = [format [LLSTRING(Partial_Kit), _fits, _name], format [LLSTRING(NoRoom), _name]] select (_fits <= 0);
    };
};

[_fits, _why]
