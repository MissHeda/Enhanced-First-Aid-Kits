#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Writes the contents of a kit instance and broadcasts them to every machine.
 * This is the only place that changes kit contents.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents <ARRAY> of [class, count]
 *
 * Return Value:
 * Cleaned contents that were stored <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7", [["ACE_morphine", 2]]] call efak_core_fnc_setContents;
 *
 * Public: Yes
 */

params ["_class", ["_contents", [], [[]]]];

_contents = [_contents] call FUNC(normalizeContents);

[QGVAR(contentsChanged), [_class, _contents]] call CBA_fnc_globalEvent;

_contents
