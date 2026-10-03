// Registry of every kit type. Third party mods can add their own kit by adding
// a class here - the whole addon is driven off this list, nothing is hardcoded.
//
//   item             prototype classname in CfgWeapons
//   shortName        short name for settings sections and the medical menu, e.g. "IFAK"
//                    (defaults to the class name)
//   icon             icon used for the ACE actions
//   iconContents     icon used for the "Quick access" action
//   capacity         default carry capacity in mass units (overridable via CBA)
//   instances        size of the generated instance class pool
//   defaultContents  contents a freshly spawned kit starts with (overridable via CBA)
//   background       optional .paa drawn behind the contents list, so opening a kit looks like
//                    opening that kit. Leave empty for the plain panel.
//
// Optional, for containers that are not first aid kits (pouches, bags of another mod):
//
//   itemFilter       default of the item filter setting: 0 everything, 1 medical (default), 2 list
//   itemTypes[]      the only kinds of items it takes, as ace_common_fnc_getItemType gives them:
//                    "magazine", "item", or with the subtype, e.g. "magazine/secondary". The
//                    mission's whitelist still lets other items in. Empty (default): any kind.
//                    Worn things (uniforms, glasses, vests...) only go into a container that
//                    names them here outright, e.g. "item/uniform"; backpacks as "backpack".
//   whitelist        default of the whitelist setting, class names separated by commas
//   useInTreatments  default of "usable for treatments": 1 (default) or 0
//   group            interaction menu it is listed under, a class of EFAK_KitGroups
//                    (default "FirstAid")
//   settingsCategory CBA settings category of its settings, "" (default) for EFAK's own
//
// The framework itself registers no kit: EFAK's own are in addons/kits, another mod brings its own.

class EFAK_Kits {};

// Interaction menus the kits are listed under, one entry on yourself and one on others each. EFAK's
// first aid kits are under "FirstAid" (addons/kits); another mod's containers can come with their
// own ("group" in EFAK_Kits).
class EFAK_KitGroups {};
