#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// Runtime state. All of these are rebuilt from scratch every mission.
GVAR(contents) = createHashMap;             // lowercase instance class -> [[item, count], ...]
GVAR(charges) = createHashMap;              // lowercase instance class -> [[item, rounds], ...] opened magazines, see fnc_setContents
GVAR(followDefaults) = createHashMap;       // lowercase instance class -> true, see fnc_setFollowDefaults
GVAR(usedInstances) = createHashMap;        // server only, lowercase instance class -> true
GVAR(nextInstance) = createHashMap;         // server only, lowercase prototype -> next id
GVAR(nextRequestId) = 0;                    // instance requests sent from this machine
GVAR(massCache) = createHashMap;
GVAR(weightOffsetCache) = createHashMap;
GVAR(labels) = createHashMap;            // lowercase instance class -> the name a player gave it
GVAR(typeNames) = createHashMap;         // lowercase prototype -> the name the settings give its type, see updateTypeNames
GVAR(nameCache) = createHashMap;              // lowercase class -> display name
GVAR(pictureCache) = createHashMap;           // lowercase class -> picture path
GVAR(contextMenuRegistered) = createHashMap;  // lowercase kit class -> true

// The container the player last opened. The engine tells us which one, which beats guessing from
// distance when several are stacked together.
GVAR(lastContainer) = objNull;

// Handle of the clipboard loop the debug setting runs.
GVAR(debugPFH) = -1;

// Kit weight. Contents are only trustworthy on a client once the server's copy has arrived.
GVAR(virtualLoadQueued) = false;
// The editor has no server to wait for: whatever it holds is all there is.
GVAR(contentsSynced) = isServer || {is3DEN};
// Bumped on every contents change, so anything that caches per kit knows when to give up.
GVAR(contentsStamp) = 0;
GVAR(whitelistLookup) = createHashMap;      // kit id -> lowercase class -> true
GVAR(blacklistLookup) = createHashMap;      // kit id -> lowercase class -> true
GVAR(whitelistPattern) = createHashMap;     // kit id -> regex of the entries with a *, or ""
GVAR(blacklistPattern) = createHashMap;     // kit id -> regex of the entries with a *, or ""
GVAR(medicalLookup) = createHashMap;

// Magazines no kit may hold, by the start of their lowercase class name. Compat addons list them in
// EFAK_Excluded, e.g. ACM's filled syringes, which keep the drawn dose as their rounds.
GVAR(excludedPrefixes) = [];
{
    GVAR(excludedPrefixes) append ((getArray (_x >> "magazinePrefixes")) apply {toLowerANSI _x});
} forEach ("true" configClasses (configFile >> "EFAK_Excluded"));
// Bumped whenever the packing rules change, see fnc_settingsChanged and fnc_getDefaultContents.
GVAR(rulesStamp) = 0;
GVAR(defaultsCache) = createHashMap;        // kit id -> [setting, rulesStamp, contents]

call FUNC(initKits);

// The events that change the contents table. Here rather than in postInit because the Eden editor
// runs preInit only, and ACE Arsenal's kits tab works there too.
[QGVAR(contentsChanged), {
    params ["_class", "_contents", ["_charges", -1]];

    private _key = toLowerANSI _class;

    // Raised without them (a kit freed on the server): kept as far as the contents still hold them.
    if (_charges isEqualTo -1) then {
        _charges = [_contents, GVAR(charges) getOrDefault [_key, []]] call FUNC(reconcileCharges);
    };

    if (_contents isEqualTo []) then {
        GVAR(contents) deleteAt _key;
    } else {
        GVAR(contents) set [_key, _contents];
    };

    if (_charges isEqualTo []) then {
        GVAR(charges) deleteAt _key;
    } else {
        GVAR(charges) set [_key, _charges];
    };

    GVAR(contentsStamp) = GVAR(contentsStamp) + 1;

    // Contents changes never touch getUnitLoadout, so nothing else would tell the kit weight that
    // a medic just used a bandage out of this kit, or somebody packed into it from another machine.
    if (hasInterface) then {call FUNC(queueVirtualLoad)};
}] call CBA_fnc_addEventHandler;

