#include "script_component.hpp"

if !(hasInterface) exitWith {};

// Put the next kit down at your feet - a medic who reaches a casualty sets the bag down and treats
// out of it lying there. Unbound by default, like EFAK's other keys.
["EFAK", QGVAR(dropKit), [LLSTRING(Keybind_DropKit), LLSTRING(Keybind_DropKit_Desc)], {
    [ACE_player] call FUNC(dropNextKit)
}, {false}, []] call CBA_fnc_addKeybind;

// The same for one kit: "Drop on the ground" in its own ACE menu (efak_core_fnc_getKitActions).
