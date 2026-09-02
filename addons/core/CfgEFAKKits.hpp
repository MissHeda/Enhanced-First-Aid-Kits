// Registry of every kit type. Third party mods can add their own kit by adding
// a class here - the whole addon is driven off this list, nothing is hardcoded.
//
//   item             prototype classname in CfgWeapons
//   icon             icon used for the ACE actions
//   iconContents     icon used for the "show contents" action
//   capacity         default carry capacity in mass units (overridable via CBA)
//   instances        size of the generated instance class pool
//   defaultContents  contents a freshly spawned kit starts with (overridable via CBA)
//   legacyClasses[]  old classnames that get converted into this kit on pickup
class EFAK_Kits {
    class IFAK {
        item = "efak_IFAK";
        icon = QPATHTOF(ui\IFAK.paa);
        iconContents = QPATHTOF(ui\IFAK_DisplayItems.paa);
        capacity = 60;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_fieldDressing',6],['ACE_morphine',1],['ACE_tourniquet',2]]";
        legacyClasses[] = {"efak_IFAK_Magazine"};
    };

    class AFAK {
        item = "efak_AFAK";
        icon = QPATHTOF(ui\AFAK.paa);
        iconContents = QPATHTOF(ui\AFAK_DisplayItems.paa);
        capacity = 120;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',10],['ACE_packingBandage',6],['ACE_morphine',2],['ACE_epinephrine',2],['ACE_tourniquet',4]]";
        legacyClasses[] = {"efak_AFAK_Magazine"};
    };

    class MFAK {
        item = "efak_MFAK";
        icon = QPATHTOF(ui\MFAK.paa);
        iconContents = QPATHTOF(ui\MFAK_DisplayItems.paa);
        capacity = 250;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',20],['ACE_packingBandage',15],['ACE_quikclot',15],['ACE_morphine',5],['ACE_epinephrine',5],['ACE_tourniquet',6],['ACE_bloodIV',2],['ACE_surgicalKit',1]]";
        legacyClasses[] = {"efak_MFAK_Magazine"};
    };
};
