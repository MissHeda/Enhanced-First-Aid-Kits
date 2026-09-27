#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Looks for kit prototypes in a unit's inventory and
 * asks the server for a real instance for each of them. Runs whenever the
 * player's loadout changes.
 *
 * Kits a loadout brought along take their saved contents with them: the unit's
 * restore queue (see fnc_applyLoadoutRestore) is matched per container and kit
 * type, and whatever is left over gets the default contents.
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

// Kit contents set up in the Eden editor, handed over by the unit's attribute at mission start.
// They wait for the kits in the restore queue like the contents of any other loadout.
private _editorKits = _unit getVariable QGVAR(editorKits);

if (!isNil "_editorKits") then {
    _unit setVariable [QGVAR(editorKits), nil];

    private _editorQueue = [_editorKits] call FUNC(parseEditorKits);

    if (count _editorQueue > 0) then {
        _unit setVariable [QGVAR(restoreQueue), [CBA_missionTime + EFAK_RESTORE_TIMEOUT, _editorQueue]];
    };
};

// Runs on every loadout change. Nothing to convert, nothing outstanding, nothing to do - and no
// hashmaps built for it either.
if (
    isNil {_unit getVariable QGVAR(pendingConversions)} &&
    {isNil {_unit getVariable QGVAR(restoreQueue)}} &&
    {!([_unit, true] call FUNC(hasKits))}
) exitWith {};

private _generation = _unit getVariable [QGVAR(loadoutGeneration), 0];

// Outstanding requests live on the unit, not in one global table: a player who respawns or takes
// over another unit must not have the old body's requests count against the new one.
private _pending = _unit getVariable QGVAR(pendingConversions);

if (isNil "_pending") then {
    _pending = createHashMap;
    _unit setVariable [QGVAR(pendingConversions), _pending];
};

// Contents a loadout promised to the kits it brought. Too old means the kits it was meant for were
// never converted (removed again, or the unit never became a player), so they do not apply any more.
private _queue = createHashMap;

(_unit getVariable [QGVAR(restoreQueue), []]) params [["_expires", -1], ["_restoreQueue", createHashMap]];

if (_expires >= 0) then {
    if (CBA_missionTime > _expires) then {
        _unit setVariable [QGVAR(restoreQueue), nil];
    } else {
        _queue = _restoreQueue;
    };
};

// How many of each convertible class every container holds right now. The container matters: two
// kits of the same type can hold different contents, and only the container tells them apart.
private _carried = createHashMap;

{
    _x params ["_slot", "_classes"];

    {
        private _class = toLowerANSI _x;

        if (_class in GVAR(needsConversion)) then {
            private _key = format ["%1:%2", _slot, _class];
            private _entry = _carried getOrDefault [_key, [_slot, _x, 0]];
            _entry set [2, (_entry select 2) + 1];
            _carried set [_key, _entry];
        };
    } forEach _classes;
} forEach [
    [LOADOUT_SLOT_UNIFORM, uniformItems _unit],
    [LOADOUT_SLOT_VEST, vestItems _unit],
    [LOADOUT_SLOT_BACKPACK, backpackItems _unit]
];

// Forget requests for kits that are gone again, otherwise a dropped prototype
// would block the next one from ever being converted.
{
    if !(_x in _carried) then {
        _pending deleteAt _x;
    };
} forEach (keys _pending);

private _served = [];

{
    _y params ["_slot", "_class", "_count"];

    private _inFlight = _pending getOrDefault [_x, []];
    private _missing = _count - (count _inFlight);

    if (_missing <= 0) then {continue};

    _pending set [_x, _inFlight];

    private _prototype = GVAR(needsConversion) get (toLowerANSI _class);
    private _queueKey = format ["%1:%2", _slot, toLowerANSI _prototype];
    private _promised = _queue getOrDefault [_queueKey, []];

    for "_i" from 1 to _missing do {
        private _contents = if (_promised isEqualTo []) then {-1} else {_promised deleteAt 0};

        GVAR(nextRequestId) = GVAR(nextRequestId) + 1;

        // Recorded before the request goes out: on a host the grant comes back before
        // serverEvent even returns.
        _inFlight pushBack [GVAR(nextRequestId), _contents];

        [
            QGVAR(requestInstance),
            [_unit, _class, _prototype, _slot, _contents, _generation, GVAR(nextRequestId)]
        ] call CBA_fnc_serverEvent;
    };

    _served pushBackUnique _queueKey;
} forEach _carried;

// Every kit of these types in these containers has its request now. Whatever the loadout promised
// beyond that belongs to kits that did not make it (an overfilled container the arsenal trimmed),
// and must not end up in a prototype picked up later.
{
    _queue deleteAt _x;
} forEach _served;
