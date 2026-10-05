#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives every kit of one type in a crate or vehicle the same name, from the crate's Eden attribute
 * (efak_core_crateName_<prototype>, see addons/kits/Cfg3DEN.hpp). The editor puts the property name
 * in for %s, which tells the kit type.
 *
 * Kits still waiting as their type are made real kits first, with the default contents. Runs after
 * the crate's contents field (fnc_fillCrateKits) has done its part, so a kit filled there keeps its
 * contents and gets the name too.
 *
 * Arguments:
 * 0: Crate or vehicle <OBJECT>
 * 1: Attribute property, efak_core_crateName_<prototype> <STRING>
 * 2: Name <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorObject, "efak_core_crateName_efak_MFAK", "Platoon medic"] call efak_core_fnc_nameCrateKits;
 *
 * Public: No
 */

params ["_crate", "_property", "_value"];

if (!isServer || {isNull _crate}) exitWith {};

private _prototype = _property select [count QGVAR(crateName_)];
private _label = trim _value;

if (_label isEqualTo "") exitWith {};

// fillCrateKits waits one frame for the instance pool; this waits a little longer, to come after it.
[{
    params ["_crate", "_prototype", "_label"];

    if (isNull _crate) exitWith {};

    private _key = toLowerANSI _prototype;
    private _waiting = {(toLowerANSI _x) isEqualTo _key} count (itemCargo _crate);

    if (_waiting > 0) then {
        _crate addItemCargoGlobal [_prototype, -_waiting];

        for "_i" from 1 to _waiting do {
            private _instance = [_prototype] call FUNC(allocateInstance);

            if (_instance isEqualTo "") then {
                WARNING_1("Could not allocate an instance for '%1'.",_prototype);
                continue;
            };

            [_instance, -1] call FUNC(fillNewInstance);
            _crate addItemCargoGlobal [_instance, 1];
        };
    };

    {
        private _itemKey = toLowerANSI _x;

        if (
            !(_itemKey in GVAR(needsConversion)) &&
            {(toLowerANSI (GVAR(prototypeOf) getOrDefault [_itemKey, ""])) isEqualTo _key}
        ) then {
            [_x, _label] call FUNC(setKitLabel);
        };
    } forEach (itemCargo _crate);
}, [_crate, _prototype, _label], 0.5] call CBA_fnc_waitAndExecute;