// The full table, for a machine that joins. The question is asked in postInit (see there); both
// ends are registered here, as early as possible, so that neither can miss the other.
// The tables travel as "toArray" gives them - [[keys], [values]], not pairs - and are put back
// together with "keys createHashMapFromArray values".
[QGVAR(syncAll), {
    params [["_contents", [[], []]], ["_follow", []], ["_charges", [[], []]], ["_labels", [[], []]]];
    GVAR(contents) = (_contents select 0) createHashMapFromArray (_contents select 1);
    GVAR(followDefaults) = createHashMapFromArray (_follow apply {[_x, true]});
    GVAR(charges) = (_charges select 0) createHashMapFromArray (_charges select 1);
    GVAR(labels) = (_labels select 0) createHashMapFromArray (_labels select 1);
    GVAR(contentsSynced) = true;
    GVAR(contentsStamp) = GVAR(contentsStamp) + 1;
    call FUNC(queueVirtualLoad);
}] call CBA_fnc_addEventHandler;

if (isServer) then {
    [QGVAR(requestSync), {
        params ["_owner"];
        [QGVAR(syncAll), [toArray GVAR(contents), keys GVAR(followDefaults), toArray GVAR(charges), toArray GVAR(labels)], _owner] call CBA_fnc_ownerEvent;
    }] call CBA_fnc_addEventHandler;
};

// The names players give their kits (fnc_setKitLabel), on every machine like the contents.
[QGVAR(labelChanged), {
    params ["_class", "_label"];

    if (_label isEqualTo "") then {
        GVAR(labels) deleteAt (toLowerANSI _class);
    } else {
        GVAR(labels) set [toLowerANSI _class, _label];
    };

    GVAR(contentsStamp) = GVAR(contentsStamp) + 1;
}] call CBA_fnc_addEventHandler;

// Kits marked to come back with the default contents from a saved loadout.
[QGVAR(followDefaultsChanged), {
    params ["_class", "_follow"];

    if (_follow) then {
        GVAR(followDefaults) set [toLowerANSI _class, true];
    } else {
        GVAR(followDefaults) deleteAt (toLowerANSI _class);
    };
}] call CBA_fnc_addEventHandler;

// ---------------------------------------------------------------------------
// Kit contents in loadouts
//
// Registered here, on every machine, like ACE's own extended loadout handlers: loadouts are read
// and set wherever a unit happens to be local, including the server and headless clients, and
// possibly before postInit has run. Per unit state lives in object variables, never public:
//   efak_core_loadoutGeneration   bumped by every loadout set, stale grants are handed back
//   efak_core_pendingConversions  "slot:class" -> [[requestId, contents], ...] still on their way
//   efak_core_restoreQueue        [expiresAt, "slot:prototype" -> [contents, ...]]
// ---------------------------------------------------------------------------

["CBA_loadoutGet", {_this call FUNC(onLoadoutGet)}] call CBA_fnc_addEventHandler;
["CBA_preLoadoutSet", {_this call FUNC(onPreLoadoutSet)}] call CBA_fnc_addEventHandler;
["CBA_loadoutSet", {_this call FUNC(onLoadoutSet)}] call CBA_fnc_addEventHandler;

// A loadout set on a unit that is local somewhere else.
[QGVAR(restoreLoadoutKits), {_this call FUNC(applyLoadoutRestore)}] call CBA_fnc_addEventHandler;

