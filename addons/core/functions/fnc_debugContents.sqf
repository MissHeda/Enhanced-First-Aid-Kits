#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Copies what is in the player's backpack onto the clipboard, in the plain form the default
 * contents setting and the Eden crate fields take: classname then amount, "ACE_fieldDressing 6".
 *
 * This is how you write a kit loadout without typing classnames: switch the setting on, fill a
 * backpack with what the kit should hold, and paste. Runs every few seconds on its own, so the
 * clipboard is always current and there is nothing to press.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_debugContents;
 *
 * Public: No
 */

if !(hasInterface) exitWith {};

private _backpack = backpackContainer ACE_player;

if (isNull _backpack) exitWith {
    hintSilent parseText format [
        "<t size='1.1' color='#ffb84d'>%1</t><br/><br/>%2",
        LLSTRING(Debug_Title),
        LLSTRING(Debug_NoBackpack)
    ];
};

// Merged across items and magazines, in the order the engine hands them over, so what you see in
// the bag is the order you get in the box.
private _counts = createHashMap;
private _order = [];

{
    _x params [["_classes", []], ["_amounts", []]];

    {
        private _key = toLowerANSI _x;

        if !(_key in _counts) then {_order pushBack [_key, _x]};

        _counts set [_key, (_counts getOrDefault [_key, 0]) + (_amounts param [_forEachIndex, 0])];
    } forEach _classes;
} forEach [getItemCargo _backpack, getMagazineCargo _backpack];

// The plain form, "ACE_fieldDressing 6 ACE_tourniquet 2": the CBA settings and the Eden fields read
// it as well as the old array, and it is the one people can read and edit by hand.
private _text = (_order apply {format ["%1 %2", _x select 1, _counts get (_x select 0)]}) joinString " ";

copyToClipboard _text;

// The same list again, one per line, so the hint is readable while the clipboard stays on the
// one line a CBA edit box takes.
private _lines = _order apply {
    format ["%1x %2", _counts get (_x select 0), [_x select 1] call FUNC(getItemName)]
};

private _mass = 0;

{
    _mass = _mass + (([_x select 1] call FUNC(getItemMass)) * (_counts get (_x select 0)));
} forEach _order;

hintSilent parseText format [
    "<t size='1.1' color='#ffb84d'>%1</t><br/><br/>%2<br/><br/><t color='#aaddaa'>%3</t>",
    LLSTRING(Debug_Title),
    [LLSTRING(Debug_Empty), _lines joinString "<br/>"] select (_order isNotEqualTo []),
    format [LLSTRING(Debug_Copied), count _order, round _mass]
];
