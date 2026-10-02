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

ACM Extended before 1.2.4 has no `ACME_fnc_itemCount` and reads the inventory directly, so it sees
nothing in a kit. EFAK used to carry generated copies of its functions for those versions; they were
removed in EFAK 1.0.2, once ACME 1.2.4 with the hooks was on the Workshop.

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
