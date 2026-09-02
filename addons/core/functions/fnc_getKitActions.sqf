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
 *
 * Return Value:
 * Child actions <ARRAY>
 *
 * Example:
 * [player, player] call efak_core_fnc_getKitActions;
 *
 * Public: No
 */

params ["_target", "_player"];

private _actions = [];

{
    private _kitClass = _x;
    private _icon = [_kitClass] call FUNC(getKitIcon);
    private _contents = [_kitClass] call FUNC(getContents);
    private _children = [];

    // Empty the whole kit in one go - the 1.x behaviour.
    private _unpackAll = [
        QGVAR(unpackAll),
        LLSTRING(Action_UnpackAll),
        _icon,
        {
            (_this select 2) params ["_kitClass"];
            [_player, [_kitClass, _target], FUNC(unpackAll), LLSTRING(Progress_Unpacking)] call FUNC(startUnpack);
        },
        {!(([_this select 2 select 0] call FUNC(getContents)) isEqualTo [])},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);
    _children pushBack [_unpackAll, [], _target];

    private _show = [
        QGVAR(showContents),
        LLSTRING(Action_ShowContents),
        ([_kitClass] call FUNC(getKitData)) select KIT_ICON_INFO,
        {(_this select 2) params ["_kitClass"]; [_kitClass] call FUNC(showContents)},
        {true},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);
    _children pushBack [_show, [], _target];

    // One entry per stack, so you can take a single type of item out instead of
    // dumping the whole kit on the ground.
    {
        _x params ["_itemClass", "_count"];

        private _action = [
            format [QGVAR(take_%1), _itemClass],
            format ["%1x %2", _count, [_itemClass] call FUNC(getItemName)],
            [_itemClass] call FUNC(getItemPicture),
            {
                (_this select 2) params ["_kitClass", "_itemClass", "_count"];
                [_player, [_kitClass, _itemClass, _count, _target], FUNC(unpackItem), LLSTRING(Progress_Unpacking)] call FUNC(startUnpack);
            },
            {true},
            {},
            [_kitClass, _itemClass, _count]
        ] call ACEFUNC(interact_menu,createAction);

        _children pushBack [_action, [], _target];
    } forEach _contents;

    private _used = [_contents] call FUNC(getUsedCapacity);
    private _capacity = [_kitClass] call FUNC(getCapacity);

    private _action = [
        format [QGVAR(kit_%1), _kitClass],
        format ["%1 (%2/%3)", [_kitClass] call FUNC(getKitName), round _used, round _capacity],
        _icon,
        {
            (_this select 2) params ["_kitClass"];
            [_target, _kitClass] call EFUNC(gui,openPouch);
        },
        {true},
        {},
        [_kitClass]
    ] call ACEFUNC(interact_menu,createAction);

    _actions pushBack [_action, _children, _target];
} forEach ([_target] call FUNC(getCarriedKits));

_actions
