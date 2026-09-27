# Enhanced First Aid Kits - the full guide

Everything in detail. The short version is the [README](../README.md).

An Arma 3 addon that turns the IFAK, AFAK and MFAK into real pouches: a small
item you carry, that holds whatever you put into it, and that you can open, fill
and empty as often as you like.

Requires [CBA_A3](https://github.com/CBATeam/CBA_A3) and [ACE3](https://github.com/acemod/ACE3).
Has to be loaded on the server **and** on every client.

---

## A rework of the original EFAK

This is Enhanced First Aid Kits rebuilt from the ground up and released anew as
1.0. The original kits were a one-shot package: you unpacked them once, the
contents were fixed in the CBA settings, and the interaction entries were
hardcoded slot names you could not rename. The rework is built around a single
idea - a kit is a container with an identity.

It replaces the original mod - load one or the other, never both. Kits from
the original do not carry over: missions and loadouts made with it need their
kits added again.

| | Original EFAK | Rework |
|---|---|---|
| Kit state | ammo count of a hidden magazine, 8 on/off slots | its own contents list per kit |
| Refilling | only by repacking a fixed slot | drag anything you carry into the kit |
| Taking things out | whole slot, or the whole kit | any stack, any amount, or the whole kit |
| Seeing what is inside | hint listing the configured slots | pouch UI with icons, plus a contents window |
| Kit types | three, hardcoded | four (IFAK, AFAK, MFAK, MFAK+), driven off a config registry, others can add more |
| Arsenal | kits were opaque items | own tab, every kit filled individually |
| Treatments | had to unpack first | ACE treats straight out of the kit |

### The ACE menu of a kit

Every kit you carry has an entry in the ACE self interaction (and on a casualty
or a crate, see the settings): **Open**, **Unpack all** and **Quick access**,
and - when **Show single item interactions** is on for that kit type - one
entry per stack to take it out.

**Quick access** opens a small window at the edge of the screen: the kit's
picture and name, how full it is, and every item with its picture and count
(hover for the masses). Select a row and press **Take**, or double click it, to
take the whole stack out. It follows the kit live.

### The pouch UI

Open a kit through the ACE self interaction (or the keybind under
*Enhanced First Aid Kits*) and you get your inventory on the left, the kit on
the right, a capacity bar for each, and along the bottom the ground, your
uniform, your vest and your backpack, each with the picture of what you wear,
what it holds and how full it is.

Every move happens at once - there is nothing to confirm. What changed since
you opened the window is marked on every list in front of the count:
*"(+3)  8x"* in green, *"(-1)  2x"* in red, and a row whose items all left stays
as *"(-3)  0x"*.

- **Double click** or **drag** moves one item
- While dragging, the **mouse wheel** adds or removes one (the number next to
  the mouse shows how many), the **middle mouse button** takes the whole stack
- **Ctrl** + click or drag moves the whole stack, **Shift** half of it
- The **single arrows** between the lists move the amount in the box, the
  **double arrows** move everything
- The **cross** at the top right or Escape leaves (Escape closes an open drop
  down menu first)

Rows show the count; the mass of one and of the whole stack are in the tooltip.
The search box and the sort box work on both lists, the button next to the
sort box turns the order round, and **Show all** greys in the items that may
not go into this kit, with the reason in the tooltip.

The kit's name at the top left opens a menu to switch kits without closing the
window - every kit you carry (*"IFAK #1 - Vest"*), those of a casualty you
opened it on, and those in the crate you are at.

The bottom lists take drops too: drag a stack out of the kit onto your vest and
it goes into the vest, as far as there is room. Drag it onto the ground list and
it is put down right there. Your own gear stays where it is.

**Unload container** in the middle picks where items taken out of this kit go
first - uniform, vest, backpack, or automatic (uniform, then vest, then
backpack). Whatever does not fit there goes into your other clothing and only
lands on the ground when none of it has room. The choice is kept per kit type
in your profile - unless the mission has set **Unload container** for that kit,
which locks the box for everyone.

Where the mission switched packing off for a kit type, what you took out of the
kit may still go back in while the window is open - a wrong click is not final
until you close it.

A medic can open the kit of an unconscious casualty - the left list stays the
medic's own inventory, so you can both take supplies out of the casualty's kit
and restock it from your own.

The left list has two tabs. The second one is what you are looking into, as in
the inventory: the supply **crate** or **vehicle** you are at, so you can walk an
empty IFAK up to a medical crate, open the kit and fill it straight from the
crate without the items ever touching your own inventory - or, with no crate
around, the **ground** at your feet, with whatever lies there. Kits lying inside a crate can be opened the same way - double
click or right click them in the crate list - and then the crate tab is the one
that opens first.

Two ways to open a kit without going through the interaction menu:

- **Double click** a kit you are carrying in your inventory
- The **Open** entry in CBA's right click context menu

### The ACE Arsenal tab

A kits tab appears under *Backpack*, but only while the unit in the arsenal
actually carries a kit. It lists every kit on the unit **separately** - two
IFAKs in the same vest are two rows and are filled independently - and the right
hand side is ACE's own panel: the category buttons down the right edge, the
search box, the sort box, the load bar.

Under the list is ACE's load line - the word on the left, how full the kit is on
the right - and below it the **Use CBA default** box:

- **On**: the kit holds the default contents from the mission's CBA settings
  and always comes back with them - from a saved loadout, or a respawn with your
  gear. The list is locked and greyed out while it is on, so a change to the
  mission's defaults reaches every such kit.
- **Off** (every new kit starts this way, filled with the default contents): the
  kit keeps what you put in. Saving a loadout saves exactly those items, and
  loading it gives them back.

Kit contents are part of an arsenal loadout, and the server checks them against
its own rules when a loadout is loaded - a kit filled to 2000 somewhere else only
gets what fits here, and nothing the kit's blacklist or item filter rejects.

What players may change in the tab is set per kit type with **Arsenal editing**:
everything, **remove only** (take items out, or tick **Use CBA default** to get
the complete kit back), or **nothing** - the kit is greyed out and stays as it
is. Loading a loadout in the arsenal follows the same rule. Together with
**Force default contents** a group can make sure every loadout it hands out
comes with complete kits. The Eden editor may always change everything.

The tab works in the Eden editor's ACE Arsenal too. What the kits of an editor
unit hold is kept in the unit's attributes (*Enhanced First Aid Kits → Kit
contents*) and handed to the kits when the mission starts.

