#include "script_component.hpp"

// Enhanced Utility Pouches carries its own copy of the framework (main, core, gui, arsenal), so it
// runs without EFAK. With both loaded the game uses whichever copy it loads first. Of the same
// version they are the same files; otherwise these kits may run on a framework they were not made
// for, and the player should hear about it.
private _framework = getText (configFile >> "CfgPatches" >> "efak_main" >> "versionStr");
private _kits = getText (configFile >> "CfgPatches" >> QUOTE(ADDON) >> "versionStr");

if (_framework isNotEqualTo _kits) then {
    private _message = format [LLSTRING(FrameworkMismatch), _kits, _framework];
    WARNING(_message);

    if (hasInterface) then {systemChat _message};
};
