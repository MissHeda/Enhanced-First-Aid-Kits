#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Writes the contents of a kit instance and broadcasts them to every machine.
 * This is the only place that changes kit contents.
 *
 * Along with the contents go the kit's opened magazines (fnc_getCharges): a pill bottle or an
 * oxygen tank that is no longer full keeps its rounds inside the kit. Left out, the kit keeps the
 * ones it has, as far as the new contents still hold them (fnc_reconcileCharges).
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents <ARRAY> of [class, count]
 * 2: Opened magazines <ARRAY> of [class, rounds], or -1 to keep them (default: -1)
 *
 * Return Value:
 * Cleaned contents that were stored <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7", [["ACE_morphine", 2]]] call efak_core_fnc_setContents;
 *
 * Public: Yes
 */

params ["_class", ["_contents", [], [[]]], ["_charges", -1, [0, []]]];

_contents = [_contents] call FUNC(normalizeContents);

if (_charges isEqualTo -1) then {
    _charges = GVAR(charges) getOrDefault [toLowerANSI _class, []];
};

_charges = [_contents, _charges] call FUNC(reconcileCharges);

[QGVAR(contentsChanged), [_class, _contents, _charges]] call CBA_fnc_globalEvent;

_contents
