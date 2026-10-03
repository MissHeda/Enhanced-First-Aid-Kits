class CfgWeapons {
    class ACE_ItemCore;
    class CBA_MiscItem_ItemInfo;

    // Common base for every kit. Never usable on its own. EFAK's own kits are in addons/kits; the
    // model stays the IFAK's for kits of other mods that never set one.
    class EFAK_KitBase: ACE_ItemCore {
        author = "Miss Heda";
        model = "\z\efak\addons\kits\data\ifak.p3d";
        scope = 0;
        scopeArsenal = 0;
        ACE_isMedicalItem = 1;
        // 1 = template. Templates are what you place in the arsenal / a loadout;
        // they are swapped for a free instance class the moment a player carries one.
        EFAK_prototype = 1;
        EFAK_instanceId = 0;
        // ItemInfo mass is the room the packed kit takes in a uniform, vest or backpack - the
        // engine has one number for room and weight. EFAK_emptyWeight, when set, is what the
        // empty kit weighs instead; the difference is evened out through ACE's virtual load
        // while a player carries it (fnc_updateVirtualLoad). Without it the kit weighs its mass.
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 10;
        };
    };
};
