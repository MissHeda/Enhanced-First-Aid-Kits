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

private _fnc_category = {
    params ["_kit"];

    private _category = _kit param [KIT_CATEGORY, ""];

    if (_category isEqualTo "") exitWith {GVAR(settingsCategory)};
    if ((_category select [0, 1]) == "$") exitWith {localize (_category select [1])};

    _category
};

private _kit = [_prototype] call FUNC(getKitData);
private _category = [_kit] call _fnc_category;

// Numbered in registry order among the kits of the same category. The framework's own category
// starts at 2, after "1) General"; a mod with a category of its own (its pouches, its bags) at 1.
private _same = GVAR(kitList) select {([GVAR(kits) get (toLowerANSI _x)] call _fnc_category) == _category};
private _index = _same findIf {_x == (_kit param [KIT_ITEM, ""])};
private _name = _kit param [KIT_SHORT_NAME, _kit param [KIT_ID, ""]];
private _first = [1, 2] select (_category == GVAR(settingsCategory));

[_category, format ["%1) %2", _index + _first, _name]]
