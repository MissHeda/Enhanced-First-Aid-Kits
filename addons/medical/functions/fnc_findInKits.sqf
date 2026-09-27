#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Finds the first kit on a unit that holds one of the wanted items.
 *
 * The item list ACE hands a treatment is in preference order - a bandage action lists every kind
 * of bandage it will accept - so the first hit wins, the same way ACE's own search does.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item classes <ARRAY> of <STRING>
 *
 * Return Value:
 * 0: Kit instance class <STRING>, "" when nothing was found
 * 1: Item class that was found <STRING>
 *
 * Example:
 * [player, ["ACE_fieldDressing"]] call efak_medical_fnc_findInKits;
 *
 * Public: No
 */

params ["_unit", "_items"];

private _result = ["", ""];

if (isNull _unit || {_items isEqualTo []}) exitWith {_result};

// Nothing to find: the kits are not walked at all.
private _counts = [_unit] call FUNC(kitCounts);
if ((_items findIf {(_counts getOrDefault [toLowerANSI _x, 0]) > 0}) == -1) exitWith {_result};

{
    private _kitClass = _x;

    // A kit type the mission keeps out of treatments.
    if !([_kitClass] call FUNC(canUseKit)) then {continue};

    private _contents = [_kitClass] call EFUNC(core,getContents);

    {
        private _key = toLowerANSI _x;

        if ((_contents findIf {(toLowerANSI (_x select 0)) isEqualTo _key}) > -1) exitWith {
            _result = [_kitClass, _x];
        };
    } forEach _items;

    if ((_result select 0) isNotEqualTo "") exitWith {};
} forEach ([_unit] call FUNC(sortKits));

_result
