#include "script_component.hpp"

// Loads only when KAT - Advanced Medical is there: an addon whose required addons are missing is skipped, quietly.
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_core",
            "efak_kits",
            "efak_medical",
            "kat_main",
            "kat_misc",
            "kat_breathing",
            "kat_chemical",
            "kat_circulation"
        };
        skipWhenMissingDependencies = 1;
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEFAKKits.hpp"

// KAT and EFAK both replace ace_medical_treatment_fnc_useItem. This compat loads after both and
// carries one that does both jobs (overrides\fnc_useItem.sqf), so neither loses out to load order.
class CfgFunctions {
    class EFAK_overwrite_kat_medical_treatment {
        tag = "ace_medical_treatment";

        class ace_medical_treatment {
            class useItem {file = QPATHTOF(overrides\fnc_useItem.sqf);};
        };
    };

    // KAT draws every breath of a BVM on a carried oxygen tank from the medic's own magazines; this
    // copy draws from a tank in a kit when there is none of those, and the tank stays in the kit.
    class EFAK_overwrite_kat_breathing {
        tag = "kat_breathing";

        class kat_breathing {
            class UseBVM {file = QPATHTOF(overrides\fnc_useBVM.sqf);};
        };
    };
};

// Interactions whose test looks at the unit's own inventory only ("items _player", hasMagazine).
// The tests below ask EFAK as well; where KAT then uses the item up or sets it down itself
// (removeItem), one is unpacked from a kit first (efak_medical_fnc_unpackForUse) and KAT's own
// function does the rest. Oxygen tanks are never unpacked: they are drawn from and refilled inside
// the kit. Same in KAT 3.2.0 and 3.2.1.
class ACE_Medical_Treatment_Actions {
    // BVM with a carried oxygen tank: KAT looks for the tank among the medic's magazines.
    class UseBVM;
    class UseBVMPortableOxygen: UseBVM {
        condition = "(_patient call kat_breathing_fnc_canUseBVM && (_medic call kat_breathing_fnc_hasOxygenTank || {(([_medic, 'kat_oxygenTank_150'] call efak_medical_fnc_countInKits) + ([_medic, 'kat_oxygenTank_300'] call efak_medical_fnc_countInKits)) > 0}) && (kat_breathing_locationProvideOxygen isEqualTo 0 || !((kat_breathing_locationProvideOxygen in [2, 3] && _patient call ace_medical_treatment_fnc_isInMedicalFacility) || ((kat_breathing_locationProvideOxygen in [1, 3] && _patient call ace_medical_treatment_fnc_isInMedicalVehicle)))))";
    };
};

