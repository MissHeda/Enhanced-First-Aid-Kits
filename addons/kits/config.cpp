#include "script_component.hpp"

// EFAK's own kits: the IFAK, AFAK, MFAK, MFAK+ and the narc box. Everything that makes a kit work - the registry,
// the kit window, the arsenal tab - is the framework in core, gui and arsenal, which knows no kit by
// name. Another mod can bring that framework along without EFAK (Enhanced Utility Pouches does);
// these kits only come with EFAK itself.
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {"efak_IFAK", "efak_AFAK", "efak_MFAK", "efak_MFAKPlus", "efak_NarcBox"};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_core"
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
