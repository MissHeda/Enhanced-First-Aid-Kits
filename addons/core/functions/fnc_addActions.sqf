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

// ACE builds the self action tree under a synthetic "ACE_SelfActions" root, so
// that has to be the first element of the parent path.
private _selfAction = [
    QGVAR(root),
    LLSTRING(Action_Root),
    QPATHTOF(ui\IFAK.paa),
    {},
    {([_player] call FUNC(getCarriedKits)) isNotEqualTo []},
    {[_player, _player] call FUNC(getKitActions)}
] call ACEFUNC(interact_menu,createAction);

["CAManBase", 1, ["ACE_SelfActions"], _selfAction, true] call ACEFUNC(interact_menu,addActionToClass);

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