class CfgVehicles {
    class LandVehicle;
    class Car: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                class RefillActionsVehicle {
                    // Refilling an empty oxygen tank at a medical vehicle; one in a kit stays in the kit.
                    class Refill_OxygenTank_150_Vehicle {
                        condition = "(([_player, 'kat_oxygenTank_150_Empty'] call efak_medical_fnc_countItem) > 0 && _target call ace_medical_treatment_fnc_isMedicalVehicle)";
                        statement = "if (([_player, 'kat_oxygenTank_150_Empty'] call efak_medical_fnc_countLoose) > 0) then {[_player, 'kat_oxygenTank_150', kat_breathing_PortableOxygenTank_RefillTime] call kat_breathing_fnc_refillOxygenTank} else {[_player, 'kat_oxygenTank_150_Empty', 'kat_oxygenTank_150', kat_breathing_PortableOxygenTank_RefillTime, ['STR_KAT_Breathing_RefillPortableOxygenTank_Progress', 'STR_KAT_Breathing_RefillPortableOxygenTank_Complete', 'STR_KAT_Breathing_RefillPortableOxygenTank_Cancel']] call efak_medical_fnc_refillInKit}";
                    };
                    class Refill_OxygenTank_300_Vehicle: Refill_OxygenTank_150_Vehicle {
                        condition = "(([_player, 'kat_oxygenTank_300_Empty'] call efak_medical_fnc_countItem) > 0 && _target call ace_medical_treatment_fnc_isMedicalVehicle)";
                        statement = "if (([_player, 'kat_oxygenTank_300_Empty'] call efak_medical_fnc_countLoose) > 0) then {[_player, 'kat_oxygenTank_300', kat_breathing_PortableOxygenTank_RefillTime*2] call kat_breathing_fnc_refillOxygenTank} else {[_player, 'kat_oxygenTank_300_Empty', 'kat_oxygenTank_300', kat_breathing_PortableOxygenTank_RefillTime*2, ['STR_KAT_Breathing_RefillPortableOxygenTank_Progress', 'STR_KAT_Breathing_RefillPortableOxygenTank_Complete', 'STR_KAT_Breathing_RefillPortableOxygenTank_Cancel']] call efak_medical_fnc_refillInKit}";
                    };
                };
            };
        };
    };

    class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
            class KAT_Equipment {
                // The pulse oximeter's sound - only a test, nothing is taken.
                class PulseOximeter_removeSound {
                    condition = "(([_player, 'kat_Pulseoximeter'] call efak_medical_fnc_countItem) > 0 && (_player getVariable ['kat_breathing_PulseOximeter_Volume', false]))";
                };
                class PulseOximeter_addSound: PulseOximeter_removeSound {
                    condition = "(([_player, 'kat_Pulseoximeter'] call efak_medical_fnc_countItem) > 0 && !(_player getVariable ['kat_breathing_PulseOximeter_Volume', false]))";
                };

                // Refilling an empty oxygen tank in a medical facility; one in a kit stays in the kit.
                class Refill_OxygenTank_150_Facility {
                    condition = "((kat_breathing_locationProvideOxygen in [2, 3]) && ([_player, 'kat_oxygenTank_150_Empty'] call efak_medical_fnc_countItem) > 0 && _player call ace_medical_treatment_fnc_isInMedicalFacility)";
                    statement = "if (([_player, 'kat_oxygenTank_150_Empty'] call efak_medical_fnc_countLoose) > 0) then {[_player, 'kat_oxygenTank_150', kat_breathing_PortableOxygenTank_RefillTime] call kat_breathing_fnc_refillOxygenTank} else {[_player, 'kat_oxygenTank_150_Empty', 'kat_oxygenTank_150', kat_breathing_PortableOxygenTank_RefillTime, ['STR_KAT_Breathing_RefillPortableOxygenTank_Progress', 'STR_KAT_Breathing_RefillPortableOxygenTank_Complete', 'STR_KAT_Breathing_RefillPortableOxygenTank_Cancel']] call efak_medical_fnc_refillInKit}";
                };
                class Refill_OxygenTank_300_Facility: Refill_OxygenTank_150_Facility {
                    condition = "((kat_breathing_locationProvideOxygen in [2, 3]) && ([_player, 'kat_oxygenTank_300_Empty'] call efak_medical_fnc_countItem) > 0 && _player call ace_medical_treatment_fnc_isInMedicalFacility)";
                    statement = "if (([_player, 'kat_oxygenTank_300_Empty'] call efak_medical_fnc_countLoose) > 0) then {[_player, 'kat_oxygenTank_300', kat_breathing_PortableOxygenTank_RefillTime*2] call kat_breathing_fnc_refillOxygenTank} else {[_player, 'kat_oxygenTank_300_Empty', 'kat_oxygenTank_300', kat_breathing_PortableOxygenTank_RefillTime*2, ['STR_KAT_Breathing_RefillPortableOxygenTank_Progress', 'STR_KAT_Breathing_RefillPortableOxygenTank_Complete', 'STR_KAT_Breathing_RefillPortableOxygenTank_Cancel']] call efak_medical_fnc_refillInKit}";
                };

                // Gas mask filter: taken with removeItem.
                class KAT_ChangeGasMaskFilter {
                    condition = "(([_player] call kat_chemical_fnc_canReplaceFilter) || {(goggles _player) in (missionNamespace getVariable ['kat_chemical_availGasmaskList', []]) && {([_player, 'kat_gasmaskFilter'] call efak_medical_fnc_countItem) > 0}})";
                    statement = "[_player, 'kat_gasmaskFilter'] call efak_medical_fnc_unpackForUse; _this call kat_chemical_fnc_changeGasMaskFilter";
                };

                // Decon kit and M8 paper are used, not used up - a test is all.
                class KAT_UseDecon {
                    condition = "(([_player, 'kat_decon_kit'] call efak_medical_fnc_countItem) > 0 && {(_player getVariable ['kat_chemical_chemicalContamination', '']) != ''})";
                };
                class KAT_UseM8Paper {
                    condition = "(([_player, 'kat_m8paper'] call efak_medical_fnc_countItem) > 0)";
                };

                // The AED X menu on yourself, and setting an AED down - which takes it with removeItem.
                class KAT_AED_X_Interactions {
                    condition = "(([_player, 'kat_X_AED'] call efak_medical_fnc_countItem) > 0)";
                };
                class KAT_placeAED {
                    condition = "(([_player, 'kat_AED'] call efak_medical_fnc_countItem) > 0 && !((_player getVariable ['kat_circulation_MedicDefibrillator_Patient', objNull]) getVariable ['kat_circulation_DefibrillatorInUse', false]))";
                    statement = "[_player, 'kat_AED'] call efak_medical_fnc_unpackForUse; [_player, 'kat_AED'] call kat_circulation_fnc_placeAED";
                };
                class KAT_placeAEDX: KAT_placeAED {
                    condition = "(([_player, 'kat_X_AED'] call efak_medical_fnc_countItem) > 0 && !((_player getVariable ['kat_circulation_MedicDefibrillator_Patient', objNull]) getVariable ['kat_circulation_DefibrillatorInUse', false]))";
                    statement = "[_player, 'kat_X_AED'] call efak_medical_fnc_unpackForUse; [_player, 'kat_X_AED'] call kat_circulation_fnc_placeAED";
                };
            };
        };
    };
};
