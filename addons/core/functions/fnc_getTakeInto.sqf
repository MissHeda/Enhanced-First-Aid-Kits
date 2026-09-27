#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Where the player wants items taken out of this type of kit to go first.
 *
 * The mission can decide it per kit type (setting "Unload container"); otherwise the player chooses
 * in the kit window, kept in their profile per kit type - an IFAK emptied into the vest, an MFAK
 * into the backpack.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * CONTAINER_AUTO, CONTAINER_UNIFORM, CONTAINER_VEST or CONTAINER_BACKPACK <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getTakeInto;
 *
 * Public: No
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {CONTAINER_AUTO};

private _id = _kit select KIT_ID;

// Set by the mission: that is the answer, whatever the player picked before.
private _forced = missionNamespace getVariable [format [QGVAR(kit_%1_unloadContainer), _id], CONTAINER_PLAYER];

if (_forced in [CONTAINER_AUTO, CONTAINER_UNIFORM, CONTAINER_VEST, CONTAINER_BACKPACK]) exitWith {_forced};

private _pairs = profileNamespace getVariable [QGVAR(takeInto), []];
private _index = _pairs findIf {_x isEqualType [] && {(_x param [0, ""]) isEqualTo _id}};

if (_index < 0) exitWith {CONTAINER_AUTO};

private _mode = (_pairs select _index) param [1, CONTAINER_AUTO];

[CONTAINER_AUTO, _mode] select (_mode in [CONTAINER_UNIFORM, CONTAINER_VEST, CONTAINER_BACKPACK])
