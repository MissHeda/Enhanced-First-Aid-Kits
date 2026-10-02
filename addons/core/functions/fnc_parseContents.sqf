#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Parses a contents string as entered in the CBA settings or an Eden attribute. Two forms are read:
 *
 * - the plain list, classname then amount, separated by spaces or line breaks:
 *   "ACE_fieldDressing 6 ACE_morphine 1"
 * - the array, as older settings, exports and loadouts hold it:
 *   "[['ACE_fieldDressing',6],['ACE_morphine',1]]"
 *
 * In the plain list a classname without an amount after it counts once; "x6" and "6x" read as 6.
 *
 * Arguments:
 * 0: Contents string <STRING>
 *
 * Return Value:
 * Contents <ARRAY> of [class, count]
 *
 * Example:
 * ["ACE_fieldDressing 6 ACE_morphine 1"] call efak_core_fnc_parseContents;
 *
 * Public: Yes
 */

params [["_string", "", [""]]];

private _text = trim _string;

if (_text isEqualTo "") exitWith {[]};

if ((_text select [0, 1]) == "[") exitWith {
    private _parsed = parseSimpleArray _text;

    if !(_parsed isEqualType []) exitWith {
        WARNING_1("Could not parse contents string '%1'.",_string);
        []
    };

    [_parsed] call FUNC(normalizeContents)
};

// Plain list. Commas and semicolons count as spaces, so a list pasted from anywhere still reads.
private _tokens = (_text splitString (toString [32, 9, 10, 13, 44, 59])) select {_x != ""};
private _contents = [];
private _open = false;                                  // the last entry still waits for its amount

{
    private _token = _x;
    private _number = _token;

    // "x6" and "6x" read as 6
    if ((toLowerANSI (_token select [0, 1])) == "x") then {_number = _token select [1]};
    if ((toLowerANSI (_token select [count _token - 1])) == "x") then {_number = _token select [0, count _token - 1]};

    // A number is an amount only when all of it is digits - "10" yes, "10ACE_x" no.
    if (_number != "" && {(toArray _number) findIf {_x < 48 || {_x > 57}} == -1}) then {
        if (_open) then {
            (_contents select -1) set [1, parseNumber _number];
            _open = false;
        } else {
            WARNING_2("Contents string '%1': amount '%2' has no classname in front of it.",_string,_token);
        };
    } else {
        _contents pushBack [_token, 1];
        _open = true;
    };
} forEach _tokens;

[_contents] call FUNC(normalizeContents)
