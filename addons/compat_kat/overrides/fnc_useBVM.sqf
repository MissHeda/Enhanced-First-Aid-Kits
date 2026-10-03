// KAT kat_breathing_fnc_useBVM, kit-aware for EFAK. Copied from KAT 3.2.0 (the same in 3.2.1) with its macros
// written out; KAT draws every breath of a carried oxygen tank from the medic's own magazines, so a tank
// packed in a kit was never used. Without a loose tank, the breath now comes out of a tank in a kit, which
// stays in the kit (efak_medical_fnc_drawCharge) - the lines marked EFAK, everything else is KAT's.
// Used with every KAT version; bring it up to date when KAT changes this function.

/*
 * Author: Blue
 * Handles BVM usage.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Is pocket BVM <BOOL>
 * 3: Use oxygen <BOOL>
 * 4: Oxygen origin <INT>
 *   0: Medical vehicle/facility
 *   1: Medic carried
 *   2: Vehicle stored
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget, true, false, false] call kat_breathing_fnc_useBVM;
 *
 * Public: No
 */

params ["_medic", "_patient", ["_pocket", false], ["_useOxygen", false], ["_oxygenOrigin", 0]];

_patient setVariable ["kat_breathing_BVMInUse", true, true];

kat_breathing_BVMTarget = _patient;

