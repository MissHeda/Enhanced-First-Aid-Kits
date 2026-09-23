#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether players may add items to this type of kit by hand at all - in the kit window, or in
 * the kits tab of the ACE Arsenal.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 * 1: In the ACE Arsenal <BOOL> (default: false)
 *
 * Return Value:
 * Packing allowed <BOOL>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_canPackInto;
 *
 * Public: Yes
 */

params ["_kitClass", ["_arsenal", false]];

if (_arsenal) exitWith {
    ([_kitClass] call FUNC(getArsenalEditing)) == EDIT_ALL
};

[_kitClass, "packing", true] call FUNC(getKitSetting)
