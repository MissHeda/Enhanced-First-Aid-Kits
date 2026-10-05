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

// EFAK: the line the treatment would take it from is marked (countTreatmentItems works it out). The
// tooltip is plain text - nothing bold in it - so it is framed, » like this «, each player's choice.
private _next = ["", missionNamespace getVariable [QGVAR(nextSource), ""]] select (missionNamespace getVariable [QGVAR(markNextSource), true]);
private _fnc_line = {
    params ["_text", "_source"];
    [_text, format ["» %1 «", _text]] select (_source isEqualTo _next)
};

private _countStrings = [[format ["%1 %2", _medicCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Medic"], "medic"] call _fnc_line];

if ((ACEGVAR(medical_treatment,allowSharedEquipment) != 2) && {!isNil "_patientCount"}) then {
    _countStrings pushBack ([format ["%1 %2", _patientCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Patient"], "patient"] call _fnc_line);
};

if (!isNil "_vehicleCount") then {
    _countStrings pushBack ([format ["%1 %2", _vehicleCount, localize "STR_ACE_Medical_GUI_TreatmentItemCount_Vehicle"], "vehicle"] call _fnc_line);
};

// ----- EFAK -----
{
    _x params ["_label", "_count", "_line"];
    _countStrings pushBack ([format ["%1 %2", _count, _label], _line] call _fnc_line);
} forEach (missionNamespace getVariable [QGVAR(lastKitCounts), []]);

_countStrings joinString "\n"
