// What the kits in a crate or vehicle hold, one field per kit type in EFAK's Eden category (see
// addons/core/Cfg3DEN.hpp). The property name tells efak_core_fnc_fillCrateKits the kit type - the
// editor puts it in for %s. It keeps core's prefix, so missions saved before the kits had an addon
// of their own keep what they set.
#define CRATE_KIT_ATTRIBUTE(kit,name) \
    class EGVAR(core,crate_##kit) { \
        displayName = CSTRING(3DEN_CrateContents_##name); \
        tooltip = ECSTRING(core,3DEN_CrateContents_Tooltip); \
        property = QEGVAR(core,crate_##kit); \
        control = "EditMulti3"; \
        expression = QUOTE(if (!is3DEN && {isServer} && {_value isNotEqualTo ''}) then {[ARR_3(_this,'%s',_value)] call EFUNC(core,fillCrateKits)}); \
        defaultValue = "''"; \
        typeName = "STRING"; \
        validate = "none"; \
        condition = "objectHasInventoryCargo"; \
    }

// And a name every kit of that type in it gets (efak_core_fnc_nameCrateKits).
#define CRATE_KIT_NAME_ATTRIBUTE(kit,name) \
    class EGVAR(core,crateName_##kit) { \
        displayName = CSTRING(3DEN_CrateName_##name); \
        tooltip = ECSTRING(core,3DEN_CrateName_Tooltip); \
        property = QEGVAR(core,crateName_##kit); \
        control = "Edit"; \
        expression = QUOTE(if (!is3DEN && {isServer} && {_value isNotEqualTo ''}) then {[ARR_3(_this,'%s',_value)] call EFUNC(core,nameCrateKits)}); \
        defaultValue = "''"; \
        typeName = "STRING"; \
        validate = "none"; \
        condition = "objectHasInventoryCargo"; \
    }

class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class EGVAR(core,attributes) {
                class Attributes {
                    CRATE_KIT_ATTRIBUTE(efak_IFAK,IFAK);
                    CRATE_KIT_NAME_ATTRIBUTE(efak_IFAK,IFAK);
                    CRATE_KIT_ATTRIBUTE(efak_AFAK,AFAK);
                    CRATE_KIT_NAME_ATTRIBUTE(efak_AFAK,AFAK);
                    CRATE_KIT_ATTRIBUTE(efak_MFAK,MFAK);
                    CRATE_KIT_NAME_ATTRIBUTE(efak_MFAK,MFAK);
                    CRATE_KIT_ATTRIBUTE(efak_MFAKPlus,MFAKPlus);
                    CRATE_KIT_NAME_ATTRIBUTE(efak_MFAKPlus,MFAKPlus);
                };
            };
        };
    };
};
