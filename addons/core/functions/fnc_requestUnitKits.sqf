#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Asks the machine that owns an AI unit to turn the kit prototypes it carries into real kits.
 *
 * Players convert their own kits the moment they carry them. AI only does when a loadout is set on
 * it (fnc_applyLoadoutRestore) - every AI of a mission holding a kit id from the start would empty
 * the pool for nothing. So the rest wait until somebody actually reaches for them: opens the AI's
 * kits, or treats it out of them. Asked at most every few seconds per unit, however often the
 * interaction menu checks.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorObject] call efak_core_fnc_requestUnitKits;
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};
if (CBA_missionTime < (_unit getVariable [QGVAR(conversionAsked), -60]) + 5) exitWith {};

_unit setVariable [QGVAR(conversionAsked), CBA_missionTime];

if ([_unit] call ACEFUNC(common,isPlayer)) exitWith {};
if ((items _unit) findIf {(toLowerANSI _x) in GVAR(needsConversion)} == -1) exitWith {};

[QGVAR(convertUnitKits), [_unit], _unit] call CBA_fnc_targetEvent;
