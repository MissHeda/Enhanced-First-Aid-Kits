#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether a unit is carrying any kit at all.
 *
 * The same question getCarriedKits answers, without building the list: this is asked every frame
 * an ACE interaction menu is open, once per unit in reach.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Count kits that are not usable yet - prototypes still waiting for an instance id <BOOL>
 *    (default: false)
 *
 * Return Value:
 * Carries a kit <BOOL>
 *
 * Example:
 * [player] call efak_core_fnc_hasKits;
 *
 * Public: Yes
 */

params ["_unit", ["_anyState", false]];

if (isNull _unit) exitWith {false};

private _fnc_isKit = {
    private _key = toLowerANSI _this;
    _key in GVAR(prototypeOf) && {_anyState || {!(_key in GVAR(needsConversion))}}
};

((items _unit) findIf {_x call _fnc_isKit}) != -1
