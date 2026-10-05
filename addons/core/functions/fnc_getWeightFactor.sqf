#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How much of what a kit holds its carrier feels: its "Contents weight" setting.
 *
 * 0 is off, 1 the honest weight, anything in between or above scales it.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Factor <NUMBER>
 *
 * Example:
 * ["efak_MFAKPlus_7"] call efak_core_fnc_getWeightFactor;
 *
 * Public: No
 */

params ["_kitClass"];

private _kit = [_kitClass] call FUNC(getKitData);

if (_kit isEqualTo []) exitWith {0};

(missionNamespace getVariable [format [QGVAR(kit_%1_weight), _kit select KIT_ID], 0.5]) max 0
