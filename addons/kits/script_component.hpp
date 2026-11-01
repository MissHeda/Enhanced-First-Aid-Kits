#define COMPONENT kits
#define COMPONENT_BEAUTIFIED EFAK - Kits
#include "\z\efak\addons\main\script_mod.hpp"

#include "\z\efak\addons\main\script_macros.hpp"

// Number of unique instance classes generated per kit type.
// Mirrors TFAR's radio approach: one prototype class + a pool of concrete
// classes so every kit in the world has its own identity.
// Keep in sync with tools/generate_instances.py
#define EFAK_INSTANCES_PER_KIT 500
// The narc box is a medic's item, a few to a squad at most: a smaller pool does.
#define EFAK_INSTANCES_NARCBOX 150

// The framework revision these kits were made for, EFAK_Framework >> revision in core's config.cpp.
#define EFAK_FRAMEWORK_REVISION 3
