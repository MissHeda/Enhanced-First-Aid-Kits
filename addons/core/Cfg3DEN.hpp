// What the kits of an editor unit hold. ACE Arsenal writes it when it dresses the unit in the
// editor (fnc_applyLoadoutRestore), and the mission hands it to the kits once the unit is played
// (fnc_convertKits). The editor saves only a unit's plain inventory - without this, every kit set
// up there would start the mission with the default contents.
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
                };
            };
        };
    };
};
