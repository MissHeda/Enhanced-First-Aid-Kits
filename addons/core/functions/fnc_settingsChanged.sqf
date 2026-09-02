#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Rebuilds everything that is derived from the CBA settings. Called once at
 * postInit and again from every setting that needs it.
 *
 * The interaction menu builds its entries live via insertChildren, so a renamed
 * kit or a changed capacity shows up without any cache flushing.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_settingsChanged;
 *
 * Public: No
 */

private _fnc_toLookup = {
    params ["_string"];

    private _lookup = createHashMap;

    {
        if (_x isNotEqualTo "") then {
            _lookup set [toLowerANSI _x, true];
        };
    } forEach (_string splitString " ,;");

    _lookup
};

GVAR(whitelistLookup) = [missionNamespace getVariable [QGVAR(whitelist), ""]] call _fnc_toLookup;
GVAR(blacklistLookup) = [missionNamespace getVariable [QGVAR(blacklist), ""]] call _fnc_toLookup;
GVAR(massCache) = createHashMap;
