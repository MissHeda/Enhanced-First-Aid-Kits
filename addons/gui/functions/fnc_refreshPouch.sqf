#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Redraws both lists, the capacity bar and the title of the open pouch.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_refreshPouch;
 *
 * Public: No
 */

disableSerialization;

private _display = uiNamespace getVariable [QGVAR(display), displayNull];

if (isNull _display) exitWith {};

private _unit = GVAR(owner);
private _kitClass = GVAR(kitClass);

// The kit can vanish while the pouch is open - somebody emptied it, the owner
// dropped it, or you walked away from the body you were looting.
if (isNull _unit || {!(_kitClass in (items _unit))}) exitWith {
    _display closeDisplay 2;
};

private _contents = [_kitClass] call EFUNC(core,getContents);
private _capacity = [_kitClass] call EFUNC(core,getCapacity);
private _used = [_contents] call EFUNC(core,getUsedCapacity);

(_display displayCtrl IDC_TITLE) ctrlSetText (
    if (_unit isEqualTo ACE_player) then {
        [_kitClass] call EFUNC(core,getKitName)
    } else {
        format ["%1 - %2", name _unit, [_kitClass] call EFUNC(core,getKitName)]
    }
);
(_display displayCtrl IDC_HEADER_KIT) ctrlSetText LLSTRING(Header_Kit);
(_display displayCtrl IDC_HEADER_INVENTORY) ctrlSetText LLSTRING(Header_Inventory);
(_display displayCtrl IDC_HINT) ctrlSetText LLSTRING(Hint_Controls);

(_display displayCtrl IDC_CAPACITY_TEXT) ctrlSetText format [
    "%1 %2 / %3 %4", LLSTRING(Capacity), round _used, round _capacity, LLSTRING(MassUnit)
];
(_display displayCtrl IDC_CAPACITY_BAR) progressSetPosition (
    if (_capacity > 0) then {(_used / _capacity) min 1} else {0}
);

[_display displayCtrl IDC_LIST_KIT, _contents] call FUNC(fillList);
[_display displayCtrl IDC_LIST_INVENTORY, [ACE_player, _kitClass] call FUNC(getPackableItems)] call FUNC(fillList);

(_display displayCtrl IDC_BUTTON_TO_KIT) ctrlEnable EGVAR(core,enablePacking);
(_display displayCtrl IDC_LIST_INVENTORY) ctrlEnable EGVAR(core,enablePacking);
