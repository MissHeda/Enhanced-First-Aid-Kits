class CfgWeapons {
    class ACE_ItemCore;
    class CBA_MiscItem_ItemInfo;

    // Common base for every kit. Never usable on its own.
    class EFAK_KitBase: ACE_ItemCore {
        author = "Miss Heda";
        model = QPATHTOF(data\ifak.p3d);
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

    // Masses are the kit as sold, filled, from a real product of the same size
    // (1 mass unit = 0.1 lb).

    class efak_IFAK: EFAK_KitBase {
        model = QPATHTOF(data\ifak.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(IFAK_Display);
        descriptionShort = CSTRING(IFAK_DESC);
        picture = QPATHTOF(ui\IFAK.paa);
        editorPreview = QPATHTOF(ui\IFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 11.25; // 1 lb 2 oz
        };
    };

    class efak_AFAK: EFAK_KitBase {
        model = QPATHTOF(data\afak.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(AFAK_Display);
        descriptionShort = CSTRING(AFAK_DESC);
        picture = QPATHTOF(ui\AFAK.paa);
        editorPreview = QPATHTOF(ui\AFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 21.25; // 2 lb 2 oz
        };
    };

    class efak_MFAK: EFAK_KitBase {
        model = QPATHTOF(data\mfak.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(MFAK_Display);
        descriptionShort = CSTRING(MFAK_DESC);
        picture = QPATHTOF(ui\MFAK.paa);
        editorPreview = QPATHTOF(ui\MFAK.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 68.75; // 6 lb 14 oz
        };
    };

    // The MFAK's bag with more room, so it weighs the same empty.
    class efak_MFAKPlus: EFAK_KitBase {
        model = QPATHTOF(data\mfakplus.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(MFAKPlus_Display);
        descriptionShort = CSTRING(MFAKPlus_DESC);
        picture = QPATHTOF(ui\MFAKPlus.paa);
        editorPreview = QPATHTOF(ui\MFAKPlus.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 68.75; // 6 lb 14 oz
        };
    };

    #include "CfgWeapons_instances.hpp"
};
