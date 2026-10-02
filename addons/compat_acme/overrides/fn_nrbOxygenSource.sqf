#include "..\script_component.hpp"
/*
 * Author: hesherson (ACM Extended), Miss Heda
 * ACME_fnc_nrbOxygenSource with an oxygen tank packed in a kit counting as a source - a stand-in until
 * ACM Extended ships hesherson/ACM-Extended#32. ACME's own check looks at worn containers only, so the
 * non-rebreather was refused with the tank in a kit, although useOxygenTankReserve draws from kits.
 *
 * Retires itself: once ACME's own file asks ACME_fnc_itemCount, that file runs, untouched.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Unit whose tank feeds the mask, objNull when there is none <OBJECT>
 *
 * Example:
 * [player, cursorObject] call ACME_fnc_nrbOxygenSource;
 *
 * Public: No
 */

if (isNil QGVAR(nrbOriginal)) then {
    private _path = "\acm_extended\functions\fn_nrbOxygenSource.sqf";
    GVAR(nrbOriginal) = [{}, compile preprocessFileLineNumbers _path] select ((loadFile _path) find "ACME_fnc_itemCount" >= 0);
};
if (GVAR(nrbOriginal) isNotEqualTo {}) exitWith {_this call GVAR(nrbOriginal)};

params ["_medic", "_patient"];

private _source = objNull;

{
    private _unit = _x;
    private _available = false;

    {
        if (((magazinesAmmoCargo _x) findIf {(_x select 0) == "ACM_OxygenTank_425" && {(_x select 1) > 0}}) >= 0) exitWith {_available = true};
    } forEach [uniformContainer _unit, vestContainer _unit, backpackContainer _unit];

    // EFAK: a tank in a kit; useOxygenTankReserve draws from it through efak_medical_fnc_drawCharge
    if (!_available) then {
        _available = ([_unit, "ACM_OxygenTank_425"] call ACME_fnc_itemCount) > 0;
    };

    if (_available) exitWith {_source = _unit};
} forEach ([_medic, _patient] call ACME_fnc_treatmentSupplyOrder);

_source
