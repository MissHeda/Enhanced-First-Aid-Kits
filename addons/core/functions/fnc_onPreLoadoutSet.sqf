#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * CBA_preLoadoutSet handler. Runs right before CBA_fnc_setLoadout hands the
 * loadout to setUnitLoadout, on the machine that called it.
 *
 * Every kit instance in the incoming loadout is turned back into its prototype,
 * in place. A loadout is a copy: whoever gets it must get kits of their own,
 * or the unit it was read from (a corpse after ACE respawn, a second player
 * loading the same saved loadout) would share contents with them. The contents
 * go into a restore queue instead, taken from the extended info, or, for a
 * loadout EFAK did not write, from the instances as they are right now.
 * fnc_onLoadoutSet passes the queue on once the loadout is on the unit.
 *
 * An AI that already carries an instance keeps it when a loadout puts the very
 * same kit back on the same unit (ACE headless transfer) - no second kit with
 * that id comes into existence that way. Only while the loadout wants the kit
 * exactly as it is: a Zeus pasting an older copy of the AI's own loadout gets
 * the contents of that copy, through a fresh kit like everybody else.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Loadout, changed in place <ARRAY>
 * 2: Extended info <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["CBA_preLoadoutSet", {_this call efak_core_fnc_onPreLoadoutSet}] call CBA_fnc_addEventHandler;
 *
 * Public: No
 */

params ["_unit", "_loadout", "_extendedInfo"];

if (isNull _unit || {!(_loadout isEqualType [])} || {count _loadout != 10}) exitWith {};

// Whatever of these the new loadout does not bring back is gone once setUnitLoadout has run.
private _heldBefore = [_unit] call FUNC(getCarriedKits);

private _entries = if (_extendedInfo isEqualType createHashMap && {QGVAR(loadoutKits) in _extendedInfo}) then {
    [_extendedInfo] call FUNC(parseLoadoutKits)
} else {
    // Not written by this version of EFAK: an older save, or a loadout put together by hand.
    // Instances still in it are copied as they are, so the new kits start out like the old ones.
    [objNull, _loadout] call FUNC(getLoadoutKits)
};

// ---------------------------------------------------------------------------
// Instances back to prototypes
// ---------------------------------------------------------------------------

private _keep = if ([_unit] call ACEFUNC(common,isPlayer)) then {[]} else {_heldBefore apply {toLowerANSI _x}};
private _kept = [];

// What the loadout wants each kit to hold, by position in the loadout.
private _wanted = createHashMap;

{
    _x params ["_slot", "_index", "", "_contents"];

    private _key = format ["%1:%2", _slot, _index];

    if !(_key in _wanted) then {
        _wanted set [_key, _contents];
    };
} forEach _entries;

// Whether a kit the unit carries already holds what the loadout wants it to. A kit without an entry
// is a fresh one, and so is every kit of a type whose contents are forced.
private _fnc_isAsWanted = {
    params ["_class", "_wish"];

    if (_wish isEqualTo LOADOUT_KIT_DEFAULT || {[_class] call FUNC(isContentsForced)}) exitWith {
        (toLowerANSI _class) in GVAR(followDefaults) ||
        {([_class] call FUNC(getCharges)) isEqualTo [] && {[_class, [_class] call FUNC(getContents)] call FUNC(isDefaultContents)}}
    };

    ([_class] call FUNC(getContentsTree)) isEqualTo _wish
};

{
    private _slot = _x;
    private _container = _loadout select _slot;

    if !(_container isEqualTypeArray ["", []]) then {continue};

    {
        if !(_x isEqualTypeArray ["", 0]) then {continue};

        private _key = toLowerANSI (_x select 0);
        private _prototype = GVAR(prototypeOf) getOrDefault [_key, ""];

        if (_prototype isEqualTo "" || {_key in GVAR(needsConversion)}) then {continue};

        private _keepIndex = if ((_x select 1) == 1) then {_keep find _key} else {-1};

        if (
            _keepIndex > -1 &&
            {!([_x select 0, _wanted getOrDefault [format ["%1:%2", _slot, _forEachIndex], LOADOUT_KIT_DEFAULT]] call _fnc_isAsWanted)}
        ) then {
            _keepIndex = -1;
        };

        if (_keepIndex > -1) then {
            _keep deleteAt _keepIndex;
            _kept pushBack [_slot, _forEachIndex];
        } else {
            _x set [0, _prototype];
        };
    } forEach (_container select 1);
} forEach [LOADOUT_SLOT_UNIFORM, LOADOUT_SLOT_VEST, LOADOUT_SLOT_BACKPACK];

// ---------------------------------------------------------------------------
// Restore queue
// ---------------------------------------------------------------------------

// While ACE Arsenal is open on this unit, kits only get what that arsenal offers. The extended
// info is left untouched: it may be the very array stored in the profile.
private _available = missionNamespace getVariable QACEGVAR(arsenal,virtualItemsFlat);
private _inArsenal = !isNil "_available" && {_unit isEqualTo (missionNamespace getVariable [QACEGVAR(arsenal,center), objNull])};

private _queue = createHashMap;

{
    _x params ["_slot", "_index", "_prototype", "_contents"];

    // The kit stayed what it was, contents included.
    private _keptIndex = _kept findIf {_x isEqualTo [_slot, _index]};

    if (_keptIndex > -1) then {
        _kept deleteAt _keptIndex;
        continue;
    };

    // A kit that follows the defaults gets the defaults - nothing of its own to check.
    if (_inArsenal && {_contents isEqualType []}) then {
        _contents = [_prototype, _contents, _available] call FUNC(filterContentsTree);

        // Loading a loadout in the arsenal can do no more to a kit than its kits tab could:
        // nothing at all, or only take things out of the default contents.
        switch ([_prototype] call FUNC(getArsenalEditing)) do {
            case EDIT_NOTHING: {
                // Its name stays, the contents go back to the defaults.
                private _label = ([_contents] call FUNC(getTreeLabel)) select 0;
                _contents = [[[KIT_MARK_DEFAULT, 1], [KIT_MARK_LABEL, _label]], LOADOUT_KIT_DEFAULT] select (_label isEqualTo "");
            };
            case EDIT_REMOVE: {
                // Offered by nothing, so every item may stay up to the amount the defaults hold.
                _contents = [_prototype, _contents, createHashMap] call FUNC(filterContentsTree);
            };
        };
    };

    private _key = format ["%1:%2", _slot, toLowerANSI _prototype];
    private _list = _queue getOrDefault [_key, []];
    _list pushBack _contents;
    _queue set [_key, _list];
} forEach _entries;

// CBA raises both events synchronously around setUnitLoadout, with nothing to tell one call from
// another. The unit is the one place that connects them, and keeps two units apart when a handler
// sets a loadout on somebody else in between.
_unit setVariable [QGVAR(loadoutSetState), [_queue, _heldBefore]];
