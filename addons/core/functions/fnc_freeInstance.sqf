#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns an instance class to its pool and clears its contents. Runs on the
 * server, but may be called from anywhere. Kits packed inside it are freed as
 * well, since they only ever existed inside this one.
 *
 * Arguments:
 * 0: Instance class <STRING>
 * 1: Nesting depth, internal <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_freeInstance;
 *
 * Public: No
 */

params ["_class", ["_depth", 0]];

if !(isServer) exitWith {
    [QGVAR(freeInstance), [_class]] call CBA_fnc_serverEvent;
};

private _key = toLowerANSI _class;

// A kit that goes away takes whatever is packed inside it along. Without this, every restored
// loadout with nested kits that does not make it into an inventory would leak their ids.
// The depth limit only guards against contents that somehow reference their own kit.
if (_depth <= EFAK_RESTORE_MAX_DEPTH) then {
    {
        _x params [["_item", "", [""]]];

        private _itemKey = toLowerANSI _item;

        if (
            _itemKey isNotEqualTo _key &&
            {_itemKey in GVAR(prototypeOf)} &&
            {!(_itemKey in GVAR(needsConversion))}
        ) then {
            [_item, _depth + 1] call FUNC(freeInstance);
        };
    } forEach (GVAR(contents) getOrDefault [_key, []]);
};

GVAR(usedInstances) deleteAt _key;

// The next kit to get this id starts out plain.
if (_key in GVAR(followDefaults)) then {
    [QGVAR(followDefaultsChanged), [_class, false]] call CBA_fnc_globalEvent;
};

[QGVAR(contentsChanged), [_class, []]] call CBA_fnc_globalEvent;

// ...and without a name.
if (_key in GVAR(labels)) then {
    [QGVAR(labelChanged), [_class, ""]] call CBA_fnc_globalEvent;
};
