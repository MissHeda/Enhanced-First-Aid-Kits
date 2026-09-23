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
            "kat_main"
        };
        skipWhenMissingDependencies = 1;
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEFAKKits.hpp"
