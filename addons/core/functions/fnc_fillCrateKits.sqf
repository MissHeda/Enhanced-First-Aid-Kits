#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives the kits of one type lying in a crate or vehicle the contents set in its Eden attribute.
 * Every prototype of that type in the cargo is swapped for a real kit instance filled that way, so
 * whoever takes one out gets those contents instead of the defaults - exactly as written, the
 * packing rules do not apply to them.
 *
 * Arguments:
 * 0: Crate or vehicle <OBJECT>
 * 1: Eden property name, "efak_core_crate_<kit prototype>" <STRING>
 * 2: Contents as in the CBA default contents setting <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorObject, "efak_core_crate_efak_IFAK", "[['ACE_fieldDressing',6]]"] call efak_core_fnc_fillCrateKits;
 *
 * Public: No
 */

params ["_crate", "_property", "_value"];

if (!isServer || {isNull _crate}) exitWith {};

private _prototype = _property select [count QGVAR(crate_)];
private _contents = [_value] call FUNC(parseContents);

// Something that does not read as contents gives the defaults rather than empty kits.
if (_contents isEqualTo [] && {_value != "[]"}) then {_contents = -1};

// The attribute is applied while the mission is still being built; the instance pool and the
// contents table are ready one frame later.
[{
    params ["_crate", "_prototype", "_contents"];

    private _count = {_x == _prototype} count (itemCargo _crate);

    if (_count == 0) exitWith {};

    _crate addItemCargoGlobal [_prototype, -_count];

    for "_i" from 1 to _count do {
        private _instance = [_prototype] call FUNC(allocateInstance);

        if (_instance isEqualTo "") then {
            WARNING_1("Could not allocate an instance for '%1'.",_prototype);
            continue;
        };

        // Exactly what the mission maker wrote, past the packing rules; the field is empty for defaults.
        if (_contents isEqualType []) then {
            [_instance, _contents] call FUNC(setContents);
            [_instance, false] call FUNC(setFollowDefaults);
        } else {
            [_instance, -1] call FUNC(fillNewInstance);
        };
        _crate addItemCargoGlobal [_instance, 1];
    };
}, [_crate, _prototype, _contents]] call CBA_fnc_execNextFrame;
