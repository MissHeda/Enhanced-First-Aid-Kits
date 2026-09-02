#define COMPONENT core
#define COMPONENT_BEAUTIFIED EFAK - Core
#include "\z\efak\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_CORE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CORE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CORE
#endif

#include "\z\efak\addons\main\script_macros.hpp"

// Number of unique instance classes generated per kit type.
// Mirrors TFAR's radio approach: one prototype class + a pool of concrete
// classes so every kit in the world has its own identity.
// Keep in sync with tools/generate_instances.py
#define EFAK_INSTANCES_PER_KIT 400

// Category of the CBA settings menu
#define CBA_SETTINGS_EFAK "Enhanced First Aid Kits"

// ----- Kit data layout (see fnc_initKits) -----
#define KIT_ID          0
#define KIT_ITEM        1
#define KIT_ICON        2
#define KIT_ICON_INFO   3
#define KIT_CAPACITY    4
#define KIT_INSTANCES   5
#define KIT_DEFAULTS    6
#define KIT_NAME        7

// Kit ids come from the config registry, so per kit setting names are built at
// runtime with e.g. format [QGVAR(kit_%1_capacity), _kitId].

// ----- Item filter modes -----
#define FILTER_ALL      0
#define FILTER_MEDICAL  1
#define FILTER_LIST     2

// ----- Container preference -----
#define CONTAINER_AUTO      0
#define CONTAINER_UNIFORM   1
#define CONTAINER_VEST      2
#define CONTAINER_BACKPACK  3
