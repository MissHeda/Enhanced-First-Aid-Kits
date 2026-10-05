#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The items of the container ACE Arsenal has open on its left: uniform, vest or backpack.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Item classes, nil when no container is open <ARRAY>
 *
 * Example:
 * [] call efak_arsenal_fnc_getContainerItems;
 *
 * Public: No
 */

private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];

if (isNull _center) exitWith {nil};

switch (missionNamespace getVariable [QACEGVAR(arsenal,currentLeftPanel), -1]) do {
    case IDC_ACE_UNIFORM: {uniformItems _center};
    case IDC_ACE_VEST: {vestItems _center};
    case IDC_ACE_BACKPACK: {backpackItems _center};
    default {nil};
}