### Treating straight out of a kit

An ACE treatment uses an item that is sitting inside a kit without anybody
unpacking it first - per kit type, see **Treat out of this kit** below. Carry a full IFAK
and you can bandage, inject and splint from it as if the contents were in your
pockets; they are spent out of the kit as you go, and an empty kit disappears
the same way it always did.

**ACE medical: use kit supplies** decides whether loose items or packed ones go
first, and ACE's shared equipment setting still decides whether the patient's
supplies count. The medical menu tooltip gains a line per kit type - *"6 in
IFAK"*, *"3 in AFAK"* - next to the ones ACE already shows for you, the patient
and the vehicle. **Treat out of this kit** switches it off per
kit type: an MFAK that has to be unpacked first, while IFAKs work straight away.
A kit type switched off is not used and not counted.

This works by overriding four ACE functions through `CfgFunctions` rather than
replacing them - `hasItem`, `useItem`, `countTreatmentItems` and
`formatItemCounts`. ACE's own logic runs first in each case and the kits are
only consulted when it comes up empty, so nothing changes for anyone who is not
carrying a kit.

### Compat addons

The kits are stocked for the medical mod you play with. `efak_compat_kat`,
`efak_compat_acm` and `efak_compat_acme` are addons of their own that load only
when KAT, ACM or ACM Extended is there - an addon whose required addons are
missing is skipped - and each replaces the capacity and the default contents of
every kit with a set for that mod. Without any of them the kits are stocked with
ACE items, straight out of `efak_core`.

The four kits are a chain, not four sizes of the same thing:

| Kit | For | Holds |
|---|---|---|
| IFAK | every rifleman | what someone needs on themselves: bandages, tourniquets, an airway, painkillers |
| AFAK | the team medic | that many times over, plus chest seals, IV access and a splint |
| MFAK | the squad medic | a working kit: airways, suction, monitoring, the drug set, IVs, surgical kit |
| MFAK+ | the maximum | what the squad medic has and more of it, plus AED, BVM, oxygen and the surgical set |

Only the defaults change: default contents a mission or a server set itself stay
as they are.

With **ACM Extended**, its own windows - chest seal, IV, thoracostomy,
laryngoscopy, ventilator and the rest - ask EFAK for what the medic has, so
those minigames work out of a kit the way an ACE treatment does and take the
item straight out of the kit. A portable oxygen tank in a kit is drawn from
right there, like any other opened magazine (see *Opened magazines* below).
Current versions of ACM Extended do this themselves (`ACME_fnc_itemCount`);
for older ones EFAK brings the overrides that do it, and picks the right way
when the game starts - see `docs/ACME-integration.md`.

