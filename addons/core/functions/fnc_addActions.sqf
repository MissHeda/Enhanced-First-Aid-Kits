#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Registers the ACE interaction entries. Everything below the root is built at
 * runtime by fnc_getKitActions, which is what makes kit names, capacities and
 * contents configurable instead of baked into the config.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_addActions;
 *
 * Public: No
 */

if !(hasInterface) exitWith {};

private _fnc_text = {
    if ((_this select [0, 1]) == "$") then {localize (_this select [1])} else {_this}
};

// One menu per group of EFAK_KitGroups: the first aid kits under their own entry, the pouches of
// another mod under theirs. The first aid kits keep the action names they always had.
{
    private _group = configName _x;
    private _suffix = ["_" + _group, ""] select (_group == "FirstAid");
    private _icon = getText (_x >> "icon");

    // ACE builds the self action tree under a synthetic "ACE_SelfActions" root, so
    // that has to be the first element of the parent path.
    private _selfAction = [
        QGVAR(root) + _suffix,
        (getText (_x >> "displayName")) call _fnc_text,
        _icon,
        {},
        {[_player, false, (_this select 2) select 0] call FUNC(hasKits)},
        {[_player, _player, (_this select 2) select 0] call FUNC(getKitActions)},
        [_group]
    ] call ACEFUNC(interact_menu,createAction);

    ["CAManBase", 1, ["ACE_SelfActions"], _selfAction, true] call ACEFUNC(interact_menu,addActionToClass);

    // Reaching into someone else's kit - the medic case. Off limits while they are
    // awake unless the mission says otherwise.
    private _targetAction = [
        QGVAR(rootOther) + _suffix,
        (getText (_x >> "displayNameOther")) call _fnc_text,
        _icon,
        {},
        {
            GVAR(interactWithOthers)
            && {GVAR(interactWithAwake) || {!([_target] call ACEFUNC(common,isAwake))}}
            && {
                // An AI's kits may still be prototypes; they show up here once they are real kits.
                [_target] call FUNC(requestUnitKits);
                [_target, false, (_this select 2) select 0] call FUNC(hasKits)
            }
        },
        {[_target, _player, (_this select 2) select 0] call FUNC(getKitActions)},
        [_group]
    ] call ACEFUNC(interact_menu,createAction);

    ["CAManBase", 0, ["ACE_MainActions"], _targetAction, true] call ACEFUNC(interact_menu,addActionToClass);
} forEach ("true" configClasses (configFile >> "EFAK_KitGroups"));
