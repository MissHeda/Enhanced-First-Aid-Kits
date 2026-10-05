#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads the markers a saved contents tree carries besides its items (fnc_getContentsTree): the
 * kit's name, and whether the kit follows the default contents.
 *
 * They are entries like any other - [KIT_MARK_LABEL, "Ammo spare"], [KIT_MARK_DEFAULT, 1] - so they
 * travel with the tree through loadouts, respawns and the restore queue without anything there
 * having to know. Whatever reads the items passes over them: no item has such a class.
 *
 * Arguments:
 * 0: Contents tree <ARRAY>
 *
 * Return Value:
 * 0: Name, "" for none <STRING>
 * 1: Follows the default contents <BOOL>
 *
 * Example:
 * [[["ACE_morphine", 2], ["#label", "Spare"]]] call efak_core_fnc_getTreeLabel;
 *
 * Public: No
 */

params [["_tree", [], [[]]]];

private _label = "";
private _default = false;

{
    if !(_x isEqualType [] && {(_x param [0, ""]) isEqualType ""}) then {continue};

    switch (_x select 0) do {
        case KIT_MARK_LABEL: {
            private _value = _x param [1, ""];
            if (_value isEqualType "") then {_label = _value};
        };
        case KIT_MARK_DEFAULT: {_default = true};
    };
} forEach _tree;

[_label, _default]
