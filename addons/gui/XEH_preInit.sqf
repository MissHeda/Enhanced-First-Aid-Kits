#include "script_component.hpp"
#include "defines.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// The kit the window is showing and who or what holds it - the player, a casualty or a crate.
GVAR(kitClass) = "";
GVAR(owner) = objNull;

// The unit the window was opened on when that is somebody else, so their kits stay in the switcher.
GVAR(patient) = objNull;

// The crate or vehicle the window offers as a second source for the left panel.
GVAR(crate) = objNull;
GVAR(leftSource) = SOURCE_INVENTORY;

// Every list as it was when the window opened or switched kits, so each row can say what changed:
// list key -> lowercase class -> [class, count]. Nothing outside this dialog reads it, but it has to
// exist before the first refresh looks at it.
GVAR(baseline) = createHashMap;

// Where items put on the ground go while the window is open, see fnc_getGroundHolder.
GVAR(groundHolder) = objNull;

// The kits in the switcher, row by row, and those emptied and removed while the window is open -
// removing a kit carried by somebody else takes a moment to arrive.
GVAR(kitChoices) = [];
GVAR(removedKits) = createHashMap;
GVAR(fillingKitSwitch) = false;

// Modifier state, tracked by the dialog itself because no command reports a held key. See
// fnc_openPouch for how clicks, double clicks and drops use it.
GVAR(ctrlHeld) = false;
GVAR(shiftHeld) = false;
GVAR(lastModifierMove) = -1;

// The drag in progress: how many items it carries, of how many that may move. See fnc_onDragStart.
GVAR(dragging) = false;
GVAR(dragAmount) = 1;
GVAR(dragMax) = 1;
GVAR(dragPFH) = -1;
GVAR(middleHeld) = false;

// Each kit as this window first showed it: lowercase kit class -> contents. What came out of a kit
// since may go back in even where packing is switched off, see fnc_getRepackable.
GVAR(kitStart) = createHashMap;
GVAR(kitStartCharges) = createHashMap;

// Search and sort. The sort choice is kept between openings, the search is not.
GVAR(searchText) = "";
GVAR(sortMode) = SORT_NAME;
GVAR(sortAscending) = true;
GVAR(fillingSort) = false;

// Whether the left list also shows items that cannot go into the kit. Kept between openings.
GVAR(showAll) = false;
GVAR(message) = "";
GVAR(fillingTakeInto) = false;
GVAR(applying) = false;

// The contents window: the kit it shows, who holds it, and its listener for changes to that kit.
GVAR(contentsKit) = "";
GVAR(contentsHolder) = objNull;
GVAR(contentsHandler) = -1;

ADDON = true;
