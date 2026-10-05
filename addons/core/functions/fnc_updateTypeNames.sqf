#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Reads the "Name" setting of every kit type into GVAR(typeNames). A type keeps its own name unless
 * the setting says something else - it is filled in with that name, so only a changed one counts.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call efak_core_fnc_updateTypeNames;
 *
 * Public: No
 */

private _names = createHashMap;

{
    private _id = (GVAR(kits) get (toLowerANSI _x)) select KIT_ID;
    private _name = trim (missionNamespace getVariable [format [QGVAR(kit_%1_name), _id], ""]);
    private _own = getText (configFile >> "CfgWeapons" >> _x >> "displayName");

    if (_name isNotEqualTo "" && {_name isNotEqualTo _own}) then {
        _names set [toLowerANSI _x, _name];
    };
} forEach GVAR(kitList);

GVAR(typeNames) = _names;
GVAR(contentsStamp) = GVAR(contentsStamp) + 1;
