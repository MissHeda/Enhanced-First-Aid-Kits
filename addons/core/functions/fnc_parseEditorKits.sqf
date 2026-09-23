#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads the kit contents an editor unit carries in its EFAK attribute.
 *
 * The attribute holds what fnc_applyLoadoutRestore wrote there when ACE Arsenal dressed the unit in
 * the editor: "slot:prototype" -> [contents, ...] as a list of pairs, turned into a string. Anything
 * that does not read as that is ignored, so a hand-edited attribute cannot break the mission.
 *
 * Arguments:
 * 0: Attribute value <STRING>
 *
 * Return Value:
 * "slot:prototype" -> [contents, ...] <HASHMAP>
 *
 * Example:
 * ['[["4:efak_ifak",["default"]]]'] call efak_core_fnc_parseEditorKits;
 *
 * Public: No
 */

params [["_value", "", [""]]];

private _queue = createHashMap;

if (_value isEqualTo "") exitWith {_queue};

private _pairs = parseSimpleArray _value;

if !(_pairs isEqualType []) exitWith {_queue};

{
    if (_x isEqualType [] && {_x isEqualTypeParams ["", []]}) then {
        _queue set [toLowerANSI (_x select 0), +(_x select 1)];
    };
} forEach _pairs;

_queue
