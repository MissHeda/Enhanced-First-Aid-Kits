#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// The settings of this addon (efak_medical_useOrder, efak_medical_kit_<id>_useFrom) are registered
// in core, so the menu keeps like with like.

GVAR(lastKitCounts) = [];

ADDON = true;
