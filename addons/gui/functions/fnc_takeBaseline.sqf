#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Takes the snapshot every list of the kit window compares itself to.
 *
 * Moves take effect the moment they are made, so the lists alone would not show what the player has
 * done since opening the window. Against this snapshot every row can say "(+3)" or "(-2)", and a row
 * whose items all left stays on its list as "0x (-3)".
 *
 * Taken when the window opens and again when it switches kits.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_gui_fnc_takeBaseline;
 *
 * Public: No
 */

GVAR(baseline) = createHashMap;

{
    private _key = _x;
    private _counts = createHashMap;

    {
        _x params ["_class", "_count"];
        _counts set [toLowerANSI _class, [_class, _count]];
    } forEach ([_key] call FUNC(getEntries));

    GVAR(baseline) set [_key, _counts];
} forEach ["inventory", "crate", "kit", "uniform", "vest", "backpack", "ground"];
