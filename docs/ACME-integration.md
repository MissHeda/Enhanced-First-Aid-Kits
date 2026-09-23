# ACM Extended and EFAK kits

EFAK (Enhanced First Aid Kits) is an ACE3 mod: an IFAK, AFAK, MFAK or MFAK+ is a single inventory
item whose **contents are virtual** - a list of `[class, count]` pairs stored per kit instance and
replicated by the server. Nothing inside a kit is an inventory item until it is taken out.

ACE medical treatments use what is inside a kit because EFAK redefines
`ace_medical_treatment_fnc_hasItem` and `ace_medical_treatment_fnc_useItem` (plus the item counts of
the ACE medical menu).

ACM Extended's own windows and actions - chest seal, IV, syringe kit, laryngoscopy, suction,
thoracostomy, ventilator, transfusion, EMMA, vials, CPR with a BVM, AED, oxygen - read and take the
medic's supplies themselves. ACM Extended routes all of that through three functions of its own that
ask EFAK when it is loaded (ACM Extended `docs/inventory-api.md`):

| ACM Extended | asks EFAK |
|---|---|
| `ACME_fnc_itemCount [unit, class]` | `efak_medical_fnc_countItem` |
| `ACME_fnc_itemTake [unit, class]` | `efak_medical_fnc_takeItem` |
| `ACME_fnc_itemList [unit, mode]` | `efak_medical_fnc_listItems` |
| portable oxygen (`useOxygenTankReserve`) | `efak_medical_fnc_drawCharge` |

With such an ACM Extended, `efak_compat_acme` only sets the kits' default contents; it overrides
nothing.

## Older ACM Extended versions

An ACM Extended without `ACME_fnc_itemCount` reads the inventory directly and sees nothing in a kit.
For those, `efak_compat_acme` still carries its legacy overrides (`addons/compat_acme/legacy/`): 22 of
ACME's functions and two of ACE's redefined through `CfgFunctions`, copies generated from ACME's PBOs
by `tools/build_acme_overrides.py`, plus the `UseSyringe` conditions.

Which one applies is decided when the game starts: the addon's `config.cpp` is not binarized, and
`#if __has_include("\acm_extended\functions\fn_itemCount.sqf")` loads the legacy part only when that
file is missing - the same pattern ACE's optional patches and other mods use
(`#pragma hemtt flag pe23_ignore_has_include`).

The copies are generated from the public ACM Extended release (workshop 3749759934). They replace its
functions, so they must come from the version that is played; regenerate them after an ACME update
until the release with `ACME_fnc_itemCount` is out. Then `legacy/`, the generator and the
`__has_include` switch can go.

## EFAK's public API

| Function | Arguments | Returns |
|---|---|---|
| `efak_medical_fnc_countItem` | `[unit, class]` | loose + in the unit's kits that treatments may use `<NUMBER>` |
| `efak_medical_fnc_takeItem` | `[unit, class]` | takes a loose one, else one out of a kit `<BOOL>` |
| `efak_medical_fnc_listItems` | `[unit, mode]` | ACE's `uniqueItems` list plus the classes in usable kits `<ARRAY>` |
| `efak_medical_fnc_drawCharge` | `[unit, magazineClass]` | one round from a multi-round magazine inside a kit, which stays there opened; rounds left, `-1` when no kit holds one `<NUMBER>` |
| `efak_medical_fnc_useCharge` | `[unit, kitClass, magazineClass]` | the same for a given kit `<NUMBER>` |
| `efak_core_fnc_getCarriedKits` | `[unit]` | kit instance classes the unit carries `<ARRAY>` |
| `efak_core_fnc_getContents` | `[kitClass]` | `[[class, count], ...]` of that kit |
| `efak_core_fnc_getCharges` | `[kitClass, class]` | rounds of each opened magazine of that class in the kit `<ARRAY>` |
| `efak_medical_fnc_canUseKit` | `[kitClass]` | whether the mission lets treatments use this kit type `<BOOL>` |

Notes:

- Kit contents are global state owned by the server; `takeItem` and `drawCharge` work on a remote
  patient's kits as well (they write through `efak_core_fnc_setContents`, a global event).
- A loose item is always taken before anything in a kit.
- Per kit type the mission can switch "Treat out of this kit" off; the functions then ignore those
  kits.
- Filled ACM syringes (`ACM_Syringe_*` magazines, the dose stored as rounds) never go into a kit
  (`EFAK_Excluded` in `efak_compat_acm`).
