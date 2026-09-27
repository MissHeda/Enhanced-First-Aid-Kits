#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Hands ACE's right-hand category buttons over to the kits tab, or gives them back.
 *
 * ACE's click handler would fill ACE's own, hidden list and switch ACE's right panel. While the
 * tab is open that handler is taken off the button and one that filters the kit contents goes on
 * instead. Closing the tab puts ACE's handler back, read from ACE's own config, so the buttons work
 * exactly as before whatever ACE version is loaded.
 *
 * A button whose handler cannot be found in the config keeps it - removing something that cannot
 * be put back would break the button for good. The tab's handler is added alongside, and
 * selectCategory hides whatever ACE's shows again on the next frame.
 *
 * Arguments:
 * 0: Arsenal display <DISPLAY>
 * 1: Hand over to the tab (true) or give back to ACE (false) <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 1127001, true] call efak_arsenal_fnc_hookCategoryButtons;
 *
 * Public: No
 */

params ["_display", "_takeOver"];

if (isNull _display) exitWith {};

// IDC -> ACE's onButtonClick, read once. The buttons may sit directly on ACE's display or inside a
// controls group, so one level of groups is searched as well.
if (isNil QGVAR(aceButtonHandlers)) then {
    GVAR(aceButtonHandlers) = createHashMap;
    private _wanted = [ACE_CATEGORY_BUTTONS];

    private _fnc_scan = {
        params ["_controls"];
        {
            private _idc = getNumber (_x >> "idc");
            private _handler = getText (_x >> "onButtonClick");

            if (_idc in _wanted && {_handler isNotEqualTo ""}) then {
                GVAR(aceButtonHandlers) set [_idc, _handler];
            };

            if (isClass (_x >> "controls")) then {
                {
                    private _innerIdc = getNumber (_x >> "idc");
                    private _innerHandler = getText (_x >> "onButtonClick");

                    if (_innerIdc in _wanted && {_innerHandler isNotEqualTo ""}) then {
                        GVAR(aceButtonHandlers) set [_innerIdc, _innerHandler];
                    };
                } forEach ("true" configClasses (_x >> "controls"));
            };
        } forEach ("true" configClasses _controls);
    };

    [configFile >> QACEGVAR(arsenal,display) >> "controls"] call _fnc_scan;
};

{
    private _ctrl = _display displayCtrl _x;
    if (isNull _ctrl) then {continue};

    private _aceHandler = GVAR(aceButtonHandlers) getOrDefault [_x, ""];

    if (_takeOver) then {
        if (_aceHandler isNotEqualTo "") then {
            _ctrl ctrlRemoveAllEventHandlers "ButtonClick";
        };

        private _id = _ctrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            [ctrlParent _ctrl, ctrlIDC _ctrl, true] call FUNC(selectCategory);
        }];
        GVAR(buttonHandlerIds) set [_x, _id];
    } else {
        private _id = GVAR(buttonHandlerIds) getOrDefault [_x, -1];
        GVAR(buttonHandlerIds) deleteAt _x;

        if (_aceHandler isNotEqualTo "") then {
            _ctrl ctrlRemoveAllEventHandlers "ButtonClick";
            _ctrl ctrlAddEventHandler ["ButtonClick", _aceHandler];
        } else {
            if (_id != -1) then {_ctrl ctrlRemoveEventHandler ["ButtonClick", _id]};
        };
    };
} forEach [ACE_CATEGORY_BUTTONS];
