#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How full the opened magazines of a class are, to go behind its name: " (7/10)", or for more than
 * one " (3/10, 7/10)". "" when none is opened.
 *
 * Arguments:
 * 0: Item class <STRING>
 * 1: Rounds of each opened one <ARRAY of NUMBER>
 *
 * Return Value:
 * Text <STRING>
 *
 * Example:
 * ["ACE_painkillers", [7]] call efak_core_fnc_formatCharges;
 *
 * Public: Yes
 */

params ["_class", "_rounds"];

if (_rounds isEqualTo []) exitWith {""};

private _size = [_class] call FUNC(getMagazineSize);

format [" (%1)", (_rounds apply {format ["%1/%2", _x, _size]}) joinString ", "]
