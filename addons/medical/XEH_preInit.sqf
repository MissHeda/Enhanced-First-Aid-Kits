#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// The settings of this addon (efak_medical_useOrder, efak_medical_kitOwnerOrder,
// efak_medical_kitSizeOrder, efak_medical_dropOrder, efak_medical_kit_<id>_useFrom,
// efak_medical_kit_<id>_nearbyRange) are registered in core, so the menu keeps like with like.

GVAR(lastKitCounts) = [];
GVAR(nearbyHolders) = createHashMap; // lowercase kit class -> the holder it was last seen lying in, see usableKits
GVAR(nextSource) = "";                // where the treatment the medical menu shows would take its item from

ADDON = true;