KAT, and ACM without the extension, go through ACE medical for their
treatments, so those work out of a kit as they are. Their own extra checks do
not see into a kit: with plain ACM, for example, BVM with portable oxygen is
only offered for a tank that is loose in the inventory.

### Opened magazines

Some supplies are magazines with several uses - ACE's painkillers, ACM's pill
bottles, an oxygen tank. A treatment that uses one out of a kit takes a single
use and the bottle stays in the kit, opened: the kit keeps count of every
opened one, an opened one is used up before the next is opened, and only the
last use takes it out.

An opened bottle is listed on its own, apart from the full ones -
*"Painkillers 4x"* and *"Painkillers (7/10) 1x"* - in the kit window, the
contents window and the ACE menu, and moves as its own row. Opened ones taken
out of a loose inventory keep their fill in the kit too, and a saved loadout
keeps it. **Pack up to the default contents only** treats it as
the item it is: an opened bottle of something the defaults hold goes back in.

### Capacity instead of slots

A kit no longer has four or six or eight slots. It has a capacity in inventory
mass units, and it holds whatever fits. Defaults are 35 for the IFAK, 90 for the
AFAK, 320 for the MFAK and 520 for the MFAK+ - a compat addon may set its own -
and every one of them is a CBA setting whose
description lists a vest and three backpacks for comparison.

A kit's own `mass` is a config property and cannot change at runtime, so what is
inside a kit is felt through ACE's virtual load instead. **Kit contents weight**
is that dial, 50% by default: at 0% a kit weighs what the item weighs whatever is
in it, at 100% everything inside weighs what it weighs. What is inside always
counts, default contents included - a mission that hands its medics a kit set up
through the settings feels those items too. It needs ACE movement and counts
towards ACE weight and fatigue.

---

## How a kit keeps its contents

Arma has no per-item variables, so an item cannot carry its own state. The
approach here is the one [TFAR](https://github.com/michail-nikolaev/task-force-arma-3-radio)
uses for radios:

- every kit ships one **prototype** class (`efak_IFAK`) - that is what you place
  in the arsenal, in a loadout or in a crate
- plus a pool of **instance** classes (`efak_IFAK_1` … `efak_IFAK_400`) that
  inherit from it, generated by `tools/generate_instances.py`
- the moment a player carries a prototype it is swapped for a free instance
  class, and the contents are stored against that classname

Because the identity is the classname, contents survive everything the engine
does to an item: dropping it, putting it in a crate or a vehicle, another player
picking it up, a JIP player joining. Instances are hidden from the ACE Arsenal
lists (`ace_arsenal_hide`) but declared as arsenal items, so the arsenal keeps
them as unique items instead of dropping them from a loadout.

The server owns the instance pool and the master copy of every kit's contents,
and hands both out to clients as they join.

### Known limits

- The pool is 1000 instances **per kit type**. Beyond that ids get recycled and
  the recycled kit falls back to its default contents. Raise
  `INSTANCES_PER_KIT` in `tools/generate_instances.py` and
  `EFAK_INSTANCES_PER_KIT` in `addons/core/script_component.hpp` together if you
  need more.
- Contents changes are applied locally and then broadcast. Two people pulling
  the last item out of the same kit within the same network tick can both get
  it. In practice this needs simultaneous clicks on one casualty's kit.
- The capacity limit is a rule for **putting things in**, not a cap on what a
  kit may hold. Lower the setting below what a kit already contains and nothing
  is thrown away or lost; you simply cannot add anything until it is back under
  the limit, and everything already inside still comes out.

---

## Settings

All under **Enhanced First Aid Kits** in the CBA settings, numbered so they stay
in order.

**0) Quick setup & debug**

| Setting | What it does |
|---|---|
| Fast edit \| Choose realism mode | Sets the rules of every kit at once: players can do everything / normal / hardcore / hardcore+ / force everything. Goes back to *Choose* afterwards; capacities, default contents and lists stay |
| DEBUG: Copy backpack contents to the clipboard | Copies your backpack every 10 s in `defaultContents` form |

**1) General**

| Setting | What it does |
|---|---|
| Allow kits inside kits | Off by default, nesting folds unlimited gear into one item |
| Open on double click | Double clicking a carried kit in the inventory opens it |
| Open other units' kits | Adds their kits to their ACE interaction menu |
| Open kits of conscious units | Off: their kits only show while they are unconscious |
| Kit contents weight | 0-200%, how much of the contents' weight you actually feel (default 50%) |
| Own arsenal category for kits | Kits get their own category button instead of sitting with the medical items |
| ACE medical: use kit supplies | Loose items first and kits last, or the other way round |
| Whose kits are used first | Like ACE's own order (default), the medic's kits first, or the patient's first |
| Which kit is used first | With several kits, the smallest (default) or the biggest is used first |

