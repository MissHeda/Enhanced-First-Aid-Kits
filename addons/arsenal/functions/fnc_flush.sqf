#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Writes every staged kit that differs from what was last read or written.
 *
 * Kits the unit no longer carries are skipped: their instance may already belong to another kit,
 * which would inherit these contents.
 *
 * The staged edits are replayed on what the kit held before they are written, under the kit's
 * rules (see replayChanges). The list on screen is only the tab's idea of the kit - a setting that
 * changed meanwhile or a click that slipped past the interface must not reach the stored contents.
 * Whatever does not make it is dropped from the staging as well.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Something staged was held back <BOOL>
 *
 * Example:
 * call efak_arsenal_fnc_flush;
 *
 * Public: No
 */

// Before the server's copy arrives nothing was staged from real contents.
if !(EGVAR(core,contentsSynced)) exitWith {false};

private _unit = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

if (isNull _unit) exitWith {false};

private _carried = createHashMap;

{
    _carried set [toLowerANSI _x, true];
} forEach (items _unit);

private _writes = [];

{
    if (_y isEqualTo (GVAR(base) getOrDefault [_x, []])) then {continue};
    if !(_x in _carried) then {continue};

    _writes pushBack _x;
} forEach GVAR(pending);

if (_writes isEqualTo []) exitWith {false};

private _heldBack = false;

// Every write comes straight back as a contents event on this machine. Those are this tab's own
// changes and must not be merged into the staging a second time.
GVAR(writing) = true;

{
    private _kit = GVAR(classNames) getOrDefault [_x, _x];
    private _base = GVAR(base) getOrDefault [_x, []];
    private _staged = GVAR(pending) get _x;

    ([_kit, _base, _staged, _base] call FUNC(replayChanges)) params ["_contents", "_complete"];

    // When every edit made it, the staged list is written as it is, in the order things were packed.
    if (_complete) then {
        _contents = _staged;
    } else {
        _heldBack = true;
    };

    // Nothing left that the rules let through.
    if (_contents isEqualTo _base) then {
        GVAR(pending) set [_x, +_base];
        continue;
    };

    private _stored = [_kit, _contents] call EFUNC(core,setContents);

    GVAR(base) set [_x, +_stored];
    GVAR(pending) set [_x, +_stored];
} forEach _writes;

GVAR(writing) = false;

// With kit weight on, EFAK adjusts the unit's load a frame after the contents change. ACE only
// redraws its weight readout when its own panels change, which they do not while this tab is open.
[{
    private _display = findDisplay IDD_ACE_ARSENAL;
    private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

    if (isNull _display || {isNull _center} || {isNil QACEFUNC(common,getWeight)}) exitWith {};

    (_display displayCtrl IDC_ACE_TOTAL_WEIGHT_TEXT) ctrlSetText format [
        "%1 (%2)",
        _center call ACEFUNC(common,getWeight),
        [_center, 1] call ACEFUNC(common,getWeight)
    ];
}, [], 3] call CBA_fnc_execAfterNFrames;

_heldBack
