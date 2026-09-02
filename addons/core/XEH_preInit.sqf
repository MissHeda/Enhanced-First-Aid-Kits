#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Runtime state. All of these are rebuilt from scratch every mission.
GVAR(contents) = createHashMap;             // lowercase instance class -> [[item, count], ...]
GVAR(usedInstances) = createHashMap;        // server only, lowercase instance class -> true
GVAR(nextInstance) = createHashMap;         // server only, lowercase prototype -> next id
GVAR(pendingConversions) = createHashMap;   // client only, lowercase class -> outstanding requests
GVAR(massCache) = createHashMap;
GVAR(whitelistLookup) = createHashMap;
GVAR(blacklistLookup) = createHashMap;

call FUNC(initKits);

// ---------------------------------------------------------------------------
// General settings
// ---------------------------------------------------------------------------

[
    QGVAR(enablePacking),
    "CHECKBOX",
    [LLSTRING(Setting_EnablePacking), LLSTRING(Setting_EnablePacking_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(allowNesting),
    "CHECKBOX",
    [LLSTRING(Setting_AllowNesting), LLSTRING(Setting_AllowNesting_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(itemFilter),
    "LIST",
    [LLSTRING(Setting_ItemFilter), LLSTRING(Setting_ItemFilter_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    [
        [FILTER_ALL, FILTER_MEDICAL, FILTER_LIST],
        [LLSTRING(Setting_ItemFilter_All), LLSTRING(Setting_ItemFilter_Medical), LLSTRING(Setting_ItemFilter_List)],
        FILTER_ALL
    ],
    1,
    {call FUNC(settingsChanged)}
] call CBA_fnc_addSetting;

[
    QGVAR(whitelist),
    "EDITBOX",
    [LLSTRING(Setting_Whitelist), LLSTRING(Setting_Whitelist_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    "",
    1,
    {call FUNC(settingsChanged)}
] call CBA_fnc_addSetting;

[
    QGVAR(blacklist),
    "EDITBOX",
    [LLSTRING(Setting_Blacklist), LLSTRING(Setting_Blacklist_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    "",
    1,
    {call FUNC(settingsChanged)}
] call CBA_fnc_addSetting;

[
    QGVAR(unpackTime),
    "SLIDER",
    [LLSTRING(Setting_UnpackTime), LLSTRING(Setting_UnpackTime_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    [0, 30, 0, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(interactWithOthers),
    "CHECKBOX",
    [LLSTRING(Setting_InteractWithOthers), LLSTRING(Setting_InteractWithOthers_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(interactWithAwake),
    "CHECKBOX",
    [LLSTRING(Setting_InteractWithAwake), LLSTRING(Setting_InteractWithAwake_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(headerColor),
    "COLOR",
    [LLSTRING(Setting_HeaderColor), LLSTRING(Setting_HeaderColor_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    [1, 0.8, 0.3],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(itemColor),
    "COLOR",
    [LLSTRING(Setting_ItemColor), LLSTRING(Setting_ItemColor_Desc)],
    [CBA_SETTINGS_EFAK, LLSTRING(SubCategory_General)],
    [0.67, 0.84, 0.9],
    0
] call CBA_fnc_addSetting;

// ---------------------------------------------------------------------------
// Per kit settings, generated from the config registry
// ---------------------------------------------------------------------------

{
    (GVAR(kits) get (toLowerANSI _x)) params ["_kitId", "", "", "", "_capacity", "", "_defaults", "_name"];

    private _category = [CBA_SETTINGS_EFAK, _name];

    [
        format [QGVAR(kit_%1_displayName), _kitId],
        "EDITBOX",
        [LLSTRING(Setting_KitName), LLSTRING(Setting_KitName_Desc)],
        _category,
        "",
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_capacity), _kitId],
        "SLIDER",
        [LLSTRING(Setting_Capacity), LLSTRING(Setting_Capacity_Desc)],
        _category,
        [1, 2000, _capacity, 0],
        1
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
        format [QGVAR(kit_%1_container), _kitId],
        "LIST",
        [LLSTRING(Setting_Container), LLSTRING(Setting_Container_Desc)],
        _category,
        [
            [CONTAINER_AUTO, CONTAINER_UNIFORM, CONTAINER_VEST, CONTAINER_BACKPACK],
            [LLSTRING(Container_Auto), LLSTRING(Container_Uniform), LLSTRING(Container_Vest), LLSTRING(Container_Backpack)],
            CONTAINER_AUTO
        ],
        1
    ] call CBA_fnc_addSetting;

    [
        format [QGVAR(kit_%1_removeWhenEmpty), _kitId],
        "CHECKBOX",
        [LLSTRING(Setting_RemoveWhenEmpty), LLSTRING(Setting_RemoveWhenEmpty_Desc)],
        _category,
        true,
        1
    ] call CBA_fnc_addSetting;
} forEach GVAR(kitList);

ADDON = true;
