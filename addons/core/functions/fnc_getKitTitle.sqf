#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * What a kit is called where there is room for one short name: the name a player gave it, else its
 * type's short name ("IFAK").
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Name <STRING>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getKitTitle;
 *
 * Public: No
 */

params ["_kitClass"];

private _label = [_kitClass] call FUNC(getKitLabel);

[_label, [_kitClass] call FUNC(getKitShortName)] select (_label isEqualTo "")
