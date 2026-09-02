#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Opens the pouch UI for a kit: your inventory on the left, what is inside the
 * kit on the right, drag and drop between them.
 *
 * The kit does not have to belong to the player - a medic can open the kit of
 * an unconscious casualty, in which case the left list stays the medic's own
 * inventory and the right list is the casualty's kit.
 *
 * Arguments:
 * 0: Unit carrying the kit <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "efak_IFAK_7"] call efak_gui_fnc_openPouch;
 *
 * Public: Yes
 */

disableSerialization;

params ["_unit", "_kitClass"];

if (!hasInterface || {isNull _unit}) exitWith {};

if !([_kitClass] call EFUNC(core,isKit)) exitWith {
    WARNING_1("'%1' is not a kit instance.",_kitClass);
};

// Called straight out of the interaction menu, which is still closing.
[{
    params ["_unit", "_kitClass"];

    GVAR(owner) = _unit;
    GVAR(kitClass) = _kitClass;

    if !(createDialog "EFAK_PouchDialog") exitWith {
        ERROR("Could not create the pouch dialog.");
    };

    private _display = uiNamespace getVariable [QGVAR(display), displayNull];

    if (isNull _display) exitWith {};

    {
        private _ctrl = _display displayCtrl _x;

        // Double click moves the whole stack.
        _ctrl ctrlAddEventHandler ["LBDblClick", {
            params ["_ctrl", "_index"];
            [ctrlIDC _ctrl, _index, AMOUNT_ALL] call FUNC(transfer);
        }];

        // Ctrl click moves a single item, shift click moves half a stack.
        _ctrl ctrlAddEventHandler ["MouseButtonClick", {
            params ["_ctrl", "", "", "", "_shift", "_ctrlKey"];

            if !(_shift || _ctrlKey) exitWith {};

            [ctrlIDC _ctrl, lbCurSel _ctrl, [AMOUNT_HALF, 1] select _ctrlKey] call FUNC(transfer);
        }];

        // Dropping onto the other list moves the whole stack, the pouch feel.
        _ctrl ctrlAddEventHandler ["LBDrop", {
            params ["_ctrl", "", "", "_sourceIdc"];

            if (_sourceIdc == ctrlIDC _ctrl) exitWith {};

            private _source = (ctrlParent _ctrl) displayCtrl _sourceIdc;
            [_sourceIdc, lbCurSel _source, AMOUNT_ALL] call FUNC(transfer);
        }];
    } forEach [IDC_LIST_INVENTORY, IDC_LIST_KIT];

    // Somebody else digging through the same kit should be visible immediately.
    GVAR(refreshHandler) = [QEGVAR(core,contentsChanged), {
        params ["_class"];
        if ((toLowerANSI _class) isEqualTo (toLowerANSI GVAR(kitClass))) then {
            call FUNC(refreshPouch);
        };
    }] call CBA_fnc_addEventHandler;

    call FUNC(refreshPouch);
}, [_unit, _kitClass]] call CBA_fnc_execNextFrame;
