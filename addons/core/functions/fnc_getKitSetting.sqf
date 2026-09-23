#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads one of the per kit CBA settings for the type of a kit, e.g. "capacity" reads
 * efak_core_kit_IFAK_capacity for any IFAK.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 * 1: Setting name without the kit part, e.g. "forceContents" <STRING>
 * 2: Value when the class is not a kit or the setting does not exist yet <ANY>
 *
 * Return Value:
 * Setting value <ANY>
 *
 * Example:
 * ["efak_IFAK_7", "forceContents", false] call efak_core_fnc_getKitSetting;
 *
 * Public: Yes
 */

params ["_class", "_name", "_default"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {_default};

missionNamespace getVariable [format [QGVAR(kit_%1_%2), _kit select KIT_ID, _name], _default]
