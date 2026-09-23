#include "script_component.hpp"
#include "defines.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// Whether the kits tab is laid over the arsenal right now.
GVAR(active) = false;

// How ACE's covered controls looked when the tab opened, so closing it can put them back exactly.
GVAR(snapshot) = [];

// Staging, per lowercase instance class: what the kit held when it was last read or written, and
// what the tab has made of it since. Only the difference is ever written.
GVAR(base) = createHashMap;
GVAR(pending) = createHashMap;
GVAR(classNames) = createHashMap;   // lowercase instance class -> class as carried

// [prototype, [instance classes], kits still being prepared], registry order
GVAR(groups) = [];
GVAR(selected) = "";
GVAR(selectedPreparing) = false;
GVAR(kitSelectionSeen) = false;
GVAR(contentsShown) = [];           // [prototype, preparing] the contents list was last drawn for
GVAR(hasItems) = false;             // whether any kit of the selected type holds anything

// Per arsenal session caches. Rows of the contents list look up what they show here.
GVAR(candidates) = createHashMap;   // lowercase prototype -> [rules stamp, [[name, class], ...] sorted by name, lookup]
GVAR(available) = createHashMap;    // lowercase class -> true for everything the arsenal offers
GVAR(availableSource) = createHashMap;
GVAR(itemInfo) = createHashMap;     // lowercase class -> [class, name, picture, mass]
GVAR(rowInfo) = createHashMap;      // lowercase class -> [can be added, reason if not, most a kit may hold or -1]

GVAR(kitListFocus) = false;
GVAR(contentsFocus) = false;
GVAR(writing) = false;
GVAR(flushToken) = 0;

// Which of ACE's right-hand category buttons the contents list follows. Misc items by default,
// which is where ACE files medical items unless another mod gives them a button of their own.
GVAR(category) = 38;
GVAR(containedKeys) = createHashMap;

// ACE custom right panel button for the kits, registered in postInit. -1 until then or if ACE had no
// free slot.
GVAR(kitsButtonSlot) = -1;

// The kits the category button lists: the prototypes you take out of the arsenal. Not the instance
// classes a carried kit turns into: ACE keeps listing every one the unit ever held, so the button
// filled up with look-alike kits that cannot be taken. Those fall into ACE's misc items instead,
// where a carried one can still be put back.
GVAR(kitClasses) = +EGVAR(core,kitList);

// Kit classes taken out of somebody else's category button, per slot, so they can be put back.
GVAR(borrowedFrom) = createHashMap;

// ACE's category buttons plus, when the kits have no category of their own, the tab's own one.
GVAR(categoryIdcs) = [ACE_CATEGORY_BUTTONS];

// ACE's own kit button while the tab stands in for it, -1 when there is none.
GVAR(aceKitsButtonIdc) = -1;


// Whether the kits tab currently has its slot under the backpack, and where ACE's config put the
// tabs below it. Both are per arsenal display, reset when one opens.
GVAR(tabSlotShown) = -1;
GVAR(tabConfigTop) = createHashMap;
GVAR(tabSlotPFH) = -1;
GVAR(kitsButtonIdc) = -1;

// Search and sort above the contents list. The sort choice is kept between openings.
GVAR(searchText) = "";
GVAR(sortMode) = 0;
GVAR(sortAscending) = true;
GVAR(fillingSort) = false;
GVAR(categoryCache) = createHashMap;
GVAR(compatibleMagazines) = createHashMap;
GVAR(buttonHandlerIds) = createHashMap;
GVAR(settingDefaultsBox) = false;      // true while a script, not the player, sets the box
GVAR(locked) = false;                  // the selected kit follows the defaults or may not be changed, see updateDefaultsBox
GVAR(editing) = EDIT_ALL;              // what the tab may change about the selected kit, see updateDefaultsBox

if (hasInterface) then {
    // ---------------------------------------------------------------------------
    // ACE Arsenal
    //
    // The kits tab never touches ACE's idea of which tab is open, so ACE's own events are what tell it
    // when to step aside. Registered in preInit: the Eden editor's arsenal runs nothing later than that.
    // ---------------------------------------------------------------------------

    [QACEGVAR(arsenal,displayOpened), {call FUNC(onDisplayOpened)}] call CBA_fnc_addEventHandler;
    [QACEGVAR(arsenal,displayClosed), {call FUNC(onDisplayClosed)}] call CBA_fnc_addEventHandler;

    // Raised whenever ACE fills its left panel: another tab was clicked, the arsenal refreshed, a
    // search was cleared or the loadouts screen closed. Each of those means ACE is taking over again.
    [QACEGVAR(arsenal,leftPanelFilled), {
        params ["_display"];

        if (GVAR(active)) then {
            [_display] call FUNC(closeTab);
        };
    }] call CBA_fnc_addEventHandler;

    // Backspace, the hide button and the loadouts screen hide and show the whole interface. Only ACE
    // 3.21 and later raise this - on older versions the tab simply stays up while the rest is hidden.
    [QACEGVAR(arsenal,showToggle), {
        params ["_display"];

        if (GVAR(active)) then {
            [_display] call FUNC(applyVisibility);
        };
    }] call CBA_fnc_addEventHandler;
};

// "Own arsenal category for kits" is registered with the other settings in core, which runs its
// script before the functions here exist. Its value is applied now that they do.
call FUNC(applyCategorySetting);

ADDON = true;
