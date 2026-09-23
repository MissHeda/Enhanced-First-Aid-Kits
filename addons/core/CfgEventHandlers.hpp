class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
        disableModuload = "true";
    };
};

class Extended_DisplayLoad_EventHandlers {
    class RscDisplayInventory {
        ADDON = QUOTE(call FUNC(inventoryDisplayLoad));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};