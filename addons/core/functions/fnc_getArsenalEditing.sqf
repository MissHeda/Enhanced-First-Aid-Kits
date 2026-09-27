#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What the kits tab of the ACE Arsenal may change about this type of kit. The Eden editor is the
 * mission maker setting the mission up, so there it may change everything.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * EDIT_NOTHING, EDIT_REMOVE or EDIT_ALL <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getArsenalEditing;
 *
 * Public: Yes
 */

params ["_kitClass"];

if (is3DEN) exitWith {EDIT_ALL};

[_kitClass, "arsenalEditing", EDIT_ALL] call FUNC(getKitSetting)
