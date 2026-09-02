class CfgWeapons {
    class ACE_ItemCore;
    class CBA_MiscItem_ItemInfo;

    // Common base for every kit. Never usable on its own.
    class EFAK_KitBase: ACE_ItemCore {
        author = "Miss Heda";
        scope = 0;
        scopeArsenal = 0;
        ACE_isMedicalItem = 1;
        // 1 = template. Templates are what you place in the arsenal / a loadout;
        // they are swapped for a free instance class the moment a player carries one.
        EFAK_prototype = 1;
        EFAK_instanceId = 0;
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 10;
        };
    };

    class efak_IFAK: EFAK_KitBase {
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(IFAK_Display);
        descriptionShort = CSTRING(IFAK_DESC);
        picture = QPATHTOF(ui\IFAK.paa);
        editorPreview = QPATHTOF(ui\IFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 15;
        };
    };

    class efak_AFAK: EFAK_KitBase {
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(AFAK_Display);
        descriptionShort = CSTRING(AFAK_DESC);
        picture = QPATHTOF(ui\AFAK.paa);
        editorPreview = QPATHTOF(ui\AFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 25;
        };
    };

    class efak_MFAK: EFAK_KitBase {
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(MFAK_Display);
        descriptionShort = CSTRING(MFAK_DESC);
        picture = QPATHTOF(ui\MFAK.paa);
        editorPreview = QPATHTOF(ui\MFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 50;
        };
    };

    #include "CfgWeapons_instances.hpp"
};
