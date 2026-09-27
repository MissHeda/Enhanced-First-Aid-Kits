#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Keeps the amount box to digits only.
 *
 * Setting the text raises the change event again, so it is only set when something was actually
 * removed - the second pass then finds nothing to do and stops.
 *
 * Arguments:
 * 0: Amount box <CONTROL>
 * 1: New text <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, "12a"] call efak_gui_fnc_onAmountChanged;
 *
 * Public: No
 */

params ["_ctrl", "_text"];

private _digits = toString ((toArray _text) select {_x >= 48 && {_x <= 57}});

if (_digits isNotEqualTo _text) then {
    _ctrl ctrlSetText _digits;
};
