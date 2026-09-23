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
