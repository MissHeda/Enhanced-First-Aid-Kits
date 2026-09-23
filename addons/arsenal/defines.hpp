// Text alignment, the same numbers ACE's own controls use.
#define ST_LEFT     0
#define ST_RIGHT    1

// ACE Arsenal's pixel grid, copied from ace_arsenal's defines.hpp. The EFAK controls sit on top of
// ACE's own panels, so they have to be measured in exactly the same units.
#define GRID_W (pixelW * pixelGridNoUIScale * 0.25)
#define GRID_H (pixelH * pixelGridNoUIScale * 0.25)

// ACE fades its panels over this long, see ace_arsenal's FADE_DELAY.
#define FADE_DELAY 0.15

// ----- ACE Arsenal (ace_arsenal defines.hpp, same in 3.20 and 3.21) -----
#define IDD_ACE_ARSENAL             1127001
#define IDD_ACE_LOADOUTS            1127002
#define IDC_ACE_MENUBAR             10
#define IDC_ACE_TOTAL_WEIGHT_TEXT   801

// Every ACE control the kits tab covers up. Left panel: list, sort, search. Right panel: frame,
// load bar, both lists, sort, search, the current magazine buttons and "remove all". Plus the item
// info, stats and actions boxes, which would otherwise keep describing whatever ACE had selected
// last. The category buttons down the right edge are NOT covered - the tab borrows them, see below.
// ACE's own list arrows (101/102) are left alone - ACE never touches them either, the engine
// shows them with their list.
#define ACE_COVERED_IDCS \
    13, 16, 161, 18, 41, \
    5, 6, 7, 14, 15, 17, 171, 19, 42, 40, \
    3001, 3002, 3003, 3004, \
    11, 51, 52, 53, 54, 90

// ACE's category buttons down the right edge - the set ACE shows for a backpack: attachments,
// compatible magazines, all magazines, grenades, explosives, misc items and the custom buttons other
// mods add. Each background sits at its button's IDC - 1. While the kits tab is open they filter the
// kit contents list instead of ACE's.
#define ACE_BUTTON_OPTIC        22
#define ACE_BUTTON_ITEMACC      24
#define ACE_BUTTON_MUZZLE       26
#define ACE_BUTTON_BIPOD        28
#define ACE_BUTTON_MAG          30
#define ACE_BUTTON_MAGALL       32
#define ACE_BUTTON_THROW        34
#define ACE_BUTTON_PUT          36
#define ACE_BUTTON_MISC         38
#define ACE_CUSTOM_BUTTONS      61, 63, 65, 67, 69, 71, 73, 75, 77, 79
#define ACE_CATEGORY_BUTTONS \
    ACE_BUTTON_OPTIC, ACE_BUTTON_ITEMACC, ACE_BUTTON_MUZZLE, ACE_BUTTON_BIPOD, \
    ACE_BUTTON_MAG, ACE_BUTTON_MAGALL, ACE_BUTTON_THROW, ACE_BUTTON_PUT, ACE_BUTTON_MISC, \
    ACE_CUSTOM_BUTTONS
#define ACE_CATEGORY_IDCS \
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, \
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79

// ACE's left tabs below the backpack, button and background each (ace_arsenal defines.hpp)
#define ACE_TABS_BELOW_BACKPACK \
    2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, \
    2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037

// ----- EFAK kits tab -----
#define IDC_EFAK_TAB_BACKGROUND     88501
#define IDC_EFAK_TAB                88502 // ACE finds a tab's background at IDC - 1
#define IDC_EFAK_KIT_LIST           88503
#define IDC_EFAK_LEFT_TITLE         88504
#define IDC_EFAK_LEFT_HINT          88505
#define IDC_EFAK_RIGHT_FRAME        88506
#define IDC_EFAK_RIGHT_BACKGROUND   88507
#define IDC_EFAK_ARROW_MINUS        88508
#define IDC_EFAK_ARROW_PLUS         88509
#define IDC_EFAK_CONTENTS           88510
#define IDC_EFAK_RIGHT_TITLE        88511
#define IDC_EFAK_RIGHT_HINT         88512
#define IDC_EFAK_LOAD_BACKGROUND    88513
#define IDC_EFAK_LOAD_BAR           88514
#define IDC_EFAK_LOAD_TEXT          88515
#define IDC_EFAK_LOAD_TITLE         88516
#define IDC_EFAK_DEFAULTS           88517 // "Use CBA default" box under the load line
#define IDC_EFAK_CLEAR              88518
#define IDC_EFAK_DEFAULTS_LABEL     88519
// The kits' own category button, shown in the tab when the kits are not given a category of their
// own in ACE's tabs. Its background sits at IDC - 1, the way ACE's own category buttons do.
#define IDC_EFAK_CATEGORY_BG        88524
#define IDC_EFAK_CATEGORY           88525
// Search and sort above the contents list, copies of ACE's own right panel controls
#define IDC_EFAK_SEARCH             88520
#define IDC_EFAK_SEARCH_BUTTON      88521
#define IDC_EFAK_SORT               88522
#define IDC_EFAK_SORT_DIR           88523

// Sort keys, in the order they appear in the sort box
#define SORT_NAME   0
#define SORT_MASS   1
#define SORT_AMOUNT 2


// The tab's panels. The clear button is shown with them but enabled by what the kits hold, and the
// arrows belong to the contents list.
#define EFAK_PANEL_IDCS \
    IDC_EFAK_KIT_LIST, \
    IDC_EFAK_LEFT_TITLE, \
    IDC_EFAK_LEFT_HINT, \
    IDC_EFAK_RIGHT_FRAME, \
    IDC_EFAK_RIGHT_BACKGROUND, \
    IDC_EFAK_CONTENTS, \
    IDC_EFAK_SEARCH, \
    IDC_EFAK_SEARCH_BUTTON, \
    IDC_EFAK_SORT, \
    IDC_EFAK_SORT_DIR, \
    IDC_EFAK_LOAD_BACKGROUND, \
    IDC_EFAK_LOAD_BAR, \
    IDC_EFAK_LOAD_TITLE, \
    IDC_EFAK_LOAD_TEXT, \
    IDC_EFAK_DEFAULTS, \
    IDC_EFAK_DEFAULTS_LABEL

// What the kits tab may change about a kit type, from efak_core_fnc_getArsenalEditing. Mirrors
// core's script_component.hpp, which this addon does not include.
#define EDIT_NOTHING    0
#define EDIT_REMOVE     1
#define EDIT_ALL        2

// Kit list row kinds, stored with lbSetValue
#define ROW_KITS        0
#define ROW_PREPARING   1
#define ROW_NOTICE      2

// Seconds after the last click before staged changes are written
#define FLUSH_DELAY 1

// Masses are decimals: three bandages at 0.4 must still fit into 1.2 of space.
#define MASS_EPSILON 0.0001

// Keys, from defineDIKCodes.inc
#define DIK_LEFT    203
#define DIK_RIGHT   205

#define COLOR_GREYED [1, 1, 1, 0.4]
