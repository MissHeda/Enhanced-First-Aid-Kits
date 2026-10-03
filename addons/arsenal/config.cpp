#include "script_component.hpp"
#include "defines.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_core",
            "ace_arsenal"
        };
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "RscArsenal.hpp"

// The kits' button and tab in ACE Arsenal. A mod that adds containers of its own (pouches, bags) to
// EFAK may set its own here; they share the one button with the first aid kits.
class EFAK_Arsenal {
    icon = QPATHTOF(ui\efak_logo.paa);
    buttonName = CSTRING(Button_Kits);
    tabTooltip = CSTRING(Tab_Tooltip);
    // Texts that name the kits, see fnc_getText.
    header = CSTRING(Header_Kits);
    buttonContents = CSTRING(Button_Contents);
    hintNoKits = CSTRING(Hint_NoKits);
    rowNoKits = CSTRING(Row_NoKits);
    tabDisabledUnit = CSTRING(Tab_Disabled_Unit);
};
