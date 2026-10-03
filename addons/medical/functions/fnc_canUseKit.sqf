#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Whether ACE treatments may use what is inside this kit: the mission has not switched it off for
 * this type of kit - an MFAK that has to be opened first, say, while IFAKs work straight away.
 *
 * Arguments:
 * 0: Kit class, prototype or instance <STRING>
 *
 * Return Value:
 * Treatments may use it <BOOL>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_medical_fnc_canUseKit;
 *
 * Public: Yes
 */

params ["_class"];

private _kit = [_class] call EFUNC(core,getKitData);

if (_kit isEqualTo []) exitWith {false};

missionNamespace getVariable [format [QGVAR(kit_%1_useFrom), _kit select KIT_ID], _kit param [KIT_TREATMENTS, true]]
