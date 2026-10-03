#include "script_component.hpp"

// Loads only when Advanced Combat Medicine is there: an addon whose required addons are missing is
// skipped, quietly. Also loaded with ACM Extended, which brings ACM with it; that compat then adds
// its own contents and the inventory bridge on top.
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_core",
            "efak_medical",
            "ACM_main",
            "ACM_core",
            "ACM_circulation",
            "ACM_breathing",
            "ACM_cbrn"
        };
        skipWhenMissingDependencies = 1;
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEFAKKits.hpp"

// Filled syringes keep the drawn dose as their rounds and are meant to be used, not stored: ACM
// looks for them only among the magazines on the unit, so one in a kit could never be given.
class EFAK_Excluded {
    class ACM {
        magazinePrefixes[] = {"ACM_Syringe_"};
    };
};

// ACM finds the BVM (CPR -> BVM swap) and empty syringes and vials with ace_common_fnc_uniqueItems
// (the AED with "items _medic") and takes them with removeItem - the unit's own inventory only.
// These are redefined under ACM's tag so a kit counts too, the way the medical addon does it for
// ACE's hasItem/useItem. The two transfusion menu ones are not copies: they run ACM's own function
// and add the kits around it.
class CfgFunctions {
    class EFAK_overwrite_ACM_circulation {
        tag = "ACM_circulation";

        class ACM_circulation {
            class beginCPR {file = QPATHTOF(overrides\fnc_beginCPR.sqf);};
            class Syringe_Find {file = QPATHTOF(overrides\fnc_Syringe_Find.sqf);};
            class Syringe_GetMedicationList {file = QPATHTOF(overrides\fnc_Syringe_GetMedicationList.sqf);};
            class Syringe_PrepareFinish {file = QPATHTOF(overrides\fnc_Syringe_PrepareFinish.sqf);};
            class Syringe_UpdateMedicationList {file = QPATHTOF(overrides\fnc_Syringe_UpdateMedicationList.sqf);};
            class canConnectAED {file = QPATHTOF(overrides\fnc_canConnectAED.sqf);};
            class TransfusionMenu_SwitchTargetInventory {file = QPATHTOF(overrides\fnc_TransfusionMenu_SwitchTargetInventory.sqf);};
            class TransfusionMenu_AddBag {file = QPATHTOF(overrides\fnc_TransfusionMenu_AddBag.sqf);};
        };
    };

    // Every breath of a BVM on portable oxygen comes out of a tank in the uniform, vest or backpack;
    // this one runs ACM's own function and draws from a tank in a kit when there is none of those.
    class EFAK_overwrite_ACM_breathing {
        tag = "ACM_breathing";

        class ACM_breathing {
            class useOxygenTankReserve {file = QPATHTOF(overrides\fnc_useOxygenTankReserve.sqf);};
        };
    };
};

// Interactions whose test looks at the unit's own inventory only. The tests below ask EFAK as well;
// where ACM then uses the item up itself (removeItem), one is unpacked from a kit first
// (efak_medical_fnc_unpackForUse) and ACM's own function does the rest. Oxygen tanks are never
// unpacked: they are drawn from and refilled inside the kit.
// ACM Extended brings its own versions of some of them, which already ask EFAK (ACME_fnc_itemCount).
class ACE_Medical_Treatment_Actions {
    // ACM offers the empty syringes in the medical menu only when "items _medic" holds one.
    class OpenTransfusionMenu;
    class UseSyringe_10: OpenTransfusionMenu {
        condition = "if (isNil 'ACME_fnc_itemCount') then {'acm_syringe_10' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})} else {([_medic, 'ACM_Syringe_10'] call ACME_fnc_itemCount) > 0}";
    };
    class UseSyringe_5: UseSyringe_10 {
        condition = "if (isNil 'ACME_fnc_itemCount') then {'acm_syringe_5' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})} else {([_medic, 'ACM_Syringe_5'] call ACME_fnc_itemCount) > 0}";
    };
    class UseSyringe_3: UseSyringe_10 {
        condition = "if (isNil 'ACME_fnc_itemCount') then {'acm_syringe_3' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})} else {([_medic, 'ACM_Syringe_3'] call ACME_fnc_itemCount) > 0}";
    };
    class UseSyringe_1: UseSyringe_10 {
        condition = "if (isNil 'ACME_fnc_itemCount') then {'acm_syringe_1' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})} else {([_medic, 'ACM_Syringe_1'] call ACME_fnc_itemCount) > 0}";
    };

