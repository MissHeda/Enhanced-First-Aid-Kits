#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {"efak_IFAK", "efak_AFAK", "efak_MFAK", "efak_MFAKPlus"};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_main"
        };
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgEFAKKits.hpp"
#include "CfgWeapons.hpp"
#include "Cfg3DEN.hpp"
