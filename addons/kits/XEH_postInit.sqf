#include "script_component.hpp"

// Enhanced Utility Pouches carries its own copy of the framework (main, core, gui, arsenal), so it
// runs without EFAK. With both loaded the game uses whichever copy it loads first. Of the same
// revision they work the same; otherwise these kits may run on a framework they were not made for,
// and the player should hear about it.
private _framework = getNumber (configFile >> "EFAK_Framework" >> "revision");

if (_framework != EFAK_FRAMEWORK_REVISION) then {
    private _message = format [LLSTRING(FrameworkMismatch), getText (configFile >> "CfgPatches" >> QUOTE(ADDON) >> "versionStr")];
    WARNING(_message);

    if (hasInterface) then {systemChat _message};
};