    // BVM with a portable oxygen tank: the tank is looked for among the medic's own magazines. The
    // breaths themselves come out of a tank in a kit through useOxygenTankReserve (CfgFunctions above),
    // and the tank stays in the kit.
    class UseBVM_Oxygen;
    class UseBVM_PortableOxygen: UseBVM_Oxygen {
        condition = "[_medic, _patient] call ACM_breathing_fnc_canUseBVM && (if (isNil 'ACME_fnc_itemCount') then {([_medic, 'ACM_OxygenTank_425'] call efak_medical_fnc_countItem) > 0} else {([_medic, 'ACM_OxygenTank_425'] call ACME_fnc_itemCount) > 0})";
    };
};

class CfgVehicles {
    class LandVehicle;
    class Car: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                // Refilling an empty oxygen tank at a medical vehicle. A loose one is ACM's; one in a
                // kit is refilled right there and stays in the kit (efak_medical_fnc_refillInKit).
                class ACM_Action_Refill_PortableOxygenTank_425 {
                    condition = "([_player, _target] call ACM_breathing_fnc_canRefillOxygenTank) || {([_player, 'ACM_OxygenTank_425_Empty'] call efak_medical_fnc_countItem) > 0 && {[_target] call ace_medical_treatment_fnc_isMedicalVehicle}}";
                    statement = "if (([_player, 'ACM_OxygenTank_425_Empty'] call efak_medical_fnc_countLoose) > 0) then {[_player] call ACM_breathing_fnc_refillOxygenTank} else {_player call ace_common_fnc_goKneeling; [_player, 'ACM_OxygenTank_425_Empty', 'ACM_OxygenTank_425', 8, ['STR_ACM_Breathing_RefillOxygenTank_Progress', 'STR_ACM_Breathing_RefillOxygenTank_Complete', 'STR_ACM_Breathing_RefillOxygenTank_Cancelled']] call efak_medical_fnc_refillInKit}";
                };
            };
        };
    };

    class Man;
    class CAManBase: Man {
        class ACE_Actions {
            class ACM_Action_GasMask_Other {
                class ACM_Action_PutOnGasMask_Other;
                class ACM_Action_ReplaceGasMaskFilter_Other: ACM_Action_PutOnGasMask_Other {
                    condition = "[_target] call ACM_cbrn_fnc_isWearingGasMask && {([_target] call ACM_cbrn_fnc_hasFilter || [_player] call ACM_cbrn_fnc_hasFilter || {([_player, 'ACM_GasMaskFilter'] call efak_medical_fnc_countItem) > 0} || {([_target, 'ACM_GasMaskFilter'] call efak_medical_fnc_countItem) > 0})}";
                    statement = "if (([_player, 'ACM_GasMaskFilter'] call efak_medical_fnc_unpackForUse) isEqualTo '') then {[_target, 'ACM_GasMaskFilter'] call efak_medical_fnc_unpackForUse}; [_player] call ACM_cbrn_fnc_replaceFilter";
                };
            };
        };

        class ACE_SelfActions {
            // The AED menu on yourself.
            class ACM_Equipment {
                class ACM_AED_Interactions {
                    condition = "if (isNil 'ACME_fnc_itemCount') then {([_player, 'ACM_AED'] call efak_medical_fnc_countItem) > 0} else {([_player, 'ACM_AED'] call ACME_fnc_itemCount) > 0}";
                };
            };

            class ACE_Equipment {
                class ACM_Action_GasMask {
                    class ACM_Action_PutOnGasMask;
                    class ACM_Action_ReplaceGasMaskFilter: ACM_Action_PutOnGasMask {
                        condition = "([_player] call ACM_cbrn_fnc_canReplaceFilter) || {([_player, 'ACM_GasMaskFilter'] call efak_medical_fnc_countItem) > 0 && {(_player call ACM_cbrn_fnc_isWearingGasMask) || {[_player] call ACM_cbrn_fnc_hasGasMask}}}";
                        statement = "[_player, 'ACM_GasMaskFilter'] call efak_medical_fnc_unpackForUse; [_player] call ACM_cbrn_fnc_replaceFilter";
                    };
                };
            };
        };
    };
};
