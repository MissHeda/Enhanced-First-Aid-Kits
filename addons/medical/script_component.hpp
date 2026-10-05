#define COMPONENT medical
#define COMPONENT_BEAUTIFIED EFAK - Medical
#include "\z\efak\addons\main\script_mod.hpp"

#include "\z\efak\addons\main\script_macros.hpp"

// Kit data indices, mirror addons/core/script_component.hpp
#define KIT_ID          0
#define KIT_SHORT_NAME  9
#define KIT_TREATMENTS  12

// Whose kits a treatment uses first, efak_medical_kitOwnerOrder
#define KIT_OWNER_ACE       0
#define KIT_OWNER_MEDIC     1
#define KIT_OWNER_PATIENT   2

// Which of several kits first, efak_medical_kitSizeOrder
#define KIT_SIZE_SMALLEST   0
#define KIT_SIZE_BIGGEST    1

// What a treatment uses up first, efak_medical_useOrder
#define USE_LOOSE_FIRST     0   // loose items, then kits
#define USE_KITS_FIRST      1   // kits, then loose items
#define USE_GROUND_FIRST    2   // kits lying nearby, then loose items, then carried kits

// Which kits usableKits returns
#define KITS_ALL            0
#define KITS_CARRIED        1
#define KITS_GROUND         2

// Which kit the drop key puts down first, efak_medical_dropOrder (each player's own)
#define DROP_BIGGEST        0
#define DROP_SMALLEST       1
