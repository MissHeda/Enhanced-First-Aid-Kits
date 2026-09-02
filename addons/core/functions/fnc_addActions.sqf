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

private _selfActions = configFile >> "CfgVehicles" >> "CAManBase" >> "ACE_SelfActions";

// Slot into whichever equipment submenu exists, so the entries end up where
// people already look for them.
private _parentPath = switch (true) do {
    case (isClass (_selfActions >> "ACM_Equipment")): {["ACM_Equipment"]};
    case (isClass (_selfActions >> "ACE_Equipment")): {["ACE_Equipment"]};
    default {[]};
};

private _selfAction = [
    QGVAR(root),
    LLSTRING(Action_Root),
    QPATHTOF(ui\IFAK.paa),
    {},
    {([_player] call FUNC(getCarriedKits)) isNotEqualTo []},
    {[_player, _player] call FUNC(getKitActions)}
] call ACEFUNC(interact_menu,createAction);

["CAManBase", 1, _parentPath, _selfAction, true] call ACEFUNC(interact_menu,addActionToClass);

// Reaching into someone else's kit - the medic case. Off limits while they are
// awake unless the mission says otherwise.
private _targetAction = [
    QGVAR(rootOther),
    LLSTRING(Action_RootOther),
    QPATHTOF(ui\IFAK.paa),
    {},
    {
        GVAR(interactWithOthers)
        && {GVAR(interactWithAwake) || {!([_target] call ACEFUNC(common,isAwake))}}
        && {([_target] call FUNC(getCarriedKits)) isNotEqualTo []}
    },
    {[_target, _player] call FUNC(getKitActions)}
] call ACEFUNC(interact_menu,createAction);

["CAManBase", 0, ["ACE_MainActions"], _targetAction, true] call ACEFUNC(interact_menu,addActionToClass);
