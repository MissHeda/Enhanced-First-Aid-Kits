// What the kits of an editor unit hold. ACE Arsenal writes it when it dresses the unit in the
// editor (fnc_applyLoadoutRestore), and the mission hands it to the kits once the unit is played
// (fnc_convertKits). The editor saves only a unit's plain inventory - without this, every kit set
// up there would start the mission with the default contents.
//
// A crate or vehicle can say what its kits hold, one field per kit type in the format of the CBA
// default contents. At mission start the server swaps the kits of that type in its cargo for kits
// filled that way (fnc_fillCrateKits); an empty field leaves them to the defaults. The editor puts
// the property name in for %s, which tells the function the kit type.
#define CRATE_KIT_ATTRIBUTE(kit,name) \
    class GVAR(crate_##kit) { \
        displayName = CSTRING(3DEN_CrateContents_##name); \
        tooltip = CSTRING(3DEN_CrateContents_Tooltip); \
        property = QGVAR(crate_##kit); \
        control = "EditMulti3"; \
        expression = QUOTE(if (!is3DEN && {isServer} && {_value isNotEqualTo ''}) then {[ARR_3(_this,'%s',_value)] call FUNC(fillCrateKits)}); \
        defaultValue = "''"; \
        typeName = "STRING"; \
        validate = "none"; \
        condition = "objectHasInventoryCargo"; \
    }

class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class GVAR(attributes) {
                displayName = CSTRING(3DEN_Category);
                collapsed = 1;

                class Attributes {
                    class GVAR(kitContents) {
                        displayName = CSTRING(3DEN_KitContents);
                        tooltip = CSTRING(3DEN_KitContents_Tooltip);
                        property = QGVAR(kitContents);
                        control = "EditMulti3";
                        expression = QUOTE(if (!is3DEN && {_value isNotEqualTo ''}) then {_this setVariable [ARR_2(QQGVAR(editorKits),_value)]});
                        defaultValue = "''";
                        typeName = "STRING";
                        validate = "none";
                        condition = "objectBrain";
                    };
                    CRATE_KIT_ATTRIBUTE(efak_IFAK,IFAK);
                    CRATE_KIT_ATTRIBUTE(efak_AFAK,AFAK);
                    CRATE_KIT_ATTRIBUTE(efak_MFAK,MFAK);
                    CRATE_KIT_ATTRIBUTE(efak_MFAKPlus,MFAKPlus);
                };
            };
        };
    };
};
