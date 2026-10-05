#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns the display name of any item, falling back to the classname.
 *
 * Arguments:
 * 0: Class <STRING>
 *
 * Return Value:
 * Display name <STRING>
 *
 * Example:
 * ["ACE_fieldDressing"] call efak_core_fnc_getItemName;
 *
 * Public: Yes
 */

params ["_class"];

// A kit with a name a player gave it goes by that name (fnc_setKitLabel). Never cached: it can change.
private _label = GVAR(labels) getOrDefault [toLowerANSI _class, ""];

if (_label isNotEqualTo "") exitWith {_label};

// ...and every kit of a type the mission renamed goes by that name.
private _typeName = [_class] call FUNC(getTypeName);

if (_typeName isNotEqualTo "") exitWith {_typeName};

// Every list redraw asks for the name of every row, and the config lookup walks several classes.
GVAR(nameCache) getOrDefaultCall [toLowerANSI _class, {
    private _config = _class call CBA_fnc_getItemConfig;

    if (isNull _config) exitWith {_class};

    private _name = getText (_config >> "displayName");

    [_name, _class] select (_name isEqualTo "")
}, true]
