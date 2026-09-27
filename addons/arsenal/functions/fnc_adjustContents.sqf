#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Adds to or takes from one item in a staged contents list, in place.
 *
 * An item keeps its place in the list while any of it is left and only drops out once it reaches
 * zero, so the stored order stays the order things were packed in.
 *
 * Given the kit the list belongs to, the change keeps to that kit's rules: nothing changes on a kit
 * the mission keeps as it is, nothing goes into one it only lets items out of, and an addition stops
 * at what the item rules, the default contents limit and the space left allow. Every change the tab
 * makes to a kit goes through here, so a click and a write can never disagree about the rules.
 *
 * Arguments:
 * 0: Contents <ARRAY> of [class, count]
 * 1: Item class <STRING>
 * 2: How many to add, negative to take away <NUMBER>
 * 3: Kit instance class whose rules apply, "" for none <STRING> (default: "")
 *
 * Return Value:
 * How many were actually added, negative when taken away <NUMBER>
 *
 * Example:
 * [_contents, "ACE_morphine", -2, "efak_IFAK_7"] call efak_arsenal_fnc_adjustContents;
 *
 * Public: No
 */

params ["_contents", "_class", ["_delta", 0], ["_kit", ""]];

if (_kit isNotEqualTo "" && {_delta != 0}) then {
    private _editing = [_kit] call EFUNC(core,getArsenalEditing);

    if (_editing == EDIT_NOTHING) exitWith {
        _delta = 0;
    };

    if (_delta < 0) exitWith {};

    // Taking out is all a "Remove only" kit allows.
    if (_editing != EDIT_ALL) exitWith {
        _delta = 0;
    };

    // Amount and space are left out here: they are measured against this list, not the stored one.
    if !(([_kit, _class, 0, true] call EFUNC(core,canPackItem)) select 0) exitWith {
        _delta = 0;
    };

    // Packed kits count by type, so an IFAK instance and the IFAK from the arsenal share one limit.
    private _limit = [_kit, _class] call EFUNC(core,getPackLimit);

    if (_limit >= 0) then {
        _delta = _delta min (_limit - ([_contents, _class] call EFUNC(core,countItem)));
    };

    // A kit can already be over capacity (a lowered capacity setting) - that is no room, not a
    // reason to take anything out.
    private _mass = ([_class] call FUNC(getItemInfo)) select 3;

    if (_mass > 0) then {
        private _free = ([_kit] call EFUNC(core,getCapacity)) - ([_contents] call EFUNC(core,getUsedCapacity));
        _delta = _delta min floor ((_free + MASS_EPSILON) / _mass);
    };

    _delta = _delta max 0;
};

if (_delta isEqualTo 0) exitWith {0};

private _key = toLowerANSI _class;
private _index = _contents findIf {toLowerANSI (_x select 0) isEqualTo _key};

if (_index < 0) exitWith {
    if (_delta > 0) then {
        _contents pushBack [_class, _delta];
        _delta
    } else {
        0
    };
};

(_contents select _index) params ["_stored", "_count"];

if (_count + _delta <= 0) exitWith {
    _contents deleteAt _index;
    -_count
};

_contents set [_index, [_stored, _count + _delta]];

_delta
