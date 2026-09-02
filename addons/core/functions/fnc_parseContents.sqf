#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Parses a contents string as entered in the CBA settings, e.g.
 * "[['ACE_fieldDressing',6],['ACE_morphine',1]]".
 *
 * Arguments:
 * 0: Contents string <STRING>
 *
 * Return Value:
 * Contents <ARRAY> of [class, count]
 *
 * Example:
 * ["[['ACE_morphine',1]]"] call efak_core_fnc_parseContents;
 *
 * Public: Yes
 */

params [["_string", "", [""]]];

if (_string isEqualTo "") exitWith {[]};

private _parsed = parseSimpleArray _string;

if !(_parsed isEqualType []) exitWith {
    WARNING_1("Could not parse contents string '%1'.",_string);
    []
};

[_parsed] call FUNC(normalizeContents)
