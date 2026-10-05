#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * The kits a unit's treatments may reach into: the ones it carries and, for the player, the ones
 * lying on the ground close by - a medic's bag set down next to the casualty.
 *
 * How far a kit may lie is set per kit type (efak_medical_kit_<id>_nearbyRange, 0 = never from the
 * ground). Only for the player: the medic and the patient are both asked for their kits, and a bag
 * next to both of them must count once - the medic is the player on the machine the treatment runs
 * on.
 *
 * The holder each of those kits lies in is remembered for takeFromKit, which has to know where an
 * emptied kit disappears from.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Which kits: KITS_ALL, KITS_CARRIED or KITS_GROUND <NUMBER> (default: KITS_ALL)
 *
 * Return Value:
 * Kit instance classes, the carried ones first <ARRAY>
 *
 * Example:
 * [player, 2] call efak_medical_fnc_usableKits;
 *
 * Public: No
 */

params ["_unit", ["_mode", KITS_ALL]];

private _kits = [[_unit] call EFUNC(core,getCarriedKits), []] select (_mode == KITS_GROUND);

if (_mode == KITS_CARRIED || {_unit isNotEqualTo ACE_player}) exitWith {_kits};

// The furthest any kit type may lie; each kit is held to its own type's range below.
private _ranges = createHashMap;
private _furthest = 0;

{
    private _id = (EGVAR(core,kits) get (toLowerANSI _x)) select KIT_ID;
    private _range = missionNamespace getVariable [format [QGVAR(kit_%1_nearbyRange), _id], 0];

    _ranges set [_id, _range];
    _furthest = _furthest max _range;
} forEach EGVAR(core,kitList);

if (_furthest <= 0) exitWith {_kits};

{
    private _holder = _x;
    private _distance = _unit distance _holder;

    {
        private _key = toLowerANSI _x;

        if (_key in EGVAR(core,prototypeOf) && {!(_key in EGVAR(core,needsConversion))}) then {
            private _id = ([_x] call EFUNC(core,getKitData)) select KIT_ID;

            if (_distance <= (_ranges getOrDefault [_id, 0])) then {
                _kits pushBackUnique _x;
                GVAR(nearbyHolders) set [_key, _holder];
            };
        };
    } forEach (itemCargo _holder);
} forEach (nearestObjects [_unit, ["WeaponHolder", "WeaponHolderSimulated"], _furthest]);

_kits
