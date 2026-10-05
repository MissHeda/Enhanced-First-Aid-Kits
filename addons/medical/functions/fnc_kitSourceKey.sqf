#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The line of the medical menu's item counts a kit belongs to: its type, and whether it lies on
 * the ground (kitCounts, countTreatmentItems and the dry run of useItem all use it).
 *
 * Arguments:
 * 0: Unit the kit was found for <OBJECT>
 * 1: Kit instance class <STRING>
 *
 * Return Value:
 * "<kit id>" for a carried kit, "<kit id>@ground" for one lying nearby <STRING>
 *
 * Example:
 * [player, "efak_MFAK_7"] call efak_medical_fnc_kitSourceKey;
 *
 * Public: No
 */

params ["_unit", "_kitClass"];

private _id = ([_kitClass] call EFUNC(core,getKitData)) param [KIT_ID, ""];
private _key = toLowerANSI _kitClass;
private _carried = ((items _unit) findIf {(toLowerANSI _x) isEqualTo _key}) > -1;

[_id + "@ground", _id] select _carried
