#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Whether an item shows under the category button that is currently selected.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * Shows <BOOL>
 *
 * Example:
 * ["ACE_morphine"] call efak_arsenal_fnc_matchesCategory;
 *
 * Public: No
 */

params ["_class"];

// The kits button: in the kits tab it shows exactly what the selected kit holds, whatever category
// each item would otherwise be in.
// With "All allowed items" ticked, everything the kit may hold.
if (GVAR(category) == GVAR(kitsButtonIdc)) exitWith {
    GVAR(showAll) || {(toLowerANSI _class) in GVAR(containedKeys)}
};

if (GVAR(category) == ACE_BUTTON_MAG) exitWith {
    // Magazines for whatever the unit is carrying, worked out once per refill by fillContents.
    (toLowerANSI _class) in GVAR(compatibleMagazines)
};

private _category = [_class] call FUNC(getItemCategory);

// A kit packed inside a kit belongs to ACE's kit button, which the tab stands in for - it reads
// as a misc item here, the way every other item without a button of its own does.
if (_category == GVAR(aceKitsButtonIdc)) then {_category = ACE_BUTTON_MISC};

_category == GVAR(category)
