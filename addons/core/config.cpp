#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
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

// What the framework is called in the CBA settings and keybinds: the category of the general
// settings and of every kit without one of its own. A mod that brings core, gui and arsenal along
// without EFAK sets its own name here.
class EFAK_Framework {
    settingsCategory = CBA_SETTINGS_EFAK;
};
#include "CfgEFAKKits.hpp"
#include "CfgWeapons.hpp"
#include "Cfg3DEN.hpp"
