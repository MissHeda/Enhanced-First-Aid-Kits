#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Takes items out of a kit and puts them into a unit's inventory. This is the
 * "give me a single dressing, not the whole kit" case.
 *
 * The unit taking the items and the unit carrying the kit are not necessarily
 * the same - a medic pulling supplies out of a casualty's kit is the whole
 * point of the interaction on other units.
 *
 * Arguments:
 * 0: Unit receiving the items <OBJECT>
 * 1: Kit instance class <STRING>
 * 2: Item class <STRING>
 * 3: Amount <NUMBER> (default: 1)
 * 4: Unit carrying the kit <OBJECT> (default: the receiving unit)
 * 5: Skip the empty-kit cleanup <BOOL> (default: false)
 * 6: For a magazine of several rounds, which ones: -1 opened first, 0 full ones only, more than 0
 *    only opened ones with that many rounds - see fnc_pickCharges <NUMBER> (default: -1)
 *
 * Return Value:
 * Amount actually taken out <NUMBER>
 *
 * Example:
 * [player, "efak_IFAK_7", "ACE_morphine", 1] call efak_core_fnc_unpackItem;
 *
 * Public: Yes
 */

params ["_unit", "_kitClass", "_itemClass", ["_count", 1], ["_kitOwner", objNull], ["_skipCleanup", false], ["_which", -1]];

if (isNull _kitOwner) then {_kitOwner = _unit};

private _contents = [_kitClass] call FUNC(getContents);
private _index = _contents findIf {(_x select 0) == _itemClass};

if (_index < 0) exitWith {0};

private _stored = (_contents select _index) select 1;
_count = (floor _count) min _stored;

if (_count <= 0) exitWith {0};

private _container = [_kitClass] call FUNC(getKitContainer);

// addToInventory answers whether the item reached the unit; when it did not, it has already
// made a weapon holder and put it on the ground. That is reasonable behaviour and it was
// happening silently, which is not - somebody unpacking a full kit into a full vest had no way
// of knowing half of it was now at their feet.
private _dropped = 0;

// Opened magazines come out first and as full as they went in - or just the ones asked for.
private _rounds = [_kitClass, _itemClass, _count, _which] call FUNC(pickCharges);

if (_which >= 0 && {([_itemClass] call FUNC(getMagazineSize)) > 1}) then {
    _count = _count min (count _rounds);
};

if (_count <= 0) exitWith {0};

for "_i" from 1 to _count do {
    if !(([_unit, _itemClass, _container, _rounds param [_i - 1, -1]] call FUNC(addToUnit)) select 0) then {
        _dropped = _dropped + 1;
    };
};

if (_dropped > 0 && {_unit isEqualTo ACE_player} && {hasInterface}) then {
    [format [
        ARR_3(LLSTRING(DroppedOnGround),_dropped,[_itemClass] call FUNC(getItemName))
    ]] call ACEFUNC(common,displayTextStructured);
};

if (_count >= _stored) then {
    _contents deleteAt _index;
} else {
    _contents set [_index, [_itemClass, _stored - _count]];
};

[_kitClass, _contents, [[_kitClass] call FUNC(getCharges), _itemClass, [], _rounds] call FUNC(adjustCharges)] call FUNC(setContents);

// removeKit decides for itself whether this kit disappears when empty - the per kit setting
// lives there, so there is nothing to check twice.
if (!_skipCleanup && {_contents isEqualTo []}) then {
    [_kitOwner, _kitClass] call FUNC(removeKit);
};

_count
