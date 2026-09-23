#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Opens the pouch UI for a kit: your inventory on the left, what is inside the
 * kit on the right, drag and drop between them. Every move takes effect the
 * moment it is made.
 *
 * The kit does not have to belong to the player - a medic can open the kit of
 * an unconscious casualty, in which case the left list stays the medic's own
 * inventory and the right list is the casualty's kit. The switcher at the top
 * then offers the medic's own kits and the casualty's side by side.
 *
 * Arguments:
 * 0: Unit or crate holding the kit <OBJECT>
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

// A kit nobody has carried yet - one lying in a crate since the mission started - is not a kit of its
// own until somebody picks it up, and holds nothing that could be shown.
if ((toLowerANSI _kitClass) in EGVAR(core,needsConversion)) exitWith {
    [LLSTRING(Error_NotOpenedYet)] call ACEFUNC(common,displayTextStructured);
};

// Called straight out of the interaction menu, which is still closing.
[{
    params ["_unit", "_kitClass"];

    if !(createDialog "EFAK_PouchDialog") exitWith {
        ERROR("Could not create the pouch dialog.");
    };

    private _display = uiNamespace getVariable [QGVAR(display), displayNull];

    if (isNull _display) exitWith {};

    private _isUnit = _unit isKindOf "CAManBase";

    // Where the kit was opened decides what else the window offers: a casualty's other kits, and
    // the crate as a second source - the one the kit lies in, or else the one the player is at.
    // Both stay the same for as long as the window is open, whichever kit it switches to.
    GVAR(patient) = [objNull, _unit] select (_isUnit && {_unit isNotEqualTo ACE_player});
    GVAR(crate) = [call EFUNC(core,getNearbyContainer), _unit] select !_isUnit;
    GVAR(leftSource) = SOURCE_INVENTORY;
    GVAR(groundHolder) = objNull;
    GVAR(removedKits) = createHashMap;
    GVAR(kitStart) = createHashMap;
    GVAR(kitStartCharges) = createHashMap;

    // A fresh start: no key is known to be held, no search from last time. The sort choice stays.
    GVAR(ctrlHeld) = false;
    GVAR(shiftHeld) = false;
    GVAR(lastModifierMove) = -1;
    GVAR(searchText) = "";
    [_display] call FUNC(fillSort);
    (_display displayCtrl IDC_SHOW_ALL) cbSetChecked GVAR(showAll);
    (_display displayCtrl IDC_HINT) ctrlSetTooltip LLSTRING(Hint_Controls_Tooltip);

    // While a row is being dragged, the mouse wheel changes how many it carries and the middle
    // button takes the whole stack.
    call FUNC(onDragEnd);

    // True while dragging, so the wheel only counts and does nothing else.
    _display displayAddEventHandler ["MouseZChanged", {
        params ["", "_scroll"];

        if (!GVAR(dragging) || {_scroll == 0}) exitWith {false};

        [[-1, 1] select (_scroll > 0)] call FUNC(onDragAmount);
        true
    }];

    // The middle button during a drag is watched in fnc_onDragStart; this only keeps it from doing
    // anything else, where the window gets to see it at all.
    _display displayAddEventHandler ["MouseButtonDown", {
        params ["", "_button"];

        _button == 2 && {GVAR(dragging)}
    }];

    _display displayAddEventHandler ["MouseButtonUp", {
        params ["", "_button"];

        if (_button == 0) then {call FUNC(onDragEnd)};
    }];

    {
        private _ctrl = _display displayCtrl _x;

        // Mouse events report the modifiers too. Taking them from here as well covers a Ctrl that
        // was already down before the dialog opened, which the key handlers never saw go down.
        _ctrl ctrlAddEventHandler ["MouseButtonDown", {
            params ["", "", "", "", "_shift", "_ctrlKey"];

            GVAR(shiftHeld) = _shift;
            GVAR(ctrlHeld) = _ctrlKey;
        }];

        // Ctrl click moves the whole stack, shift click half of it.
        _ctrl ctrlAddEventHandler ["MouseButtonClick", {
            params ["_ctrl", "_button", "", "", "_shift", "_ctrlKey"];

            if (_button != 0 || {!(_shift || _ctrlKey)}) exitWith {};

            GVAR(lastModifierMove) = diag_tickTime;

            [ctrlIDC _ctrl, lnbCurSelRow _ctrl, [AMOUNT_HALF, AMOUNT_ALL] select _ctrlKey] call FUNC(transfer);
        }];

        // Double click moves a single item - but never while Ctrl or Shift is held, and never right
        // after a modifier move. The double click event carries no modifier state, so the held keys
        // come from the dialog's own tracking, and the short grace window catches a key let go a
        // moment before the second click of fast modifier clicking.
        _ctrl ctrlAddEventHandler ["LBDblClick", {
            params ["_ctrl", "_index"];

            if (GVAR(ctrlHeld) || {GVAR(shiftHeld)}) exitWith {};
            if (diag_tickTime - GVAR(lastModifierMove) < MODIFIER_GRACE) exitWith {};

            [ctrlIDC _ctrl, _index, 1] call FUNC(transfer);
        }];

        // Picking a row up shows how many the drag carries, see fnc_onDragStart.
        _ctrl ctrlAddEventHandler ["LBDrag", {
            params ["_ctrl", ["_dragged", []]];

            (_dragged param [0, []]) params ["", "", ["_class", ""]];

            // Should the engine not say which row, it is the one the mouse went down on.
            if (_class isEqualTo "" && {lnbCurSelRow _ctrl >= 0}) then {
                _class = _ctrl lnbData [lnbCurSelRow _ctrl, 0];
            };

            [_ctrl, _class] call FUNC(onDragStart);
        }];

        // Dropping onto another list moves as many as the drag carries - one, unless the mouse wheel,
        // the middle button, Ctrl or Shift said otherwise. Which list it was dropped on decides where
        // it goes, so dragging out of the kit and onto the ground list is how you put something down
        // on purpose.
        _ctrl ctrlAddEventHandler ["LBDrop", {
            params ["_ctrl", "", "", "_sourceIdc", ["_dragged", []]];

            call FUNC(onDragEnd);

            if (_sourceIdc == ctrlIDC _ctrl) exitWith {};

            private _source = (ctrlParent _ctrl) displayCtrl _sourceIdc;

            // The row the drag started on, which need not be the selected one - nobody should have
            // to click an item before they can drag it. The engine says what was picked up; its
            // class finds the row again, and every list holds each class once.
            (_dragged param [0, []]) params ["", "", ["_class", ""]];

            private _row = lnbCurSelRow _source;

            if (_class isNotEqualTo "") then {
                for "_i" from 0 to ((lnbSize _source) select 0) - 1 do {
                    if ((_source lnbData [_i, 0]) isEqualTo _class) exitWith {
                        _row = _i;
                    };
                };
            };

            // The drop event carries no modifier state either. Ctrl or Shift held on the drop still
            // count, whatever the drag carried.
            private _amount = switch (true) do {
                case (GVAR(ctrlHeld)): {AMOUNT_ALL};
                case (GVAR(shiftHeld)): {AMOUNT_HALF};
                default {GVAR(dragAmount)};
            };

            [_sourceIdc, _row, _amount, ctrlIDC _ctrl] call FUNC(transfer);
        }];
    } forEach [IDC_LIST_INVENTORY, IDC_LIST_KIT, IDC_LIST_GROUND, PREVIEW_LIST_IDCS];

    // Somebody else digging through the same kit should be visible immediately. Every move here is
    // applied the moment it is made, so there is nothing to reconcile - the lists are drawn again.
    GVAR(refreshHandler) = [QEGVAR(core,contentsChanged), {
        params ["_class", "_contents"];

        if (GVAR(applying)) exitWith {};
        if ((toLowerANSI _class) isNotEqualTo (toLowerANSI GVAR(kitClass))) exitWith {};

        call FUNC(refreshPouch);

        // Emptied somewhere else: the kit may be removed as well, which reaches this machine a
        // moment later than its contents. Looked at again once it has, so the window does not keep
        // showing a kit that is gone.
        if (_contents isEqualTo []) then {
            [{
                if !(isNull (uiNamespace getVariable [QGVAR(display), displayNull])) then {
                    call FUNC(refreshPouch);
                };
            }, [], 1] call CBA_fnc_waitAndExecute;
        };
    }] call CBA_fnc_addEventHandler;

    [_unit, _kitClass] call FUNC(selectKit);
}, [_unit, _kitClass]] call CBA_fnc_execNextFrame;