**2) IFAK, 3) AFAK, 4) MFAK, 5) MFAK+** (one section per kit type)

| Setting | What it does |
|---|---|
| Capacity | How much mass the kit holds |
| Default contents | What a freshly spawned kit starts with, e.g. `[['ACE_fieldDressing',6],['ACE_morphine',1]]` |
| Force default contents | Every kit of this type starts with the defaults, whatever a loadout says it held (arsenal, respawn, Zeus, editor). Off by default |
| Pack up to the default contents only | Nothing beyond the default amounts, nothing that is not in them. **Pack all** at a crate fills the kit back up to its defaults |
| Allow packing in the kit window | Whether items may be put into this kit by hand |
| Arsenal editing | Remove and add (default) / remove only / nothing (greyed out) |
| Allowed items | Medical items only (default) / whitelist only / anything |
| Whitelist, Blacklist | Comma separated classnames |
| Unload container | Player's choice (default), or forced to automatic / uniform / vest / backpack for everyone |
| Remove when empty | Drops the kit item once the last thing is taken out. Off by default |
| Show single item interactions | Lists every item of this kit in the ACE interaction menu. Off by default: the kit offers Open, Unpack all and Quick access |
| Treat out of this kit | Whether ACE treatments may use what is inside this kit type |

See *Compat addons* below for what the kits hold with KAT, ACM or ACM Extended.

**Fast edit** forces every value it sets - from the server over the mission and
all clients, in the editor over all clients - and opens the settings again to
show the result. It never touches default contents, whitelists or blacklists.

The blacklist and the item filter hold everywhere: an item they reject is left
out of the default contents and dropped from any loadout that brings it along.
Changing the default contents does not touch kits that already exist in the
world - they keep whatever is in them.

---

## Adding your own kit type

Add a class to `EFAK_Kits`, a prototype to `CfgWeapons`, and generate the
instance pool:

```cpp
class CfgWeapons {
    class efak_IFAK;
    class mymod_TraumaBag: efak_IFAK {
        scope = 2;
        scopeArsenal = 2;
        displayName = "Trauma Bag";
        picture = "\mymod\ui\bag.paa";
    };
    // plus mymod_TraumaBag_1 .. mymod_TraumaBag_N, see tools/generate_instances.py
};

class EFAK_Kits {
    class TraumaBag {
        item = "mymod_TraumaBag";
        shortName = "TB";         // settings section and medical menu, defaults to the class name
        icon = "\mymod\ui\bag.paa";
        iconContents = "\mymod\ui\bag.paa";
        capacity = 300;
        instances = 200;          // must match the number of generated classes
        defaultContents = "[['ACE_elasticBandage',20]]";
        bag = 1;                  // optional: a bag, which the hard realism modes unload into the backpack
    };
};
```

Everything else - CBA settings, interaction entries, the pouch UI, the arsenal
tab - is generated from that registry.

## Scripting

Public functions live in `efak_core`:

```sqf
["efak_IFAK_7"] call efak_core_fnc_getContents;                        // [[class, count], ...]
["efak_IFAK_7", [["ACE_morphine", 2]]] call efak_core_fnc_setContents;  // replicated
[player, "efak_IFAK_7", "ACE_morphine", 1] call efak_core_fnc_unpackItem;
[player, "efak_IFAK_7", "ACE_morphine", 1] call efak_core_fnc_packItem;
[player, "efak_IFAK_7"] call efak_core_fnc_unpackAll;
[player] call efak_core_fnc_getCarriedKits;                            // instance classnames
[player] call efak_core_fnc_hasKits;                                   // cheap "any kit at all"
[player, "efak_IFAK_7"] call efak_gui_fnc_openPouch;
["efak_IFAK_7", player] call efak_core_fnc_showContents;              // the contents window
```

## Building

```bash
hemtt build
```

`tools/generate_instances.py` regenerates
`addons/core/CfgWeapons_instances.hpp` and only needs to run when the pool size
or the kit list changes.

## Credit

Thanks to Blue for the help while this was still a PR on KAT Advanced Medical.

## License

Arma Public License No Derivatives (APL-ND), with permission to repack, rework
and build upon this work as long as credit is given - see the Steam Workshop
page for the exact wording.
