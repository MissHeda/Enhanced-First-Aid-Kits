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