kat_breathing_CPRCancel_EscapeID = [0x01, [false, false, false], {
    kat_breathing_BVMTarget setVariable ["kat_breathing_BVMInUse", false, true];
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

kat_breathing_CPRCancel_MouseID = [0xF0, [false, false, false], {
    kat_breathing_BVMTarget setVariable ["kat_breathing_BVMInUse", false, true];
}, "keydown", "", false, 0] call CBA_fnc_addKeyHandler;

ace_medical_gui_pendingReopen = false; // Prevent medical menu from reopening

if (dialog) then { // If another dialog is open (medical menu) close it
    closeDialog 0;
};

private _notInVehicle = isNull objectParent _medic;
totalProvided = 1;
kat_breathing_BVM_loop = false;

if (_notInVehicle) then {
    [_medic, "AinvPknlMstpSnonWnonDnon_AinvPknlMstpSnonWnonDnon_medic", 1] call ace_common_fnc_doAnimation;
    kat_breathing_BVM_loop = true;
};

kat_breathing_BVM_timeOut = true;

[{
    params ["_medic", "_patient", "_pocket", "_useOxygen", "_oxygenOrigin", "_notInVehicle"];

    [(localize "STR_kat_breathing_UseBVM_PutAway"), "", ""] call ace_interaction_fnc_showMouseHint;
    [(localize "STR_kat_breathing_UseBVM_Start"), 1.5, _medic] call ace_common_fnc_displayTextStructured;

    [{
        params ["_args", "_idPFH"];
        _args params ["_medic", "_patient", "_pocket", "_useOxygen", "_oxygenOrigin", "_notInVehicle"];

        private _patientCondition = (!((_patient getVariable ["ACE_isUnconscious", false])) && alive _patient || _patient isEqualTo objNull);
        private _medicCondition = (!(alive _medic) || (_medic getVariable ["ACE_isUnconscious", false]) || _medic isEqualTo objNull);
        private _vehicleCondition = (objectParent _medic isNotEqualTo objectParent _patient);
        private _distanceCondition = (_patient distance2D _medic > ace_medical_gui_maxDistance);

        if (_patientCondition || _medicCondition || !(_patient getVariable ["kat_breathing_BVMInUse", false]) || dialog || {(!_notInVehicle && _vehicleCondition) || {(_notInVehicle && _distanceCondition)}}) exitWith {
            [_idPFH] call CBA_fnc_removePerFrameHandler;

            _patient setVariable ["kat_breathing_BVMInUse", false, true];
            _patient setVariable ["kat_breathing_oxygenTankConnected", false, true];

            [] call ace_interaction_fnc_hideMouseHint;

            [kat_breathing_CPRCancel_EscapeID, "keydown"] call CBA_fnc_removeKeyHandler;
            [kat_breathing_CPRCancel_MouseID, "keydown"] call CBA_fnc_removeKeyHandler;

            if (_notInVehicle) then {
                [_medic, "AinvPknlMstpSnonWnonDnon_medicEnd", 2] call ace_common_fnc_doAnimation;
            };

            closeDialog 0;

            private _bvmType = "";

            if (_pocket) then {
                _bvmType = (localize "STR_kat_breathing_PocketBVM_Display");
            } else {
                _bvmType = (localize "STR_kat_breathing_BVM_Display");
            };

            if (_useOxygen) then {
                _bvmType = format [(localize "STR_kat_breathing_Activity_BVM_Oxygenated"), _bvmType];
            };

            [_patient, "activity", "STR_kat_breathing_Activity_BVM", [[_medic, false, true] call ace_common_fnc_getName, _bvmType, totalProvided]] call ace_medical_treatment_fnc_addToLog;
            [(localize "STR_kat_breathing_UseBVM_Cancelled"), 1.5, _medic] call ace_common_fnc_displayTextStructured;
        };

        if !(kat_breathing_BVM_timeOut) then {
            kat_breathing_BVM_timeOut = true;

            if (_useOxygen && !_pocket) then {
                switch (_oxygenOrigin) do {
                    case 1: { // Medic provided oxygen with carried oxygen tank
                        private _carriedTanks = [];
                        private _heldPreferredTanks = [];
                        private _medicPreferredTank = _medic getVariable ["kat_breathing_oxygenTankPreferred", ""];

                        if(_medicPreferredTank != "") then { // Handle preferred medic oxygen tank
                            {
                                if(_x select 0 == _medicPreferredTank) then {
                                    _heldPreferredTanks pushBack _x;
                                };
                            } forEach magazinesAmmo _medic;

                            if (_heldPreferredTanks isNotEqualTo []) then {
                                _carriedTanks = _heldPreferredTanks;
                            };
                        } else {
                            {
                                if(_x select 0 in ["kat_oxygenTank_150","kat_oxygenTank_300"]) then {
                                    _carriedTanks pushBack _x;
                                };
                            } forEach magazinesAmmo _medic;
                        };

                        if (_carriedTanks isNotEqualTo []) then {
                            _patient setVariable ["kat_breathing_oxygenTankConnected", true, true];

                            private _tank = _carriedTanks select - 1;
                            _tank params ["_tankClassName", "_oxygenLeft"];

                            if(_oxygenLeft > 1) then {
                                _medic removeMagazine _tankClassName;
                                _medic addMagazine [_tankClassName, _oxygenLeft - 1];
                            } else {
                                _medic removeMagazine _tankClassName;
                                _medic addItem ([_tankClassName,"Empty"] joinString "_");
                                [(localize "STR_kat_breathing_PortableOxygenTankDisconnected_Empty"), 1.5, _medic] call ace_common_fnc_displayTextStructured;
                            };
                        } else {
                            // EFAK: no tank loose - breathe from one packed in a kit, which stays there.
                            private _tankClasses = ["kat_oxygenTank_150", "kat_oxygenTank_300"];
                            if (_medicPreferredTank != "") then {_tankClasses = [_medicPreferredTank]};

                            private _oxygenLeft = -1;
                            {
                                _oxygenLeft = [_medic, _x, _x + "_Empty"] call efak_medical_fnc_drawCharge;
                                if (_oxygenLeft >= 0) exitWith {};
                            } forEach _tankClasses;

                            _patient setVariable ["kat_breathing_oxygenTankConnected", _oxygenLeft >= 0, true];

                            if (_oxygenLeft == 0) then {
                                [(localize "STR_kat_breathing_PortableOxygenTankDisconnected_Empty"), 1.5, _medic] call ace_common_fnc_displayTextStructured;
                            };
                        };
                    };
                    case 2: { // Vehicle provided with stored oxygen tank
                        private _vehicle = objectParent _patient;

                        private _oxygenTanks = [];

                        {
                            if((_x select 0) in ["kat_oxygenTank_150","kat_oxygenTank_300"]) then {
                                _oxygenTanks append [_x];
                            };
                        } forEach (magazinesAmmoCargo _vehicle);

                        if (_oxygenTanks isNotEqualTo []) then {
                            _patient setVariable ["kat_breathing_oxygenTankConnected", true, true];

                            private _tank = _oxygenTanks select - 1;
                            _tank params ["_tankClassName", "_oxygenLeft"];

                            if (_oxygenLeft > 1) then {
                                [_vehicle, _tankClassName] call ace_common_fnc_adjustMagazineAmmo;
                            } else {
                                _vehicle addItemCargoGlobal [[_tankClassName,"Empty"] joinString "_", 1];
                                [(localize "STR_kat_breathing_PortableOxygenTankDisconnected_Empty"), 1.5, _medic] call ace_common_fnc_displayTextStructured;
                            };
                        } else {
                            _patient setVariable ["kat_breathing_oxygenTankConnected", false, true];
                        };
                    };
                    default { // Medical vehicle/facility provided
                        _patient setVariable ["kat_breathing_oxygenTankConnected", true, true];
                    };
                };
            } else {
                _patient setVariable ["kat_breathing_oxygenTankConnected", false, true];
            };

            playSound3D ["x\kat\addons\breathing\audio\squeeze_BVM.ogg", _patient, false, getPosASL _patient, 8, 1, 15];

            [{ // Squeeze BVM every 5 seconds
                params ["_patient"];

                !(_patient getVariable ["kat_breathing_BVMInUse", false]);
            }, {}, [_patient], 5,
            {
                kat_breathing_BVM_timeOut = false;
                totalProvided = totalProvided + 1;
            }] call CBA_fnc_waitUntilAndExecute;
        };

        if (kat_breathing_BVM_loop) then {
            ["ace_common_switchMove", [_medic, "kat_BVM"]] call CBA_fnc_globalEvent;
            kat_breathing_BVM_loop = false;

            [{
                params ["_patient"];
                !(_patient getVariable ["kat_breathing_BVMInUse", false]);
            }, {}, [_patient], 9, {
                kat_breathing_BVM_loop = true;
            }] call CBA_fnc_waitUntilAndExecute;
        };
    }, 0, [_medic, _patient, _pocket, _useOxygen, _oxygenOrigin, _notInVehicle]] call CBA_fnc_addPerFrameHandler;

    [{kat_breathing_BVM_timeOut = false;}, [], 1] call CBA_fnc_waitAndExecute;
}, [_medic, _patient, _pocket, _useOxygen, _oxygenOrigin, _notInVehicle], 2] call CBA_fnc_waitAndExecute;
