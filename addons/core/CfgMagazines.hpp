class CfgMagazines {
    class CA_Magazine;

    // ----- Legacy 1.x classes -----
    // 1.x stored the kit state in a magazine's ammo count. 2.0 does not need
    // that any more, but missions and loadouts still reference these classnames,
    // so they stay around at scope 1 and are converted into a real kit the
    // moment a player carries one (see fnc_convertKits).
    class EFAK_LegacyMagazine: CA_Magazine {
        scope = 1;
        scopeArsenal = 0;
        author = "Miss Heda";
        ammo = "";
        count = 255;
        initSpeed = 0;
        tracersEvery = 0;
        lastRoundsTracer = 0;
        mass = 15;
    };

    class efak_IFAK_Magazine: EFAK_LegacyMagazine {
        displayName = CSTRING(IFAK_Display);
        descriptionShort = CSTRING(IFAK_DESC);
        picture = QPATHTOF(ui\IFAK.paa);
        mass = 15;
    };

    class efak_AFAK_Magazine: EFAK_LegacyMagazine {
        displayName = CSTRING(AFAK_Display);
        descriptionShort = CSTRING(AFAK_DESC);
        picture = QPATHTOF(ui\AFAK.paa);
        mass = 25;
    };

    class efak_MFAK_Magazine: EFAK_LegacyMagazine {
        displayName = CSTRING(MFAK_Display);
        descriptionShort = CSTRING(MFAK_DESC);
        picture = QPATHTOF(ui\MFAK.paa);
        mass = 50;
    };
};
