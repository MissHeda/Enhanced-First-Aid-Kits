#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Opens the small contents window for a kit: its picture and name, how full it is, and every item
 * with its picture and count. A stack can be taken out whole (Take, or a double click). Kept up to
 * date while it is open - somebody else taking a bandage out of the same kit shows at once.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Who or what holds the kit - a unit or a crate <OBJECT> (default: ACE_player)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", player] call efak_gui_fnc_showContents;
 *
 * Public: Yes
 */

params ["_kitClass", ["_holder", objNull]];

if (!hasInterface || {!([_kitClass] call EFUNC(core,isKit))}) exitWith {};

if (isNull _holder) then {_holder = ACE_player};

// Called straight out of the interaction menu, which is still closing.
[{
    params ["_kitClass", "_holder"];

    if !(createDialog "EFAK_ContentsPopup") exitWith {
        ERROR("Could not create the contents window.");
    };

    GVAR(contentsKit) = _kitClass;
    GVAR(contentsHolder) = _holder;

    call FUNC(fillContentsPopup);

    GVAR(contentsHandler) = [QEGVAR(core,contentsChanged), {
        params ["_class"];

        if ((toLowerANSI _class) isEqualTo (toLowerANSI GVAR(contentsKit))) then {
            call FUNC(fillContentsPopup);
        };
    }] call CBA_fnc_addEventHandler;
}, [_kitClass, _holder]] call CBA_fnc_execNextFrame;
