#include "..\..\script_component.hpp"
/*
 * Author: Dedmen, Blue, johnb43, Miss Heda
 * ACE's own function, counting what the unit's EFAK kits hold as well (efak_medical_fnc_countItem):
 * ACM Extended counts the medic's supplies through this, and takes them with
 * efak_medical_fnc_takeItem (see acme\), which reaches into the kits too. Nothing is moved to count.
 *
 * Return how many items of type _itemType the player has in his containers (Uniform, Vest, Backpack)
 * Doesn't count assignedItems, weapons, weapon attachments, magazines in weapons
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Classname of item (Case-Sensitive) <STRING>
 *
 * Return Value:
 * Item Count <NUMBER>
 *
 * Example:
 * [bob, "FirstAidKit"] call ace_common_fnc_getCountOfItem
 *
 * Public: Yes
 */

params ["_unit", "_itemType"];

[_unit, _itemType] call efak_medical_fnc_countItem
