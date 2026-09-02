#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns how much mass a kit can hold. The CBA setting wins over the config default.
 *
 * Arguments:
 * 0: Kit class <STRING>
 *
 * Return Value:
 * Capacity in mass units <NUMBER>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getCapacity;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {0};

missionNamespace getVariable [format [QGVAR(kit_%1_capacity), _kit select KIT_ID], _kit select KIT_CAPACITY]
