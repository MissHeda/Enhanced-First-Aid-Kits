// ACM offers "Use syringe" only for an empty syringe that is loose in the inventory
// ('ACM_Syringe_10' in (items _medic)). Counted with the kits instead, so a syringe packed in a kit
// can be drawn up; Syringe_PrepareFinish (legacy\acme\) then takes it out of the kit.
class ace_medical_treatment_actions {
    class OpenTransfusionMenu;
    class UseSyringe_10: OpenTransfusionMenu {
        condition = "([_medic, 'ACM_Syringe_10'] call efak_medical_fnc_countItem) > 0";
    };
    class UseSyringe_5: UseSyringe_10 {
        condition = "([_medic, 'ACM_Syringe_5'] call efak_medical_fnc_countItem) > 0";
    };
    class UseSyringe_3: UseSyringe_10 {
        condition = "([_medic, 'ACM_Syringe_3'] call efak_medical_fnc_countItem) > 0";
    };
    class UseSyringe_1: UseSyringe_10 {
        condition = "([_medic, 'ACM_Syringe_1'] call efak_medical_fnc_countItem) > 0";
    };
};
