#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows what is inside a kit as a hint. The quick look for when you do not want
 * to open the whole pouch UI.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_showContents;
 *
 * Public: Yes
 */

params ["_kitClass"];

private _fnc_toHex = {
    params ["_color"];
    private _hex = "#";
    {
        _hex = _hex + ([round (linearConversion [0, 1, _x, 0, 255, true])] call ACEFUNC(common,toHex));
    } forEach [_color param [0, 1], _color param [1, 1], _color param [2, 1]];
    _hex
};

private _headerColor = [missionNamespace getVariable [QGVAR(headerColor), [1, 0.8, 0.3]]] call _fnc_toHex;
private _itemColor = [missionNamespace getVariable [QGVAR(itemColor), [0.67, 0.84, 0.9]]] call _fnc_toHex;

private _contents = [_kitClass] call FUNC(getContents);
private _used = [_contents] call FUNC(getUsedCapacity);
private _capacity = [_kitClass] call FUNC(getCapacity);

private _text = format [
    "<t size='1.4' color='%1'>%2</t><br/><t size='0.8' color='%1'>%3 %4 / %5</t><br/>",
    _headerColor,
    [_kitClass] call FUNC(getKitName),
    LLSTRING(Capacity),
    round _used,
    round _capacity
];

if (_contents isEqualTo []) then {
    _text = _text + format ["<br/><t color='%1'>%2</t>", _itemColor, LLSTRING(Empty)];
} else {
    {
        _x params ["_itemClass", "_count"];
        _text = _text + format [
            "<br/><t color='%1'>%2x %3</t>",
            _itemColor,
            _count,
            [_itemClass] call FUNC(getItemName)
        ];
    } forEach _contents;
};

hintSilent parseText _text;
