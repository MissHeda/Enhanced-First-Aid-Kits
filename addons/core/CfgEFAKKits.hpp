// Registry of every kit type. Third party mods can add their own kit by adding
// a class here - the whole addon is driven off this list, nothing is hardcoded.
//
//   item             prototype classname in CfgWeapons
//   shortName        short name for settings sections and the medical menu, e.g. "IFAK"
//                    (defaults to the class name)
//   icon             icon used for the ACE actions
//   iconContents     icon used for the "show contents" action
//   capacity         default carry capacity in mass units (overridable via CBA)
//   instances        size of the generated instance class pool
//   defaultContents  contents a freshly spawned kit starts with (overridable via CBA)
//   background       optional .paa drawn behind the contents list, so opening a kit looks like
//                    opening that kit. Leave empty for the plain panel.
//
// Three kits by size: individual, advanced, and one for several casualties. Item masses come from real
// products of each size; the stock fills are what a unit would issue with ACE. The AFAK carries an IFAK
// inside - the prototype, never an instance id, or every AFAK would share that one IFAK. Items of a mod
// that is not loaded are dropped quietly, so a mission can put ACM or KAT items in here.
//
// These are the ACE loadouts. With KAT, ACM or ACM Extended loaded, the compat addon of that mod
// (addons/compat_*) replaces capacity and contents with its own - see its CfgEFAKKits.hpp.

class EFAK_Kits {
    // Individual first aid kit, carried by everyone. Modelled on a standard IFAK pouch.
    class IFAK {
        item = "efak_IFAK";
        shortName = "IFAK";
        icon = QPATHTOF(ui\IFAK.paa);
        iconContents = QPATHTOF(ui\IFAK.paa);
        capacity = 35;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',6],['ACE_packingBandage',8],['ACE_quikclot',6],['ACE_tourniquet',3],['ACE_morphine',1],['ACE_epinephrine',1],['ACE_painkillers',2],['ACE_splint',1]]";
        background = "";
    };

    // Advanced first aid kit, a bigger trauma pouch with enough for more than one casualty.
    class AFAK {
        item = "efak_AFAK";
        shortName = "AFAK";
        icon = QPATHTOF(ui\AFAK.paa);
        iconContents = QPATHTOF(ui\AFAK.paa);
        capacity = 90;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',15],['ACE_packingBandage',15],['ACE_quikclot',10],['ACE_tourniquet',6],['ACE_morphine',4],['ACE_epinephrine',4],['ACE_painkillers',4],['ACE_splint',2],['ACE_suture',10],['ACE_salineIV_250',2],['ACE_plasmaIV_250',2]]";
        background = "";
    };

    // Multiple first aid kit, supplies for several casualties. Big, but still a bag that goes into
    // a backpack, not a backpack.
    class MFAK {
        item = "efak_MFAK";
        shortName = "MFAK";
        icon = QPATHTOF(ui\MFAK.paa);
        iconContents = QPATHTOF(ui\MFAK.paa);
        capacity = 320;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',40],['ACE_packingBandage',30],['ACE_quikclot',25],['ACE_tourniquet',12],['ACE_morphine',10],['ACE_epinephrine',10],['ACE_painkillers',10],['ACE_splint',8],['ACE_adenosine',6],['ACE_surgicalKit',1],['ACE_suture',40],['ACE_salineIV_500',4],['ACE_salineIV_250',4],['ACE_plasmaIV_500',4],['ACE_plasmaIV_250',4],['ACE_bloodIV_250',4]]";
        // A bag rather than a pouch: the hard realism modes unload it into the backpack.
        bag = 1;
        background = "";
    };

    // The same bag as the MFAK with more room, for a medic who carries for the whole squad.
    class MFAKPlus {
        item = "efak_MFAKPlus";
        shortName = "MFAK+";
        icon = QPATHTOF(ui\MFAKPlus.paa);
        iconContents = QPATHTOF(ui\MFAKPlus.paa);
        capacity = 520;
        instances = EFAK_INSTANCES_PER_KIT;
        defaultContents = "[['ACE_elasticBandage',60],['ACE_packingBandage',45],['ACE_quikclot',40],['ACE_tourniquet',16],['ACE_morphine',15],['ACE_epinephrine',15],['ACE_painkillers',15],['ACE_splint',12],['ACE_adenosine',8],['ACE_surgicalKit',2],['ACE_suture',60],['ACE_salineIV_500',6],['ACE_salineIV_250',6],['ACE_plasmaIV_500',6],['ACE_plasmaIV_250',6],['ACE_bloodIV_500',4],['ACE_bloodIV_250',6]]";
        // A bag rather than a pouch: the hard realism modes unload it into the backpack.
        bag = 1;
        background = "";
    };
};
