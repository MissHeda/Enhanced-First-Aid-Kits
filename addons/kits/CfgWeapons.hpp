class CfgWeapons {
    class EFAK_KitBase;
    class CBA_MiscItem_ItemInfo;

    // Packed sizes are fixed, whatever capacity a mission sets: about 40% of the default capacity,
    // so a kit full of supplies takes real room - two IFAKs to a uniform, one MFAK to an assault
    // pack, one MFAK+ to a kitbag or carryall. Empty weights are the kit as sold, filled, from a
    // real product of the same size (1 mass unit = 0.1 lb).

    class efak_IFAK: EFAK_KitBase {
        model = QPATHTOF(data\ifak.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(IFAK_Display);
        descriptionShort = CSTRING(IFAK_DESC);
        picture = QPATHTOF(ui\IFAK.paa);
        editorPreview = QPATHTOF(ui\IFAK.paa);
        EFAK_emptyWeight = 11.25; // 1 lb 2 oz
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 15;
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
        EFAK_emptyWeight = 21.25; // 2 lb 2 oz
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 35;
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
        EFAK_emptyWeight = 68.75; // 6 lb 14 oz
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 130;
        };
    };

    // The MFAK's bag with more room: bigger packed, the same weight empty.
    class efak_MFAKPlus: EFAK_KitBase {
        model = QPATHTOF(data\mfakplus.p3d);
        scope = 2;
        scopeArsenal = 2;
        displayName = CSTRING(MFAKPlus_Display);
        descriptionShort = CSTRING(MFAKPlus_DESC);
        picture = QPATHTOF(ui\MFAKPlus.paa);
        editorPreview = QPATHTOF(ui\MFAKPlus.paa);
        EFAK_emptyWeight = 68.75; // 6 lb 14 oz
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 210;
        };
    };

    #include "CfgWeapons_instances.hpp"
};
