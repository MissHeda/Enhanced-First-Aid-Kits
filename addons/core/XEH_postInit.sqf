#include "script_component.hpp"

// ---------------------------------------------------------------------------
// Contents replication
//
// Contents live on the classname, not on the item, so every machine keeps the
// same lookup table. The server owns the master copy and hands it to anyone
// joining in progress. The events that change the table are registered in
// preInit, see there.
// ---------------------------------------------------------------------------

// Removing an item only works on the machine the unit is local on.
[QGVAR(removeItem), {
    params ["_holder", "_class"];

    if !(local _holder) exitWith {};

    // A kit lying in a crate is cargo, not a carried item, and answers to a different command.
    if (_holder isKindOf "CAManBase") then {
        _holder removeItem _class;
    } else {
        _holder addItemCargoGlobal [_class, -1];
    };
}] call CBA_fnc_addEventHandler;

// ---------------------------------------------------------------------------
// Instance pool
//
// Only the server hands out instance ids. The unit's owner asks for one per prototype it carries,
// passing along the contents a loadout promised that kit (or -1 for the defaults), and swaps the
// prototype once the id arrives.
// ---------------------------------------------------------------------------

// Registered on every machine: whoever owns the unit when the grant arrives has to either swap it
// in or give the id back, and that can be a headless client after a locality change.
[QGVAR(grantInstance), {
    params ["_unit", "_carriedClass", "_instance", ["_slot", -1], ["_generation", 0], ["_requestId", -1]];

    if (isNull _unit || {!local _unit}) exitWith {
        [_instance] call FUNC(freeInstance);
    };

    private _pending = _unit getVariable [QGVAR(pendingConversions), createHashMap];
    private _inFlight = _pending getOrDefault [format ["%1:%2", _slot, toLowerANSI _carriedClass], []];
    private _index = _inFlight findIf {(_x select 0) == _requestId};

    if (_index > -1) then {
        _inFlight deleteAt _index;
    };

    // A loadout was set after this was requested. The prototype it was meant for went with the old
    // loadout, and one of the same type the new loadout brought may be waiting for saved contents.
    if (_generation != (_unit getVariable [QGVAR(loadoutGeneration), 0])) exitWith {
        [_instance] call FUNC(freeInstance);
    };

    // The kit may already be gone again (dropped, traded, respawned). Give the
    // id straight back instead of leaking it.
    if !([_unit, _carriedClass, _instance, _slot] call FUNC(replaceItem)) then {
        [_instance] call FUNC(freeInstance);

        // A prototype that turned up while this request was out was never asked for, and a failed
        // swap changes nothing the loadout player event would notice.
        [FUNC(convertKits), [_unit]] call CBA_fnc_execNextFrame;
    };
}] call CBA_fnc_addEventHandler;

// Somebody reached for the kits of an AI this machine owns, see fnc_requestUnitKits.
[QGVAR(convertUnitKits), {
    params ["_unit"];

    if (isNull _unit || {!local _unit} || {[_unit] call ACEFUNC(common,isPlayer)}) exitWith {};

    [_unit] call FUNC(convertKits);
}] call CBA_fnc_addEventHandler;

if (isServer) then {
    [QGVAR(requestInstance), {
        params ["_unit", "_carriedClass", "", ["_slot", -1], ["_contents", -1], ["_generation", 0], ["_requestId", -1]];

        // Nobody left to hand it to.
        if (isNull _unit) exitWith {};

        // The prototype is looked up here rather than taken from the request.
        private _prototype = GVAR(needsConversion) getOrDefault [toLowerANSI _carriedClass, ""];

        if (_prototype isEqualTo "") exitWith {
            WARNING_1("Instance requested for '%1', which is not a kit prototype.",_carriedClass);
        };

        private _instance = [_prototype] call FUNC(allocateInstance);

        if (_instance isEqualTo "") exitWith {
            WARNING_1("Could not allocate an instance for '%1'.",_prototype);
        };

        // Saved contents are checked against the packing rules before they go in.
        [_instance, _contents] call FUNC(fillNewInstance);

        // Routed by object rather than by client id, so this behaves the same in
        // single player, on a listen server and on a dedicated server.
        [
            QGVAR(grantInstance),
            [_unit, _carriedClass, _instance, _slot, _generation, _requestId],
            _unit
        ] call CBA_fnc_targetEvent;
    }] call CBA_fnc_addEventHandler;

    [QGVAR(freeInstance), {
        params ["_class"];
        [_class] call FUNC(freeInstance);
    }] call CBA_fnc_addEventHandler;

    // A unit that is deleted - a body the garbage collector clears away, an AI a Zeus deletes -
    // takes its kits with it, and their ids would stay taken for the rest of the mission. With AI
    // converting their kits too, a mission spawning waves would run through the pool. Units only:
    // a weapon holder is deleted the moment its last item is picked up, and that kit lives on.
    // A kit some other unit still carries stays: a respawn that gave the gear back with plain
    // setUnitLoadout put the body's ids on the new unit too (see fnc_dedupeKits).
    addMissionEventHandler ["EntityDeleted", {
        params ["_entity"];

        if !(_entity isKindOf "CAManBase") exitWith {};

        private _kits = [_entity] call FUNC(getCarriedKits);

        if (_kits isEqualTo []) exitWith {};

        private _elsewhere = createHashMap;

        {
            {
                _elsewhere set [toLowerANSI _x, true];
            } forEach ([_x] call FUNC(getCarriedKits));
        } forEach ((allUnits + allDeadMen) - [_entity]);

        {
            if !((toLowerANSI _x) in _elsewhere) then {
                [_x] call FUNC(freeInstance);
            };
        } forEach _kits;
    }];
} else {
    // Every machine that is not the server asks for the full table - headless clients too: they own
    // AI units, and reading those units' loadouts writes kit contents into them. At mission start
    // every client asks at once, possibly before the server is listening, so the question is asked
    // again every few seconds until the answer is in.
    [QGVAR(requestSync), [clientOwner]] call CBA_fnc_serverEvent;

    [{
        params ["_args", "_handle"];

        if (GVAR(contentsSynced)) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        _args set [0, (_args select 0) + 1];

        if ((_args select 0) > EFAK_SYNC_ATTEMPTS) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
            WARNING("No kit contents from the server - kits on this machine may show the wrong contents.");

            // Most often the mod is missing on the server: no kit gets an id there, so every kit stays
            // "being prepared" and empty. Said where the player sees it, not only in the log.
            if (hasInterface) then {
                systemChat format [LLSTRING(Sync_NoServer), GVAR(settingsCategory)];
            };
        };

        [QGVAR(requestSync), [clientOwner]] call CBA_fnc_serverEvent;
    }, EFAK_SYNC_INTERVAL, [0]] call CBA_fnc_addPerFrameHandler;
};

