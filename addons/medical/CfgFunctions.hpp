// ACE compiles its functions final, so a runtime reassignment is refused with
// "Attempt to override final function". Redefining them here, under ACE's own tag, is the way
// in: the function library takes the last definition it sees and this addon loads after ACE.
//
// Only functions ACM does not already override are touched - it owns
// ace_medical_treatment_fnc_treatment, and two mods cannot have the same one.
class CfgFunctions {
    class EFAK_overwrite_medical_treatment {
        tag = "ace_medical_treatment";

        class ace_medical_treatment {
            class hasItem {
                file = QPATHTOF(overrides\fnc_hasItem.sqf);
            };
            class useItem {
                file = QPATHTOF(overrides\fnc_useItem.sqf);
            };
        };
    };

    class EFAK_overwrite_medical_gui {
        tag = "ace_medical_gui";

        class ace_medical_gui {
            class countTreatmentItems {
                file = QPATHTOF(overrides\fnc_countTreatmentItems.sqf);
            };
            class formatItemCounts {
                file = QPATHTOF(overrides\fnc_formatItemCounts.sqf);
            };
        };
    };
};
