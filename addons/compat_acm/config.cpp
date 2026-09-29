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
            "ACM_circulation"
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
// and takes them with removeItem - the unit's own inventory only. These are redefined under
// ACM's tag so a kit counts too, the way the medical addon does it for ACE's hasItem/useItem.
class CfgFunctions {
    class EFAK_overwrite_ACM_circulation {
        tag = "ACM_circulation";

        class ACM_circulation {
            class beginCPR {file = QPATHTOF(overrides\fnc_beginCPR.sqf);};
            class Syringe_Find {file = QPATHTOF(overrides\fnc_Syringe_Find.sqf);};
            class Syringe_GetMedicationList {file = QPATHTOF(overrides\fnc_Syringe_GetMedicationList.sqf);};
            class Syringe_PrepareFinish {file = QPATHTOF(overrides\fnc_Syringe_PrepareFinish.sqf);};
            class Syringe_UpdateMedicationList {file = QPATHTOF(overrides\fnc_Syringe_UpdateMedicationList.sqf);};
        };
    };
};

// ACM offers the empty syringes in the medical menu only when "items _medic" holds one; the same
// test through EFAK, so a syringe packed in a kit shows up there too.
class ACE_Medical_Treatment_Actions {
    class OpenTransfusionMenu;
    class UseSyringe_10: OpenTransfusionMenu {
        condition = "'acm_syringe_10' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})";
    };
    class UseSyringe_5: UseSyringe_10 {
        condition = "'acm_syringe_5' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})";
    };
    class UseSyringe_3: UseSyringe_10 {
        condition = "'acm_syringe_3' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})";
    };
    class UseSyringe_1: UseSyringe_10 {
        condition = "'acm_syringe_1' in (([_medic] call efak_medical_fnc_listItems) apply {toLowerANSI _x})";
    };
};
