#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Sets many EFAK settings at once to one of the realism modes of the "Fast edit" setting, as if a
 * settings file had been imported, and puts the fast edit box back to "Choose".
 *
 * Only the rules are touched: capacities, default contents, whitelists and blacklists are what a
 * mission sets up for its own kits and stay as they are. Kits marked "bag = 1" in EFAK_Kits (the MFAK
 * and the MFAK+, or a third party bag) count as bags: in the hard modes they are unloaded into the
 * backpack and have to be unpacked before a treatment can use what is in them.
 *
 * Runs where the choice is stored: the server (the settings menu's server tab, single player too)
 * or the Eden editor (the mission tab). Every value it sets is forced as far as that source can:
 * a server value overrides the mission's and every client's, a mission value every client's. A mode
 * is meant to hold for everybody, not to be undone by a setting somewhere else.
 *
 * The item lists - default contents, whitelists, blacklists - are never touched: a mission writes
 * its own items into them, and a mode must not throw that away. Afterwards the settings menu opens
 * again, so the result can be seen straight away.
 *
 * Arguments:
 * 0: PRESET_* <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [PRESET_HARDCORE] call efak_core_fnc_applyPreset;
 *
 * Public: No
 */

params ["_preset"];

if (_preset == PRESET_NONE) exitWith {};

private _source = switch (true) do {
    case (is3DEN): {"mission"};
    case (isServer): {"server"};
    default {""};
};

// Chosen somewhere this machine does not store, or already applied and put back.
if (_source isEqualTo "" || {([QGVAR(preset), _source] call CBA_settings_fnc_get) != _preset}) exitWith {};

// [nesting, others' kits, conscious units' kits, kit weight] and per kit
// [force, limit, packing, arsenal editing, item filter, removeWhenEmpty, [unload, treat out of] for kits, for bags]
private _values = switch (_preset) do {
    case PRESET_SANDBOX: {[
        [true, true, true, 0],
        [false, false, true, EDIT_ALL, FILTER_ALL, false, [CONTAINER_PLAYER, true], [CONTAINER_PLAYER, true]]
    ]};
    case PRESET_NORMAL: {[
        [false, true, false, 0.5],
        [false, false, true, EDIT_ALL, FILTER_MEDICAL, false, [CONTAINER_PLAYER, true], [CONTAINER_PLAYER, true]]
    ]};
    case PRESET_HARDCORE: {[
        [false, true, false, 1],
        [false, true, true, EDIT_REMOVE, FILTER_MEDICAL, false, [CONTAINER_PLAYER, true], [CONTAINER_BACKPACK, false]]
    ]};
    case PRESET_HARDCORE_PLUS: {[
        [false, true, false, 1],
        [true, true, true, EDIT_NOTHING, FILTER_MEDICAL, true, [CONTAINER_PLAYER, true], [CONTAINER_BACKPACK, false]]
    ]};
    case PRESET_FIXED: {[
        [false, true, false, 0.5],
        [true, true, false, EDIT_NOTHING, FILTER_MEDICAL, false, [CONTAINER_PLAYER, true], [CONTAINER_PLAYER, true]]
    ]};
    default {[]};
};

if (_values isEqualTo []) exitWith {};

_values params ["_general", "_perKit"];
_general params ["_nesting", "_others", "_awake", "_weight"];
_perKit params ["_force", "_limit", "_packing", "_editing", "_filter", "_removeEmpty", "_kitValues", "_bagValues"];

private _pairs = [
    [QGVAR(allowNesting), _nesting],
    [QGVAR(interactWithOthers), _others],
    [QGVAR(interactWithAwake), _awake],
    [QGVAR(kitWeight), _weight]
];

{
    private _kit = GVAR(kits) get (toLowerANSI _x);
    private _id = _kit select KIT_ID;

    // Marked in the registry rather than judged by capacity: compat addons raise capacities, and an
    // AFAK with room for 100 is still a pouch.
    private _isBag = getNumber (configFile >> "EFAK_Kits" >> _id >> "bag") > 0;

    ([_kitValues, _bagValues] select _isBag) params ["_unload", "_treat"];

    _pairs append [
        [format [QGVAR(kit_%1_forceContents), _id], _force],
        [format [QGVAR(kit_%1_limitToDefaults), _id], _limit],
        [format [QGVAR(kit_%1_packing), _id], _packing],
        [format [QGVAR(kit_%1_arsenalEditing), _id], _editing],
        [format [QGVAR(kit_%1_itemFilter), _id], _filter],
        [format [QGVAR(kit_%1_unloadContainer), _id], _unload],
        [format [QGVAR(kit_%1_removeWhenEmpty), _id], _removeEmpty],
        [format ["efak_medical_kit_%1_useFrom", _id], _treat]
    ];
} forEach GVAR(kitList);

// Forced: over the mission and the clients from the server, over the clients from the mission.
private _forced = [1, 2] select (_source isEqualTo "server");

private _fnc_set = {
    params ["_name", "_value", "_priority"];

    // A setting of an addon that is not loaded.
    if (isNil {missionNamespace getVariable _name}) exitWith {};

    if (isNil "_priority") then {
        _priority = [_name, _source] call CBA_settings_fnc_priority;
    };

    if (isNil "_priority") then {_priority = 0};

    [_name, _value, _priority, _source, true] call CBA_settings_fnc_set;
};

{
    [_x select 0, _x select 1, _forced] call _fnc_set;
} forEach _pairs;

// Back to "Choose", so the next mission start does not apply it again over changes made since.
[QGVAR(preset), PRESET_NONE] call _fnc_set;

// The menu was closed with OK a moment ago; open it again to show what changed.
if (hasInterface) then {
    [[1, 0.5] select is3DEN] call FUNC(reopenSettings);
};

INFO_2("Realism mode %1 applied to %2 settings.",_preset,count _pairs);
