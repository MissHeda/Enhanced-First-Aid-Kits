#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Looks for kit prototypes and legacy 1.x classes in a unit's inventory and
 * asks the server for a real instance for each of them. Runs whenever the
 * player's loadout changes.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call efak_core_fnc_convertKits;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit || {!local _unit}) exitWith {};

// How many of each convertible class the unit is carrying right now.
private _carried = createHashMap;

{
    private _key = toLowerANSI _x;

    if (_key in GVAR(needsConversion)) then {
        _carried set [_key, (_carried getOrDefault [_key, 0]) + 1];
    };
} forEach ((items _unit) + (magazines _unit));

// Forget requests for kits that are gone again, otherwise a dropped prototype
// would block the next one from ever being converted.
{
    if !(_x in _carried) then {
        GVAR(pendingConversions) deleteAt _x;
    };
} forEach (keys GVAR(pendingConversions));

{
    private _missing = _y - (GVAR(pendingConversions) getOrDefault [_x, 0]);

    if (_missing > 0) then {
        GVAR(pendingConversions) set [_x, _y];

        for "_i" from 1 to _missing do {
            [
                QGVAR(requestInstance),
                [_unit, _x, GVAR(needsConversion) get _x, clientOwner]
            ] call CBA_fnc_serverEvent;
        };
    };
} forEach _carried;
