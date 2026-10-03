#define COMPONENT core
#define COMPONENT_BEAUTIFIED EFAK - Core
#include "\z\efak\addons\main\script_mod.hpp"

#include "\z\efak\addons\main\script_macros.hpp"

// Number of unique instance classes generated per kit type.
// Mirrors TFAR's radio approach: one prototype class + a pool of concrete
// classes so every kit in the world has its own identity.
// Keep in sync with tools/generate_instances.py
#define EFAK_INSTANCES_PER_KIT 500

// ----- Kit data layout (see fnc_initKits) -----
#define KIT_ID          0
#define KIT_ITEM        1
#define KIT_ICON        2
#define KIT_ICON_INFO   3
#define KIT_CAPACITY    4
#define KIT_INSTANCES   5
#define KIT_DEFAULTS    6
#define KIT_NAME        7
#define KIT_BACKGROUND  8
#define KIT_SHORT_NAME  9

// Kit ids come from the config registry, so per kit setting names are built at
// runtime with e.g. format [QGVAR(kit_%1_capacity), _kitId].

// ----- What the kits tab of the ACE Arsenal may change, per kit type -----
#define EDIT_NOTHING    0
#define EDIT_REMOVE     1
#define EDIT_ALL        2

// ----- Realism modes of the "Fast edit" setting, see fnc_applyPreset -----
#define PRESET_NONE             0
#define PRESET_SANDBOX          1
#define PRESET_NORMAL           2
#define PRESET_HARDCORE         3
#define PRESET_HARDCORE_PLUS    4
#define PRESET_FIXED            5

// ----- Item filter modes -----
#define FILTER_ALL      0
#define FILTER_MEDICAL  1
#define FILTER_LIST     2

// How often the backpack contents are copied to the clipboard while the debug setting is on.
#define EFAK_DEBUG_INTERVAL 10

// ----- Inventory display (RscDisplayInventory) -----
#define IDC_ITEMLIST_GROUND     632
#define IDC_ITEMLIST_UNIFORM    633
#define IDC_ITEMLIST_VEST       638
#define IDC_ITEMLIST_BACKPACK   619

// ----- Container preference -----
// The mission leaves the choice to the player (the kit window's "Unload container" box)
#define CONTAINER_PLAYER    -1
#define CONTAINER_AUTO      0
#define CONTAINER_UNIFORM   1
#define CONTAINER_VEST      2
#define CONTAINER_BACKPACK  3

// A joining machine asks the server for the contents table every this many seconds, this many times,
// until it has an answer.
#define EFAK_SYNC_INTERVAL          5
#define EFAK_SYNC_ATTEMPTS          24

// ----- Kit contents in loadouts (format documented in fnc_getLoadoutKits) -----
// Bump the version whenever the entry layout changes. Loadouts carrying another version are
// ignored and their kits start with the default contents, which beats misreading them.
#define LOADOUT_KITS_VERSION        1

// Written instead of a contents tree for a kit marked to follow the default contents. A string, so
// it survives export, import and the profile like the rest of the entry does.
#define LOADOUT_KIT_DEFAULT         "default"

// Loadout slots that hold containers, as indices into a getUnitLoadout array.
#define LOADOUT_SLOT_UNIFORM        3
#define LOADOUT_SLOT_VEST           4
#define LOADOUT_SLOT_BACKPACK       5

// How long contents promised by a loadout wait for their prototypes to be converted, in seconds.
// Long enough for a remote owner or a unit that becomes the player a few frames later, short
// enough that a prototype picked up from a crate afterwards gets the default contents.
#define EFAK_RESTORE_TIMEOUT        30
// How long after the player gets a new unit (respawn) its kits are checked against the bodies.
#define EFAK_DEDUPE_WINDOW          60

// Limits for contents coming from outside the mission (profile, clipboard, other modpacks).
#define EFAK_RESTORE_MAX_DEPTH      3       // kits packed inside kits
#define EFAK_RESTORE_MAX_NESTED     16      // packed kits that get an instance of their own, per kit
#define EFAK_RESTORE_MAX_ENTRIES    64      // contents entries read per kit
#define EFAK_RESTORE_MAX_COUNT      1000    // items per contents entry
