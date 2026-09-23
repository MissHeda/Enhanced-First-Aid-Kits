#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether every kit of this type starts with the default contents, whatever a loadout says it
 * held - so whoever hands out a loadout knows every kit in it is complete.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Contents forced <BOOL>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_isContentsForced;
 *
 * Public: Yes
 */

params ["_kitClass"];

[_kitClass, "forceContents", false] call FUNC(getKitSetting)