if !(hasInterface) exitWith {};

// ---------------------------------------------------------------------------
// Client side
// ---------------------------------------------------------------------------

["loadout", {
    params ["_unit"];

    // A respawn script may hand the old gear back a moment after the new unit arrived.
    if (CBA_missionTime < (_unit getVariable [QGVAR(dedupeUntil), -1])) then {
        [_unit] call FUNC(dedupeKits);
    };

    [_unit] call FUNC(convertKits);
    call FUNC(queueVirtualLoad);
}, true] call CBA_fnc_addPlayerEventHandler;

// Respawn, team switch and Zeus remote control hand the player a different unit, which carries
// none of the kit weight that was applied to the old one. Its prototypes may not have been
// converted either: AI does not convert, and a unit that got its loadout just before it was taken
// over may still hold contents in its restore queue.
["unit", {
    params ["_unit"];
    _unit setVariable [QGVAR(dedupeUntil), CBA_missionTime + EFAK_DEDUPE_WINDOW];
    [_unit] call FUNC(dedupeKits);
    [_unit] call FUNC(convertKits);
    call FUNC(queueVirtualLoad);
}, true] call CBA_fnc_addPlayerEventHandler;

["ace_settingsInitialized", {
    call FUNC(settingsChanged);
    [ACE_player] call FUNC(convertKits);
    call FUNC(queueVirtualLoad);
}] call CBA_fnc_addEventHandler;

call FUNC(settingsChanged);
call FUNC(addActions);
call FUNC(initInventoryHooks);

// Only the heading changes with the mods loaded; the keys are stored under the id "EFAK".
private _keybindCategory = getText (configFile >> "EFAK_Framework" >> "keybindCategory");
["EFAK", [_keybindCategory, GVAR(settingsCategory)] select (_keybindCategory isEqualTo "")] call CBA_fnc_registerKeybindModPrettyName;

// Both unbound by default. They act on the first kit the player carries.
["EFAK", QGVAR(openPouch), [LLSTRING(Keybind_OpenPouch), LLSTRING(Keybind_OpenPouch_Desc)], {
    private _kits = [ACE_player] call FUNC(getCarriedKits);
    if (_kits isEqualTo []) exitWith {false};

    // The open window cycles with its own key; the other window is closed first, never stacked.
    if (!isNull (uiNamespace getVariable ["efak_gui_display", displayNull])) exitWith {true};
    private _other = uiNamespace getVariable ["efak_gui_contentsDisplay", displayNull];
    if (!isNull _other) then {_other closeDisplay 2};

    [ACE_player, _kits select 0] call FUNC(openKit);
    true
}, {false}, []] call CBA_fnc_addKeybind;

["EFAK", QGVAR(quickAccess), [LLSTRING(Keybind_QuickAccess), LLSTRING(Keybind_QuickAccess_Desc)], {
    private _kits = [ACE_player] call FUNC(getCarriedKits);
    if (_kits isEqualTo []) exitWith {false};

    // The open window cycles with its own key; the other window is closed first, never stacked.
    if (!isNull (uiNamespace getVariable ["efak_gui_contentsDisplay", displayNull])) exitWith {true};
    private _other = uiNamespace getVariable ["efak_gui_display", displayNull];
    if (!isNull _other) then {_other closeDisplay 2};

    [_kits select 0, ACE_player] call FUNC(showContents);
    true
}, {false}, []] call CBA_fnc_addKeybind;
