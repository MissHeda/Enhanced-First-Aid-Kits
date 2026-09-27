#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Returns the kits the tab is editing: every instance of the selected kit type. A greyed "being
 * prepared" row has nothing to edit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Kit instance classes <ARRAY>
 *
 * Example:
 * call efak_arsenal_fnc_getSelectedKits;
 *
 * Public: No
 */

if (GVAR(selectedPreparing) || {GVAR(selected) isEqualTo ""}) exitWith {[]};

private _index = GVAR(groups) findIf {(_x select 0) == GVAR(selected)};

if (_index < 0) exitWith {[]};

(GVAR(groups) select _index) select 1
