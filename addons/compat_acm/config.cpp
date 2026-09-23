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
            "ACM_main"
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
