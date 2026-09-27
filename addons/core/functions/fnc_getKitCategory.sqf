#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The CBA settings section of a kit type, so that every addon puts its per kit settings into the
 * same section. Numbered in registry order, because the CBA menu sorts sections by name, after
 * "0) Quick setup & debug" and "1) General".
 *
 * Arguments:
 * 0: Kit prototype class <STRING>
 *
 * Return Value:
 * Category for CBA_fnc_addSetting <ARRAY>
 *
 * Example:
 * ["efak_IFAK"] call efak_core_fnc_getKitCategory;
 *
 * Public: No
 */

params ["_prototype"];

private _kit = [_prototype] call FUNC(getKitData);
private _index = GVAR(kitList) findIf {_x == (_kit param [KIT_ITEM, ""])};

[CBA_SETTINGS_EFAK, format ["%1) %2", _index + 2, _kit param [KIT_SHORT_NAME, _kit param [KIT_ID, ""]]]]
