#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives a freshly allocated kit instance its first contents.
 *
 * Contents a loadout brought along are checked against the rules first (fnc_restoreContents);
 * anything else - -1, or a kit saved as "default" - gets the default contents, and so does every
 * kit of a type whose contents the mission forces. Only a kit saved as "default" goes on following
 * the defaults: a new kit starts with them but keeps whatever it is repacked with, so a saved
 * loadout never quietly swaps a kit the player filled by hand for the defaults.
 *
 * Server only, or the Eden editor, which has nobody else to ask.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Contents tree <ARRAY>, LOADOUT_KIT_DEFAULT or -1 for the defaults
 *
 * Return Value:
 * None
 *
 * Example:
 * ["efak_IFAK_7", -1] call efak_core_fnc_fillNewInstance;
 *
 * Public: No
 */

params ["_instance", ["_contents", -1]];

// A saved kit that followed the defaults and had a name comes as a tree of markers only.
private _label = "";

if (_contents isEqualType []) then {
    ([_contents] call FUNC(getTreeLabel)) params ["_treeLabel", "_followsDefaults"];

    _label = _treeLabel;

    if (_followsDefaults) then {_contents = LOADOUT_KIT_DEFAULT};
};

private _restore = _contents isEqualType [] && {!([_instance] call FUNC(isContentsForced))};

if (_restore) then {
    [_instance, _contents] call FUNC(restoreContents);
} else {
    [_instance, [_instance] call FUNC(getDefaultContents)] call FUNC(setContents);
};

[_instance, _contents isEqualTo LOADOUT_KIT_DEFAULT] call FUNC(setFollowDefaults);

// restoreContents names it itself, from the same tree.
if (!_restore && {_label isNotEqualTo ""}) then {
    [_instance, _label] call FUNC(setKitLabel);
};
