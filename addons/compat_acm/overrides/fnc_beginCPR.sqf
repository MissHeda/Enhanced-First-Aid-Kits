// ACM ACM_circulation_fnc_beginCPR, kit-aware for EFAK. Copied from ACM 1.5.0.4 with its macros written out;
// ACM looks at the unit's own inventory only, so a BVM packed in a kit could start ventilation but CPR could never swap back to it.
/*
 * Author: Blue
 * Begin CPR
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget] call ACM_circulation_fnc_beginCPR;
 *
 * Public: No
 */

params ["_medic", "_patient"];

if !(isNull (_patient getVariable ["ACM_circulation_CPR_Medic", objNull])) exitWith {
    [localize "STR_ACM_circulation_CPR_Already", 2, _medic] call ace_common_fnc_displayTextStructured;
};

private _fnc_doCPRAnimation = {
    params ["_medic"];

    if (ACM_circulation_loopCPR) then {
        ["ace_common_switchMove", [_medic, "ACM_CPR"]] call CBA_fnc_globalEvent;
        _medic addEventHandler ["AnimDone", {
	        params ["_medic", "_anim"];

            if !(ACM_circulation_loopCPR) exitWith {
                _medic removeEventHandler [_thisEvent, _thisEventHandler];
            };

            ["ace_common_switchMove", [_medic, "ACM_CPR"]] call CBA_fnc_globalEvent;
        }];
    };
};
_patient setVariable ["ace_medical_CPR_provider", _medic, true];
_patient setVariable ["ACM_circulation_CPR_Medic", _medic, true];

_medic setVariable ["ACM_circulation_isPerformingCPR", true, true];

ACM_circulation_CPRTarget = _patient;
ACM_circulation_CPRActive = true;
ACM_circulation_BVMActive = false;

ACM_circulation_MedicHasBVM = false;
ACM_circulation_MedicHasBVMType = "";

ACM_circulation_SwapToBVM = false;

private _uniqueItems = [_medic, 0] call efak_medical_fnc_listItems;
private _itemIndex = _uniqueItems findIf {_x == "ACM_BVM"};

if (_itemIndex < 0) then {
    _itemIndex = _uniqueItems findIf {_x == "ACM_PocketBVM"};
    ACM_circulation_MedicHasBVMType = "ACM_PocketBVM";
} else {
    ACM_circulation_MedicHasBVMType = "ACM_BVM";
};

ACM_circulation_MedicHasBVM = _itemIndex >= 0;

if !(ACM_circulation_MedicHasBVM) then {
    ACM_circulation_MedicHasBVMType = "";
};

