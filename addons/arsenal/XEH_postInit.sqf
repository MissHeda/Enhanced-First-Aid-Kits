#include "script_component.hpp"
#include "defines.hpp"

if !(hasInterface) exitWith {};

// After ACE's own postInit, so the medical button the kits would otherwise sit in already exists.
[{
    call FUNC(applyCategorySetting);
}] call CBA_fnc_execNextFrame;

// The mission may say otherwise, and its settings arrive later.
["ace_settingsInitialized", {call FUNC(applyCategorySetting)}] call CBA_fnc_addEventHandler;

// ---------------------------------------------------------------------------
// Kits changing underneath the tab
// ---------------------------------------------------------------------------

// Prototypes turn into real kits a moment after they are added, and a loaded loadout swaps kits.
["loadout", {
    if (GVAR(active)) then {
        call FUNC(refreshKits);
    };
}] call CBA_fnc_addPlayerEventHandler;

[QEGVAR(core,contentsChanged), {call FUNC(onContentsChanged)}] call CBA_fnc_addEventHandler;
