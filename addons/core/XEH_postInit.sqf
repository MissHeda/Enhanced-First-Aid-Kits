#include "script_component.hpp"

// ---------------------------------------------------------------------------
// Contents replication
//
// Contents live on the classname, not on the item, so every machine keeps the
// same lookup table. The server owns the master copy and hands it to anyone
// joining in progress.
// ---------------------------------------------------------------------------

[QGVAR(contentsChanged), {
    params ["_class", "_contents"];

    private _key = toLowerANSI _class;

    if (_contents isEqualTo []) then {
        GVAR(contents) deleteAt _key;
    } else {
        GVAR(contents) set [_key, _contents];
    };
}] call CBA_fnc_addEventHandler;

// Removing an item only works on the machine the unit is local on.
[QGVAR(removeItem), {
    params ["_unit", "_class"];

    if (local _unit) then {
        _unit removeItem _class;
    };
}] call CBA_fnc_addEventHandler;

if (isServer) then {
    [QGVAR(requestInstance), {
        params ["_unit", "_carriedClass", "_prototype", "_owner"];

        private _instance = [_prototype] call FUNC(allocateInstance);

        if (_instance isEqualTo "") exitWith {
            WARNING_1("Could not allocate an instance for '%1'.",_prototype);
        };

        [_instance, [_prototype] call FUNC(getDefaultContents)] call FUNC(setContents);
        [QGVAR(grantInstance), [_unit, _carriedClass, _instance], _owner] call CBA_fnc_ownerEvent;
    }] call CBA_fnc_addEventHandler;

    [QGVAR(freeInstance), {
        params ["_class"];
        [_class] call FUNC(freeInstance);
    }] call CBA_fnc_addEventHandler;

    [QGVAR(requestSync), {
        params ["_owner"];
        [QGVAR(syncAll), [toArray GVAR(contents)], _owner] call CBA_fnc_ownerEvent;
    }] call CBA_fnc_addEventHandler;
};

if !(hasInterface) exitWith {};

// ---------------------------------------------------------------------------
// Client side
// ---------------------------------------------------------------------------

[QGVAR(syncAll), {
    params ["_pairs"];
    GVAR(contents) = createHashMapFromArray _pairs;
    TRACE_1("synced kit contents",count _pairs);
}] call CBA_fnc_addEventHandler;

[QGVAR(grantInstance), {
    params ["_unit", "_carriedClass", "_instance"];

    private _key = toLowerANSI _carriedClass;
    GVAR(pendingConversions) set [_key, ((GVAR(pendingConversions) getOrDefault [_key, 0]) - 1) max 0];

    // The kit may already be gone again (dropped, traded, respawned). Give the
    // id straight back instead of leaking it.
    if !([_unit, _carriedClass, _instance] call FUNC(replaceItem)) then {
        [_instance] call FUNC(freeInstance);
    };
}] call CBA_fnc_addEventHandler;

["loadout", {
    params ["_unit"];
    [_unit] call FUNC(convertKits);
}, true] call CBA_fnc_addPlayerEventHandler;

["ace_settingsInitialized", {
    call FUNC(settingsChanged);
    [ACE_player] call FUNC(convertKits);
}] call CBA_fnc_addEventHandler;

if !(isServer) then {
    [QGVAR(requestSync), [clientOwner]] call CBA_fnc_serverEvent;
};

call FUNC(settingsChanged);
call FUNC(addActions);

["EFAK", "Enhanced First Aid Kits"] call CBA_fnc_registerKeybindModPrettyName;

["EFAK", QGVAR(openPouch), [LLSTRING(Keybind_OpenPouch), LLSTRING(Keybind_OpenPouch_Desc)], {
    private _kits = [ACE_player] call FUNC(getCarriedKits);
    if (_kits isEqualTo []) exitWith {false};

    [ACE_player, _kits select 0] call EFUNC(gui,openPouch);
    true
}, {false}, []] call CBA_fnc_addKeybind;
