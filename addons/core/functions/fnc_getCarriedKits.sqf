#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns every kit instance a unit is carrying. Prototypes
 * are skipped - they are not usable until they have been given an identity.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Kit instance classes <ARRAY>
 *
 * Example:
 * [player] call efak_core_fnc_getCarriedKits;
 *
 * Public: Yes
 */

params ["_unit"];

private _kits = [];

{
    private _key = toLowerANSI _x;
    if (_key in GVAR(prototypeOf) && {!(_key in GVAR(needsConversion))}) then {
        _kits pushBackUnique _x;
    };
} forEach (items _unit);

_kits
