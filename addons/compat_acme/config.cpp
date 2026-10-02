#include "script_component.hpp"

// Loads only when ACM Extended is there: an addon whose required addons are missing is skipped,
// quietly. ACM Extended brings ACM with it, so the ACM compat is loaded as well - and this one after
// it, so its kit contents are the ones that count.
//
// ACM Extended (1.2.4 and later) reads and takes supplies through ACME_fnc_itemCount, itemTake and
// itemList, which ask EFAK's public API itself - nothing to do here but the kit contents.

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "efak_compat_acm",
            "efak_medical",
            "ACM_core",
            "ACM_Extended"
        };
        skipWhenMissingDependencies = 1;
        author = "Miss Heda";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEFAKKits.hpp"

// Until ACM Extended ships hesherson/ACM-Extended#32: its non-rebreather looks for an oxygen tank on
// the worn containers only and refuses one packed in a kit. ACME registers its functions through
// CfgFunctions itself, where the first definition of a name wins - so this does not add a second one but
// points ACME's own entry at the stand-in (same class path, merged into ACME's config). The stand-in
// hands back to ACME's own file as soon as that one asks for kits itself (see the file).
class CfgFunctions {
    class ACME {
        class infusion {
            class nrbOxygenSource {file = QPATHTOF(overrides\fn_nrbOxygenSource.sqf);};
        };
    };
};
