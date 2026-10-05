#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Shows the names players gave their kits (fnc_setKitLabel), and those the mission gave a kit type
 * (fnc_getTypeName), in the game's own inventory: the rows of those kits in the ground, container,
 * uniform, vest and backpack lists read the name, their tooltip the name and what the kit is.
 *
 * The engine fills those lists again whenever something changes, with the item's own name, so this
 * runs every frame the inventory is open (fnc_inventoryDisplayLoad) - but only while some kit has a
 * name, and it only touches the rows of named kits.
 *
 * Arguments:
 * 0: Inventory display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 602] call efak_core_fnc_labelInventoryLists;
 *
 * Public: No
 */

params ["_display"];

{
    private _ctrl = _display displayCtrl _x;

    if (isNull _ctrl) then {continue};

    // Plain list boxes today; list n boxes are read the same way should a patch change that.
    private _grid = ctrlType _ctrl == 102;
    private _rows = if (_grid) then {(lnbSize _ctrl) select 0} else {lbSize _ctrl};
    private _renamed = false;

    for "_row" from 0 to _rows - 1 do {
        private _class = if (_grid) then {_ctrl lnbData [_row, 0]} else {_ctrl lbData _row};
        private _label = GVAR(labels) getOrDefault [toLowerANSI _class, ""];

        if (_label isEqualTo "") then {_label = [_class] call FUNC(getTypeName)};
        if (_label isEqualTo "") then {continue};

        if (_grid) then {
            if ((_ctrl lnbText [_row, 0]) isNotEqualTo _label) then {
                _ctrl lnbSetText [[_row, 0], _label];
                _renamed = true;
            };
        } else {
            if ((_ctrl lbText _row) isNotEqualTo _label) then {
                _ctrl lbSetText [_row, _label];
                _renamed = true;
                _ctrl lbSetTooltip [_row, format ["%1\n%2", _label, getText (configFile >> "CfgWeapons" >> _class >> "displayName")]];
            };
        };
    };

    // In among the others by the name shown, as the list sorts by name. A row carries what it stands
    // for along (ACE's item filter takes rows out the same way), and the next refresh of the list
    // brings the usual names and order back, which the next pass here renames and sorts again.
    if (_renamed) then {
        if (_grid) then {_ctrl lnbSort [0, false]} else {lbSort _ctrl};
    };
} forEach [IDC_ITEMLIST_GROUND, IDC_ITEMLIST_SOLDIER, IDC_ITEMLIST_UNIFORM, IDC_ITEMLIST_VEST, IDC_ITEMLIST_BACKPACK];
