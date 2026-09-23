#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Adds "Open" to CBA's inventory context menu for the kits a player carries.
 *
 * The entry is registered per classname, and there are 1200 instance classes -
 * registering all of them at mission start would cost a hitch for entries
 * nobody ever sees. So they are added as kits actually turn up in a loadout.
 * Registrations are never removed again: a stale one only shows if the player
 * happens to carry that exact instance later on.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_initInventoryHooks;
 *
 * Public: No
 */

if !(hasInterface) exitWith {};

// Remember which container the player opened. Everything that has to work out where a kit came
// from, or what to offer as a second source in the pouch, starts from this.
["CAManBase", "InventoryOpened", {
    params ["_unit", "_container"];

    if (_unit isEqualTo ACE_player) then {
        GVAR(lastContainer) = _container;
    };
}] call CBA_fnc_addClassEventHandler;

["loadout", {
    params ["_unit"];

    {
        private _kitClass = _x;
        private _key = toLowerANSI _kitClass;

        if (_key in GVAR(contextMenuRegistered)) then {continue};

        GVAR(contextMenuRegistered) set [_key, true];

        [
            _kitClass,
            ["CONTAINER", "GROUND", "CARGO"],
            LLSTRING(Action_OpenKit),
            [],
            [_kitClass] call FUNC(getKitIcon),
            [
                {true},
                {true}
            ],
            {
                params ["_unit", "", "_item"];

                // The kit is not always the player's own - it may sit in a casualty's inventory
                // or in the crate they have open.
                private _owner = [_item, _unit] call FUNC(findKitHolder);

                [_owner, _item] call FUNC(openKit);
            }
        ] call CBA_fnc_addItemContextMenuOption;
    } forEach ([_unit] call FUNC(getCarriedKits));
}, true] call CBA_fnc_addPlayerEventHandler;
