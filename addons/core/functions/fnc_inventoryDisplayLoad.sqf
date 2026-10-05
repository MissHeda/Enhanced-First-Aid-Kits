#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Makes a double click on a kit in the inventory open it.
 *
 * Works for kits in the player's own pockets as well as ones lying in the crate
 * or vehicle they have open - findKitHolder sorts out which.
 *
 * Arguments:
 * 0: Inventory display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 602] call efak_core_fnc_inventoryDisplayLoad;
 *
 * Public: No
 */

params ["_display"];

// The names players gave their kits, in place of the item's own name - every frame the inventory is
// open, since the engine writes its own names back whenever something moves. Nothing to do, and
// nothing done, while no kit has a name.
[{
    params ["_display", "_handle"];

    if (isNull _display) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    if (count GVAR(labels) == 0 && {count GVAR(typeNames) == 0}) exitWith {};

    [_display] call FUNC(labelInventoryLists);
}, 0, _display] call CBA_fnc_addPerFrameHandler;

if !(missionNamespace getVariable [QGVAR(doubleClickOpen), true]) exitWith {};

{
    private _ctrl = _display displayCtrl _x;

    if (isNull _ctrl) then {continue};

    _ctrl ctrlAddEventHandler ["LBDblClick", {
        params ["_ctrl", "_index"];

        // The inventory lists are listNBoxes, but do not bet the whole feature
        // on that staying true across patches.
        private _item = if (ctrlType _ctrl == 102) then {
            _ctrl lnbData [_index, 0]
        } else {
            _ctrl lbData _index
        };

        if !([_item] call FUNC(isKit)) exitWith {};

        private _owner = [_item] call FUNC(findKitHolder);

        if (isNull _owner) exitWith {};

        [_owner, _item] call FUNC(openKit);
    }];
} forEach [IDC_ITEMLIST_GROUND, IDC_ITEMLIST_UNIFORM, IDC_ITEMLIST_VEST, IDC_ITEMLIST_BACKPACK];
