#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Checks whether an item may go into a kit.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Item class <STRING>
 * 2: Amount <NUMBER> (default: 1)
 * 3: Skip the capacity and amount checks <BOOL> (default: false)
 *
 * Return Value:
 * 0: Allowed <BOOL>
 * 1: Reason when not allowed, "" otherwise <STRING>
 *
 * Example:
 * ["efak_IFAK_7", "ACE_morphine", 1] call efak_core_fnc_canPackItem;
 *
 * Public: Yes
 */

params ["_kitClass", "_itemClass", ["_count", 1], ["_skipCapacity", false]];

// Whether packing is switched on is not a property of the item, and there are two switches per
// kit type - the kit window and the arsenal (fnc_canPackInto). Each of those checks its own before
// asking here.

if (([_kitClass] call FUNC(getKitData)) isEqualTo []) exitWith {[false, ""]};

// A kit inside a kit would let you fold an arbitrary amount of gear into one
// item, so it stays off unless the mission explicitly wants it.
if (([_itemClass] call FUNC(isKit)) && {!GVAR(allowNesting)}) exitWith {
    [false, LLSTRING(Error_NoNesting)]
};

([_kitClass, _itemClass] call FUNC(isItemAllowed)) params ["_allowed", "_reason"];

if !(_allowed) exitWith {[false, _reason]};

// Packed only up to the default contents: what they do not hold does not go in at all.
private _limit = [_kitClass, _itemClass] call FUNC(getPackLimit);

if (_limit == 0) exitWith {[false, LLSTRING(Error_NotInDefaults)]};

// The pouch and the arsenal tab check the space and the amount against what they have staged,
// which this cannot see, so they skip it here.
if (_skipCapacity) exitWith {[true, ""]};

private _contents = [_kitClass] call FUNC(getContents);

if (_limit > 0 && {([_contents, _itemClass] call FUNC(countItem)) + _count > _limit}) exitWith {
    [false, LLSTRING(Error_DefaultsReached)]
};

private _free = ([_kitClass] call FUNC(getCapacity)) - ([_contents] call FUNC(getUsedCapacity));

if (([_itemClass] call FUNC(getItemMass)) * _count > _free) exitWith {
    [false, LLSTRING(Error_NotEnoughSpace)]
};

[true, ""]
