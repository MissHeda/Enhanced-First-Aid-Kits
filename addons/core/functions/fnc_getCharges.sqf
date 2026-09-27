#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The opened magazines in a kit: those of a magazine class with several rounds - pill bottles,
 * oxygen tanks - that are no longer full. Full ones are only counted in the contents.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Item class, "" for all of them <STRING> (default: "")
 *
 * Return Value:
 * With an item class: the rounds of each opened one, the emptiest first <ARRAY of NUMBER>
 * Without: [[class, rounds], ...] <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7", "ACE_painkillers"] call efak_core_fnc_getCharges;
 *
 * Public: Yes
 */

params ["_kitClass", ["_itemClass", ""]];

private _charges = GVAR(charges) getOrDefault [toLowerANSI _kitClass, []];

if (_itemClass isEqualTo "") exitWith {+_charges};

private _rounds = (_charges select {(_x select 0) == _itemClass}) apply {_x select 1};
_rounds sort true;

_rounds