ACM_circulation_CPRCancel_EscapeID = [0x01, [false, false, false], {
    ACM_circulation_CPRTarget setVariable ["ace_medical_CPR_provider", objNull, true];
    ACM_circulation_CPRTarget setVariable ["ACM_circulation_CPR_Medic", objNull, true];
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

ACM_circulation_CPRCancel_MouseID = [0xF0, [false, false, false], {
    ACM_circulation_CPRTarget setVariable ["ace_medical_CPR_provider", objNull, true];
    ACM_circulation_CPRTarget setVariable ["ACM_circulation_CPR_Medic", objNull, true];
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

ACM_circulation_CPRToggle_MouseID = [0xF1, [false, false, false], {
    if (ACM_circulation_CPRTarget getVariable ["ace_medical_CPR_provider", objNull] isEqualTo objNull) then {
        if ((ACM_circulation_CPRTarget getVariable ["ACM_airway_AirwayItem_Oral", ""]) == "SGA") then {
            ACM_circulation_CPRTarget setVariable ["ace_medical_CPR_provider", ACE_player, true];
        } else {
            if !([ACM_circulation_CPRTarget] call ACM_core_fnc_bvmActive) then {
                ACM_circulation_CPRTarget setVariable ["ace_medical_CPR_provider", ACE_player, true];
            };
        };
    } else {
        ACM_circulation_CPRTarget setVariable ["ace_medical_CPR_provider", objNull, true];
    };
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

ACM_circulation_CPRSwap_MouseID = [0xF2, [false, false, false], {
    if (isNull (ACM_circulation_CPRTarget getVariable ["ace_medical_CPR_provider", objNull]) && isNull (ACM_circulation_CPRTarget getVariable ["ACM_breathing_BVM_Medic", objNull]) && ACM_circulation_MedicHasBVM) then {
        ACM_circulation_SwapToBVM = true;
    };
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

ace_medical_gui_pendingReopen = false; // Prevent medical menu from reopening

if (dialog) then { // If another dialog is open (medical menu) close it
    closeDialog 0;
};

private _notInVehicle = isNull objectParent _medic;
private _initialAnimation = animationState _medic;
private _startDelay = 2;
ACM_circulation_loopCPR = false;

if (_notInVehicle) then {
    [_medic, "AinvPknlMstpSnonWnonDnon_AinvPknlMstpSnonWnonDnon_medic", 1] call ace_common_fnc_doAnimation;
    ACM_circulation_loopCPR = true;
} else {
    if (currentWeapon _medic != "") then {
        [_medic] call ace_weaponselect_fnc_putWeaponAway;
    };
};

if (_initialAnimation in ["amovpercmstpsnonwnondnon", "amovpknlmstpsnonwnondnon_gear", "amovpknlmstpsnonwnondnon"]) then { // Wack
    _startDelay = 1.8;
};

private _CPRStartTime = CBA_missionTime + _startDelay + 0.2;

[{
    params ["_medic", "_patient", "_notInVehicle", "_CPRStartTime", "_fnc_doCPRAnimation"];

    if (currentWeapon _medic != "") then {
        [_medic] call ace_weaponselect_fnc_putWeaponAway;
    };
    
    [localize "STR_ACM_circulation_CPR_Stop", localize "STR_ACM_circulation_CPR_Pause", ""] call ace_interaction_fnc_showMouseHint;
    [_patient, "activity", localize "STR_ACM_circulation_CPR_ActionLog_Started", [[_medic, false, true] call ace_common_fnc_getName]] call ace_medical_treatment_fnc_addToLog;

    if (ACM_breathing_SwapToCPR) then {
        ACM_breathing_SwapToCPR = false;
    } else {
        [localize "STR_ACM_circulation_CPR_Started", 1.5, _medic] call ace_common_fnc_displayTextStructured;
    };

    [{
        params ["_args", "_idPFH"];
        _args params ["_medic", "_patient", "_notInVehicle", "_CPRStartTime", "_fnc_doCPRAnimation"];

        private _patientCondition = (!((_patient getVariable ["ACE_isUnconscious", false])) && alive _patient || _patient isEqualTo objNull);
        private _medicCondition = (!(alive _medic) || (_medic getVariable ["ACE_isUnconscious", false]) || _medic isEqualTo objNull);
        private _vehicleCondition = (objectParent _medic isNotEqualTo objectParent _patient);
        private _distanceCondition = (_patient distance2D _medic > ace_medical_gui_maxDistance);

        if (_patientCondition || _medicCondition || !(alive (_patient getVariable ["ACM_circulation_CPR_Medic", objNull])) || ACM_circulation_SwapToBVM || dialog || {(!_notInVehicle && _vehicleCondition) || {(_notInVehicle && _distanceCondition)}}) exitWith { // Stop CPR
            [_idPFH] call CBA_fnc_removePerFrameHandler;
            [] call ace_interaction_fnc_hideMouseHint;
            [ACM_circulation_CPRCancel_EscapeID, "keydown"] call CBA_fnc_removeKeyHandler;
            [ACM_circulation_CPRCancel_MouseID, "keydown"] call CBA_fnc_removeKeyHandler;
            [ACM_circulation_CPRToggle_MouseID, "keydown"] call CBA_fnc_removeKeyHandler;
            [ACM_circulation_CPRSwap_MouseID, "keydown"] call CBA_fnc_removeKeyHandler;

            if (_notInVehicle) then {
                [_medic, "AinvPknlMstpSnonWnonDnon_medicEnd", 2] call ace_common_fnc_doAnimation;
            };

            private _CPRTime = CBA_missionTime - _CPRStartTime; 
            private _time = [_CPRTime, "MM:SS"] call BIS_fnc_secondsToString;

            [_patient, "activity", localize "STR_ACM_circulation_CPR_ActionLog_Stopped", [[_medic, false, true] call ace_common_fnc_getName, _time]] call ace_medical_treatment_fnc_addToLog;

            _patient setVariable ["ACM_circulation_CPR_StoppedTotal", _CPRTime, true];
            _patient setVariable ["ACM_circulation_CPR_StoppedTime", CBA_missionTime, true];

            if (_patient getVariable ["ace_medical_CPR_provider", objNull] isNotEqualTo objNull) then {
                _patient setVariable ["ace_medical_CPR_provider", objNull, true];
            };

            _patient setVariable ["ACM_circulation_CPR_Medic", objNull, true];
            _medic setVariable ["ACM_circulation_isPerformingCPR", false, true];

            closeDialog 0;
            
            if (ACM_circulation_SwapToBVM) then {
                [localize "STR_ACM_circulation_CPR_SwappedToBVM", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                [_medic, _patient, false] call ACM_breathing_fnc_useBVM;
            } else {
                [localize "STR_ACM_circulation_CPR_Stopped", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                ["ACM_core_openMedicalMenu", ACM_circulation_CPRTarget] call CBA_fnc_localEvent;
            };

            ACM_circulation_CPRActive = false;
            ACM_circulation_CPRTarget = objNull;
            ACM_circulation_loopCPR = false;
        };

        private _updateMouseHint = false;

        if ([_patient] call ACM_core_fnc_cprActive != ACM_circulation_CPRActive || [_patient] call ACM_core_fnc_bvmActive != ACM_circulation_BVMActive) then {
            _updateMouseHint = true;
        };

        if (_updateMouseHint) then {
            private _uniqueItems = [_medic, 0] call efak_medical_fnc_listItems;
            private _itemIndex = _uniqueItems findIf {_x == "ACM_BVM"};

            if (_itemIndex < 0) then {
                _itemIndex = _uniqueItems findIf {_x == "ACM_PocketBVM"};
                ACM_circulation_MedicHasBVMType = "ACM_PocketBVM";
            } else {
                ACM_circulation_MedicHasBVMType = "ACM_BVM";
            };

            ACM_circulation_MedicHasBVM = _itemIndex >= 0;

            if !(ACM_circulation_MedicHasBVM) then {
                ACM_circulation_MedicHasBVMType = "";
            };

            if ((_patient getVariable ["ACM_airway_AirwayItem_Oral", ""]) == "SGA") then { // Intubated
                ACM_circulation_BVMActive = [_patient] call ACM_core_fnc_bvmActive;
                if ([_patient] call ACM_core_fnc_cprActive) then {
                    [localize "STR_ACM_circulation_CPR_Continued", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                    [localize "STR_ACM_circulation_CPR_Stop", localize "STR_ACM_circulation_CPR_Pause", ""] call ace_interaction_fnc_showMouseHint;
                    ACM_circulation_CPRActive = true;
                    ACM_circulation_loopCPR = true;
                    if (_notInVehicle) then {
                        [_medic] call _fnc_doCPRAnimation;
                    };
                } else {
                    if (_notInVehicle) then {
                        ["ace_common_switchMove", [_medic, "ACM_CPR_Stop"]] call CBA_fnc_globalEvent;
                    };
                    [localize "STR_ACM_circulation_CPR_Paused", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                    [localize "STR_ACM_circulation_CPR_Stop", localize "STR_ACM_circulation_CPR_Continue", (["", localize "STR_ACM_circulation_CPR_SwapToBVM"] select (ACM_circulation_MedicHasBVM && isNull (_patient getVariable ["ACM_circulation_BVM_Medic", objNull])))] call ace_interaction_fnc_showMouseHint;
                    ACM_circulation_CPRActive = false;
                    ACM_circulation_loopCPR = false;
                };
            } else {
                if ([_patient] call ACM_core_fnc_bvmActive) then {
                    [localize "STR_ACM_circulation_CPR_Stop", "", ""] call ace_interaction_fnc_showMouseHint;
                    ACM_circulation_BVMActive = true;
                    ACM_circulation_CPRActive = [_patient] call ACM_core_fnc_cprActive;
                    ACM_circulation_loopCPR = ACM_circulation_CPRActive;
                } else {
                    ACM_circulation_BVMActive = false;
                    if ([_patient] call ACM_core_fnc_cprActive) then {
                        [localize "STR_ACM_circulation_CPR_Continued", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                        [localize "STR_ACM_circulation_CPR_Stop", localize "STR_ACM_circulation_CPR_Pause", ""] call ace_interaction_fnc_showMouseHint;
                        ACM_circulation_CPRActive = true;
                        ACM_circulation_loopCPR = true;
                        if (_notInVehicle) then {
                            [_medic] call _fnc_doCPRAnimation;
                        };
                    } else {
                        if (_notInVehicle) then {
                            ["ace_common_switchMove", [_medic, "ACM_CPR_Stop"]] call CBA_fnc_globalEvent;
                        };
                        [localize "STR_ACM_circulation_CPR_Paused", 1.5, _medic] call ace_common_fnc_displayTextStructured;
                        [localize "STR_ACM_circulation_CPR_Stop", localize "STR_ACM_circulation_CPR_Continue", (["", localize "STR_ACM_circulation_CPR_SwapToBVM"] select (ACM_circulation_MedicHasBVM && isNull (_patient getVariable ["ACM_circulation_BVM_Medic", objNull])))] call ace_interaction_fnc_showMouseHint;
                        ACM_circulation_CPRActive = false;
                        ACM_circulation_loopCPR = false;
                    };
                };
            };
            _medic setVariable ["ACM_circulation_isPerformingCPR", ACM_circulation_CPRActive, true];
        };
    }, 0, [_medic, _patient, _notInVehicle, _CPRStartTime, _fnc_doCPRAnimation]] call CBA_fnc_addPerFrameHandler;

    ["ACM_circulation_handleCPR", [_patient, _CPRStartTime], _patient] call CBA_fnc_targetEvent;

    if (_notInVehicle) then {
        [_medic] call _fnc_doCPRAnimation;
    };
}, [_medic, _patient, _notInVehicle, _CPRStartTime, _fnc_doCPRAnimation], _startDelay] call CBA_fnc_waitAndExecute;