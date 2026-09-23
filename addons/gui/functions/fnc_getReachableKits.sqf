#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Every kit the open kit window can switch to: the ones the player carries in the uniform, the vest
 * and the backpack, those of the casualty the window was opened on, and those lying in the crate.
 *
 * Only real kits - a prototype still waiting for its identity has no contents to show yet, and a kit
 * packed inside another kit is part of that kit's contents rather than a kit of its own here. A kit
 * this window emptied and removed is left out even while its removal is still on its way from the
 * machine that owns it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Kits <ARRAY> of [holder, kit instance class, where it is <STRING>], in the order they are listed
 *
 * Example:
 * call efak_gui_fnc_getReachableKits;
 *
 * Public: No
 */

private _kits = [];
private _seen = createHashMap;

private _fnc_add = {
    params ["_holder", "_classes", "_where"];

    {
        private _key = toLowerANSI _x;

        if !(_key in EGVAR(core,prototypeOf)) then {continue};
        if (_key in EGVAR(core,needsConversion)) then {continue};

        // A class is one kit whatever holds it - a copy of it has the same contents.
        if (_key in _seen) then {continue};
        _seen set [_key, true];

        if (_key in GVAR(removedKits)) then {continue};

        _kits pushBack [_holder, _x, _where];
    } forEach _classes;
};

[ACE_player, uniformItems ACE_player, LELSTRING(core,Container_Uniform)] call _fnc_add;
[ACE_player, vestItems ACE_player, LELSTRING(core,Container_Vest)] call _fnc_add;
[ACE_player, backpackItems ACE_player, LELSTRING(core,Container_Backpack)] call _fnc_add;

private _patient = GVAR(patient);

if (!isNull _patient && {_patient isNotEqualTo ACE_player}) then {
    [_patient, items _patient, name _patient] call _fnc_add;
};

private _crate = GVAR(crate);

if (!isNull _crate) then {
    [_crate, (getItemCargo _crate) param [0, []], LLSTRING(Header_Crate)] call _fnc_add;
};

// A removed kit that is nowhere to be found any more is gone for good. Its instance can be handed
// out again, and that kit must not stay hidden.
{
    if !(_x in _seen) then {GVAR(removedKits) deleteAt _x};
} forEach (keys GVAR(removedKits));

_kits
