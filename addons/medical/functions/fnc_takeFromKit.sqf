#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Consumes items straight out of a kit, without them ever passing through anybody's pockets.
 *
 * Arguments:
 * 0: Unit carrying the kit <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Item class <STRING>
 * 3: Amount <NUMBER> (default: 1)
 *
 * Return Value:
 * Taken <BOOL>
 *
 * Example:
 * [player, "efak_IFAK_7", "ACE_morphine", 1] call efak_medical_fnc_takeFromKit;
 *
 * Public: No
 */

params ["_unit", "_kitClass", "_itemClass", ["_count", 1]];

private _contents = [_kitClass] call EFUNC(core,getContents);
private _key = toLowerANSI _itemClass;
private _index = _contents findIf {(toLowerANSI (_x select 0)) isEqualTo _key};

if (_index < 0) exitWith {false};

(_contents select _index) params ["_stored", "_have"];

_count = _count min _have;

if (_count <= 0) exitWith {false};

// Opened magazines leave first, see efak_core_fnc_pickCharges.
private _rounds = [_kitClass, _itemClass, _count] call EFUNC(core,pickCharges);

if (_count >= _have) then {
    _contents deleteAt _index;
} else {
    _contents set [_index, [_stored, _have - _count]];
};

[_kitClass, _contents, [[_kitClass] call EFUNC(core,getCharges), _itemClass, [], _rounds] call EFUNC(core,adjustCharges)] call EFUNC(core,setContents);

// Does nothing unless the kit is both empty and set up to disappear when it is. A kit lying on the
// ground (see usableKits) disappears from where it lies.
if (_contents isEqualTo []) then {
    private _owner = _unit;

    if (((items _unit) findIf {(toLowerANSI _x) isEqualTo (toLowerANSI _kitClass)}) == -1) then {
        _owner = GVAR(nearbyHolders) getOrDefault [toLowerANSI _kitClass, _unit];
    };

    [_owner, _kitClass] call EFUNC(core,removeKit);
};

true