if (isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then {
    [QACEGVAR(arsenal,loadoutVerified), {_this call FUNC(onArsenalLoadoutVerified)}] call CBA_fnc_addEventHandler;
};

// ---------------------------------------------------------------------------
// Settings
//
// Grouped by what they are about, and within that like with like - switches together, lists
// together, text boxes together - so the menu reads as a form rather than a mix.
// ---------------------------------------------------------------------------

// The category of the general settings and of every kit without one of its own: EFAK's, or the name
// of a mod that brings the framework along without it (EFAK_Framework, core's config.cpp).
GVAR(settingsCategory) = getText (configFile >> "EFAK_Framework" >> "settingsCategory");

if ((GVAR(settingsCategory) select [0, 1]) == "$") then {
    GVAR(settingsCategory) = localize (GVAR(settingsCategory) select [1]);
};

if (GVAR(settingsCategory) isEqualTo "") then {GVAR(settingsCategory) = CBA_SETTINGS_EFAK};

// The medical addon only comes with EFAK itself. Without it its settings would do nothing.
GVAR(hasMedical) = isClass (configFile >> "CfgPatches" >> "efak_medical");

// ----- 0) Quick setup & debug -----

// Sets many of the settings below at once, see fnc_applyPreset. It goes back to "Choose" once
// applied, so its own value never means anything at mission start. In the first section of the
// menu, with the debug setting, above everything it changes.
[
    QGVAR(preset),
    "LIST",
    [LLSTRING(Setting_Preset), LLSTRING(Setting_Preset_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_Top)],
    [
        [PRESET_NONE, PRESET_SANDBOX, PRESET_NORMAL, PRESET_HARDCORE, PRESET_HARDCORE_PLUS, PRESET_FIXED],
        [
            LLSTRING(Preset_None), LLSTRING(Preset_Sandbox), LLSTRING(Preset_Normal),
            LLSTRING(Preset_Hardcore), LLSTRING(Preset_HardcorePlus), LLSTRING(Preset_Fixed)
        ],
        0
    ],
    1,
    {
        params ["_value"];

        if (_value == PRESET_NONE) exitWith {};

        // Out of the settings menu's own saving first. The editor has no frame loop to wait for.
        switch (true) do {
            case (is3DEN): {
                [_value] call FUNC(applyPreset);
            };
            case (isServer): {
                [FUNC(applyPreset), [_value]] call CBA_fnc_execNextFrame;
            };
            // The admin who picked it, on a dedicated server: the menu opens again once the server
            // has sent the new values, so they are what it shows.
            case (hasInterface && {serverCommandAvailable "#kick"}): {
                [1.5] call FUNC(reopenSettings);
            };
        };
    }
] call CBA_fnc_addSetting;

[
    QGVAR(debugContents),
    "CHECKBOX",
    [LLSTRING(Setting_DebugContents), LLSTRING(Setting_DebugContents_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_Top)],
    false,
    1,
    {
        if (GVAR(debugPFH) != -1) then {
            [GVAR(debugPFH)] call CBA_fnc_removePerFrameHandler;
            GVAR(debugPFH) = -1;
        };

        if (GVAR(debugContents) && {hasInterface}) then {
            GVAR(debugPFH) = [{call FUNC(debugContents)}, EFAK_DEBUG_INTERVAL, []] call CBA_fnc_addPerFrameHandler;
        };
    }
] call CBA_fnc_addSetting;

// ----- 1) General -----

[
    QGVAR(allowNesting),
    "CHECKBOX",
    [LLSTRING(Setting_AllowNesting), LLSTRING(Setting_AllowNesting_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(interactWithOthers),
    "CHECKBOX",
    [LLSTRING(Setting_InteractWithOthers), LLSTRING(Setting_InteractWithOthers_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(interactWithAwake),
    "CHECKBOX",
    [LLSTRING(Setting_InteractWithAwake), LLSTRING(Setting_InteractWithAwake_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(doubleClickOpen),
    "CHECKBOX",
    [LLSTRING(Setting_DoubleClickOpen), LLSTRING(Setting_DoubleClickOpen_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
    true,
    0
] call CBA_fnc_addSetting;

// The arsenal's and the medical addon's general settings are registered here with the rest, so the
// menu keeps like with like. CBA runs a setting's script the moment it is added, before those addons
// have compiled their functions; the arsenal applies its own value once it has (its preInit).
[
    "efak_arsenal_ownCategory",
    "CHECKBOX",
    [LELSTRING(arsenal,Setting_OwnCategory), LELSTRING(arsenal,Setting_OwnCategory_Desc)],
    [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
    true,
    1,
    {
        if (!isNil "efak_arsenal_fnc_applyCategorySetting") then {
            call efak_arsenal_fnc_applyCategorySetting;
        };
    }
] call CBA_fnc_addSetting;

if (GVAR(hasMedical)) then {
    // Each player's own: whether the medical menu marks where the next item comes from.
    [
        "efak_medical_markNextSource",
        "CHECKBOX",
        [LELSTRING(medical,Setting_MarkNextSource), LELSTRING(medical,Setting_MarkNextSource_Desc)],
        [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
        true,
        0
    ] call CBA_fnc_addSetting;

    [
        "efak_medical_useOrder",
        "LIST",
        [LELSTRING(medical,Setting_UseOrder), LELSTRING(medical,Setting_UseOrder_Desc)],
        [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
        [
            [0, 1, 2],
            [LELSTRING(medical,Setting_UseOrder_Inventory), LELSTRING(medical,Setting_UseOrder_Kits), LELSTRING(medical,Setting_UseOrder_Ground)],
            0
        ],
        1
    ] call CBA_fnc_addSetting;

    [
        "efak_medical_kitOwnerOrder",
        "LIST",
        [LELSTRING(medical,Setting_KitOwnerOrder), LELSTRING(medical,Setting_KitOwnerOrder_Desc)],
        [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
        [
            [0, 1, 2],
            [LELSTRING(medical,Setting_KitOwnerOrder_Ace), LELSTRING(medical,Setting_KitOwnerOrder_Medic), LELSTRING(medical,Setting_KitOwnerOrder_Patient)],
            0
        ],
        1
    ] call CBA_fnc_addSetting;

    [
        "efak_medical_kitSizeOrder",
        "LIST",
        [LELSTRING(medical,Setting_KitSizeOrder), LELSTRING(medical,Setting_KitSizeOrder_Desc)],
        [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
        [[0, 1], [LELSTRING(medical,Setting_KitSizeOrder_Smallest), LELSTRING(medical,Setting_KitSizeOrder_Biggest)], 0],
        1
    ] call CBA_fnc_addSetting;

    // Each player's own: which kit their drop key puts down first.
    [
        "efak_medical_dropOrder",
        "LIST",
        [LELSTRING(medical,Setting_DropOrder), LELSTRING(medical,Setting_DropOrder_Desc)],
        [GVAR(settingsCategory), LLSTRING(SubCategory_General)],
        [[0, 1], [LELSTRING(medical,Setting_DropOrder_Biggest), LELSTRING(medical,Setting_DropOrder_Smallest)], 0],
        0
    ] call CBA_fnc_addSetting;
};

// ---------------------------------------------------------------------------
// Per kit settings, generated from the config registry - like the general ones, like with like:
// numbers, then switches, then lists, then text boxes.
// ---------------------------------------------------------------------------

{
    private _kit = GVAR(kits) get (toLowerANSI _x);
    _kit params ["_kitId", "", "", "", "_capacity", "", "_defaults", "_name"];

    // Numbered so the CBA menu, which sorts subcategories by name, keeps them in registry order
    // right after "1) General" - or in a category of their own, for containers of another mod.
    private _category = [_x] call FUNC(getKitCategory);

    // Numbers

    [
        format [QGVAR(kit_%1_capacity), _kitId],
        "SLIDER",
        [LLSTRING(Setting_Capacity), format ["%1

%2", LLSTRING(Setting_Capacity_Desc), call FUNC(capacityHint)]],
        _category,
        [1, 2000, _capacity, 0],
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_weight), _kitId],
        "SLIDER",
        [LLSTRING(Setting_KitWeight), LLSTRING(Setting_KitWeight_Desc)],
        _category,
        [0, 2, 0.5, 0, true],
        1,
        {call FUNC(queueVirtualLoad)}
    ] call CBA_fnc_addSetting;

    if (GVAR(hasMedical)) then {
        // 3 m for the bags (MFAK, MFAK+), what a medic sets down next to a casualty; off for the rest.
        [
            format ["efak_medical_kit_%1_nearbyRange", _kitId],
            "SLIDER",
            [LELSTRING(medical,Setting_NearbyRange), LELSTRING(medical,Setting_NearbyRange_Desc)],
            _category,
            [0, 15, [0, 3] select ((_kit select KIT_TREATMENTS) && {getNumber (configFile >> "EFAK_Kits" >> _kitId >> "bag") > 0}), 0],
            1
        ] call CBA_fnc_addSetting;
    };

    // Switches

    // Every kit of this type comes with the defaults, whatever a loadout says it held.
    [
        format [QGVAR(kit_%1_forceContents), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_ForceContents), LLSTRING(Setting_ForceContents_Desc)],
        _category,
        false,
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_limitToDefaults), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_LimitToDefaults), LLSTRING(Setting_LimitToDefaults_Desc)],
        _category,
        false,
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_packing), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_EnablePacking), LLSTRING(Setting_EnablePacking_Desc)],
        _category,
        true,
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_removeWhenEmpty), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_RemoveWhenEmpty), LLSTRING(Setting_RemoveWhenEmpty_Desc)],
        _category,
        false,
        1
    ] call CBA_fnc_addSetting;

    // A player's own taste - but a mission may force it either way. Off: a full MFAK+ would fill the
    // screen with one entry per item.
    [
        format [QGVAR(kit_%1_itemActions), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_ItemActions), LLSTRING(Setting_ItemActions_Desc)],
        _category,
        false,
        0
    ] call CBA_fnc_addSetting;

    if (GVAR(hasMedical)) then {
        // Read by the medical addon, registered here to sit with the other switches of this kit.
        [
            format ["efak_medical_kit_%1_useFrom", _kitId],
            "CHECKBOX",
            [LELSTRING(medical,Setting_UseFromKit), LELSTRING(medical,Setting_UseFromKit_Desc)],
            _category,
            _kit select KIT_TREATMENTS,
            1
        ] call CBA_fnc_addSetting;
    };

    // Lists

    [
        format [QGVAR(kit_%1_arsenalEditing), _kitId],
        "LIST",
        [LLSTRING(Setting_ArsenalEditing), LLSTRING(Setting_ArsenalEditing_Desc)],
        _category,
        [
            [EDIT_ALL, EDIT_REMOVE, EDIT_NOTHING],
            [LLSTRING(Setting_ArsenalEditing_All), LLSTRING(Setting_ArsenalEditing_Remove), LLSTRING(Setting_ArsenalEditing_Nothing)],
            0
        ],
        1
    ] call CBA_fnc_addSetting;

    // Where items taken out of this kit go. Left to the player by default; a mission can decide it
    // for them - a medic bag emptied into the backpack only.
    [
        format [QGVAR(kit_%1_unloadContainer), _kitId],
        "LIST",
        [LLSTRING(Setting_UnloadContainer), LLSTRING(Setting_UnloadContainer_Desc)],
        _category,
        [
            [CONTAINER_PLAYER, CONTAINER_AUTO, CONTAINER_UNIFORM, CONTAINER_VEST, CONTAINER_BACKPACK],
            [LLSTRING(Container_Player), LLSTRING(Container_Auto), LLSTRING(Container_Uniform), LLSTRING(Container_Vest), LLSTRING(Container_Backpack)],
            0
        ],
        0
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_itemFilter), _kitId],
        "LIST",
        [LLSTRING(Setting_ItemFilter), LLSTRING(Setting_ItemFilter_Desc)],
        _category,
        [
            [FILTER_ALL, FILTER_MEDICAL, FILTER_LIST],
            [LLSTRING(Setting_ItemFilter_All), LLSTRING(Setting_ItemFilter_Medical), LLSTRING(Setting_ItemFilter_List)],
            [FILTER_ALL, FILTER_MEDICAL, FILTER_LIST] find (_kit select KIT_FILTER)
        ],
        1,
        {call FUNC(settingsChanged)}
    ] call CBA_fnc_addSetting;

    // Text boxes

    // Filled in with the type's own name; whatever else it says is the name of every kit of the type
    // that has none of its own.
    [
        format [QGVAR(kit_%1_name), _kitId],
        "EDITBOX",
        [LLSTRING(Setting_TypeName), LLSTRING(Setting_TypeName_Desc)],
        _category,
        getText (configFile >> "CfgWeapons" >> _x >> "displayName"),
        1,
        {call FUNC(updateTypeNames)}
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_defaultContents), _kitId],
        "EDITBOX",
        [LLSTRING(Setting_DefaultContents), LLSTRING(Setting_DefaultContents_Desc)],
        _category,
        _defaults,
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_whitelist), _kitId],
        "EDITBOX",
        [LLSTRING(Setting_Whitelist), LLSTRING(Setting_Whitelist_Desc)],
        _category,
        _kit select KIT_WHITELIST,
        1,
        {call FUNC(settingsChanged)}
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_blacklist), _kitId],
        "EDITBOX",
        [LLSTRING(Setting_Blacklist), LLSTRING(Setting_Blacklist_Desc)],
        _category,
        "",
        1,
        {call FUNC(settingsChanged)}
    ] call CBA_fnc_addSetting;
} forEach GVAR(kitList);

// The Eden editor never runs postInit, and the default contents are checked against the rules as
// early as the kits tab of its arsenal.
call FUNC(settingsChanged);

ADDON = true;
