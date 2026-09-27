#include "..\script_component.hpp"
/*
 * Author: AmsteadRayle, Miss Heda
 * Format item counts to be shown in the tooltip.
 *
 * OVERRIDE of ace_medical_gui_fnc_formatItemCounts, installed through CfgFunctions - see
 * fnc_hasItem for why. Everything above the EFAK block is ACE's own code; keep it in step when
 * ACE changes.
 *
 * EFAK: one more line per kit type for what is in the kits, counted by the override of countTreatmentItems
 * that runs immediately before this.
 *
 * Arguments:
 * 0: Medic count <NUMBER>
 * 1: Patient count <NUMBER>
 * 2: Vehicle count <NUMBER>
 *
 * Return Value:
 * Item count string <STRING>
 *
 * Example:
 * [medicCount, patientCount, vehicleCount] call ace_medical_gui_fnc_formatItemCounts
 *
 * Public: No
 */

params ["_medicCount", "_patientCount", "_vehicleCount"];

private _countStrings = [format ["%1 %2", _medicCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Medic"]];

if ((ACEGVAR(medical_treatment,allowSharedEquipment) != 2) && {!isNil "_patientCount"}) then {
    _countStrings pushBack format ["%1 %2", _patientCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Patient"];
};

if (!isNil "_vehicleCount") then {
    _countStrings pushBack format ["%1 %2", _vehicleCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Vehicle"];
};

// ----- EFAK -----
{
    _x params ["_type", "_count"];
    _countStrings pushBack format ["%1 %2", _count, format [LLSTRING(ItemCount_InKit), _type]];
} forEach (missionNamespace getVariable [QGVAR(lastKitCounts), []]);

_countStrings joinString "\n"
