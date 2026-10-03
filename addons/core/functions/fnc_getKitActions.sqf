#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Builds the interaction menu for every kit a unit carries. Everything shown
 * here is generated at runtime, so renaming a kit in the CBA settings or
 * changing its contents shows up immediately.
 *
 * Arguments:
 * 0: Unit carrying the kits <OBJECT>
 * 1: Player <OBJECT>
 * 2: Only kits of this interaction group, see EFAK_KitGroups; "" for any <STRING> (default: "")
 *
 * Return Value:
 * Child actions <ARRAY>
 *
 * Example:
 * [player, player] call efak_core_fnc_getKitActions;
 *
 * Public: No
 */

params ["_target", "_player", ["_group", ""]];

private _actions = [];

{
    private _kitClass = _x;
    private _icon = [_kitClass] call FUNC(getKitIcon);
    private _contents = [_kitClass] call FUNC(getContents);
    private _children = [];

    // The kit's own entry opens it as well - clicking it rather than one of its children - but not
    // everybody finds that, so it is spelled out as the first entry.
    private _open = [
        QGVAR(open),
        LLSTRING(Action_OpenKit),
        _icon,
        {
            (_this select 2) params ["_kitClass"];
            [_target, _kitClass] call FUNC(openKit);
        },
        {true},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);
    _children pushBack [_open, [], _target];

    // Empty the whole kit in one go.
    private _unpackAll = [
        QGVAR(unpackAll),
        LLSTRING(Action_UnpackAll),
        _icon,
        {
            (_this select 2) params ["_kitClass"];
            [_player, _kitClass, _target] call FUNC(unpackAll);
        },
        {!(([_this select 2 select 0] call FUNC(getContents)) isEqualTo [])},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);
    _children pushBack [_unpackAll, [], _target];

    private _show = [
        QGVAR(showContents),
        LLSTRING(Action_ShowContents),
        _icon,
        {(_this select 2) params ["_kitClass"]; [_kitClass, _target] call FUNC(showContents)},
        {true},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);
    _children pushBack [_show, [], _target];

    // One entry per stack, so you can take a single type of item out instead of
    // dumping the whole kit on the ground. Off by default: a full MFAK makes a list longer than the
    // screen, and the kit window does the same job better.
    if ([_kitClass, "itemActions", false] call FUNC(getKitSetting)) then {
        // An opened magazine is an entry of its own (fnc_getKitRows).
        {
            _x params ["_itemClass", "_count", "_which", "_name"];

            private _action = [
                format [QGVAR(take_%1_%2), _itemClass, _which],
                format ["%1x %2", _count, _name],
                [_itemClass] call FUNC(getItemPicture),
                {
                    (_this select 2) params ["_kitClass", "_itemClass", "_count", "_which"];
                    [_player, _kitClass, _itemClass, _count, _target, false, _which] call FUNC(unpackItem);
                },
                {true},
                {},
                [_kitClass, _itemClass, _count, _which]
            ] call ACEFUNC(interact_menu,createAction);

            _children pushBack [_action, [], _target];
        } forEach ([_kitClass] call FUNC(getKitRows));
    };

    private _used = [_contents] call FUNC(getUsedCapacity);
    private _capacity = [_kitClass] call FUNC(getCapacity);

    private _action = [
        format [QGVAR(kit_%1), _kitClass],
        format ["%1 (%2/%3)", [_kitClass] call FUNC(getKitShortName), round _used, round _capacity],
        _icon,
        {
            (_this select 2) params ["_kitClass"];
            [_target, _kitClass] call FUNC(openKit);
        },
        {true},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);

    _actions pushBack [_action, _children, _target];
} forEach (([_target] call FUNC(getCarriedKits)) select {
    _group isEqualTo "" || {(([_x] call FUNC(getKitData)) param [KIT_GROUP, "FirstAid"]) == _group}
});

_actions
