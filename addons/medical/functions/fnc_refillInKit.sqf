#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Refills an empty item packed in one of a unit's kits - an empty oxygen tank at a medical vehicle -
 * right inside the kit: after a progress bar the empty one becomes a full one, in the same kit. For
 * other mods whose own refill only takes the empty item out of the unit's inventory.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Empty item class <STRING>
 * 2: Full item class <STRING>
 * 3: Time in seconds <NUMBER>
 * 4: Texts: progress, done, cancelled - stringtable keys or plain text <ARRAY> (default: none)
 *
 * Return Value:
 * Started, false when no kit holds the empty item <BOOL>
 *
 * Example:
 * [player, "ACM_OxygenTank_425_Empty", "ACM_OxygenTank_425", 8] call efak_medical_fnc_refillInKit;
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_emptyClass", "", [""]], ["_fullClass", "", [""]], ["_time", 1, [0]], ["_texts", ["", "", ""], [[]]]];

_texts params [["_progressText", ""], ["_doneText", ""], ["_cancelText", ""]];

([_unit, [_emptyClass]] call FUNC(findInKits)) params ["_kitClass"];

if (_kitClass isEqualTo "") exitWith {false};

[_time, [_unit, _kitClass, _emptyClass, _fullClass, _doneText, _cancelText], {
    params ["_args"];
    _args params ["_unit", "_kitClass", "_emptyClass", "_fullClass", "_doneText"];

    private _contents = [_kitClass] call EFUNC(core,getContents);
    private _key = toLowerANSI _emptyClass;
    private _index = _contents findIf {(toLowerANSI (_x select 0)) isEqualTo _key};

    // Gone from the kit in the meantime.
    if (_index < 0) exitWith {};

    (_contents select _index) params ["_stored", "_have"];

    if (_have <= 1) then {
        _contents deleteAt _index;
    } else {
        _contents set [_index, [_stored, _have - 1]];
    };

    _contents pushBack [_fullClass, 1];
    [_kitClass, _contents] call EFUNC(core,setContents);

    if (_doneText isNotEqualTo "") then {
        [_doneText, 1.5, _unit] call ACEFUNC(common,displayTextStructured);
    };
}, {
    params ["_args"];
    _args params ["_unit"];

    private _cancelText = _args param [5, ""];

    if (_cancelText isNotEqualTo "") then {
        [_cancelText, 1.5, _unit] call ACEFUNC(common,displayTextStructured);
    };
}, _progressText] call ACEFUNC(common,progressBar);

true
