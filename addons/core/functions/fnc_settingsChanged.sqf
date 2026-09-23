#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Rebuilds everything that is derived from the CBA settings. Called at the end of preInit, again
 * at postInit, and from every setting that needs it.
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

// Every kit type has a whitelist and a blacklist of its own.
GVAR(whitelistLookup) = createHashMap;
GVAR(blacklistLookup) = createHashMap;

{
    private _id = (GVAR(kits) get (toLowerANSI _x)) select KIT_ID;

    GVAR(whitelistLookup) set [_id, [missionNamespace getVariable [format [QGVAR(kit_%1_whitelist), _id], ""]] call _fnc_toLookup];
    GVAR(blacklistLookup) set [_id, [missionNamespace getVariable [format [QGVAR(kit_%1_blacklist), _id], ""]] call _fnc_toLookup];
} forEach GVAR(kitList);

GVAR(massCache) = createHashMap;

// What counts as medical is ACE's own answer: every item any treatment action uses (ACM's included)
// plus everything flagged ACE_isMedicalItem. ACE builds that list once at game start. The flag on
// its own misses most of it - plenty of treatment items never set it.
GVAR(medicalLookup) = createHashMap;
{
    GVAR(medicalLookup) set [toLowerANSI _x, true];
} forEach keys (uiNamespace getVariable [QACEGVAR(medical_treatment,treatmentItems), createHashMap]);

// Whatever was worked out from the old rules - the default contents first of all - is stale now.
GVAR(rulesStamp) = GVAR(rulesStamp) + 1;
