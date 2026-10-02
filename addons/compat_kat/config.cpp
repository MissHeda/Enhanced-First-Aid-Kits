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
            "efak_medical",
            "kat_main",
            "kat_misc"
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
};
