// EFAK compat: ACM Extended's own fn_ccApply.sqf, with every
//   <unit> removeItem <item>
// replaced by
//   [<unit>, <item>] call efak_medical_fnc_takeItem
// which takes a loose one first and otherwise one straight out of an EFAK kit. Nothing else changed,
// apart from what EXTRA in the build script lists for this file.
// Generated from ACM Extended by tools/build_acme_overrides.py - regenerate after an ACM Extended update.
// the owner-local inventory edit for the blood cold-chain. the cold-chain ledger is server-authoritative, and
// adding or removing items on a person must run where that person is local, so the server remoteexecs this to the
// owner.
// _this is [_unit, _removeclasses, _addclasses]. the removes run first, freeing room for the adds.
params ["_unit", ["_rem", []], ["_add", []]];
if (isNull _unit || {!local _unit}) exitWith {};
{ [_unit, _x] call efak_medical_fnc_takeItem; } forEach _rem;
{
    if (_unit canAdd _x) then { _unit addItem _x; }
    else {
        // never silently lose an item: drop it at the feet of the unit.
        private _wh = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0.5, "CAN_COLLIDE"];
        _wh addItemCargoGlobal [_x, 1];
    };
} forEach _add;
if (("ACME_SpoiledBlood" in _add) && {_unit isEqualTo ACE_player}) then {
    [format ["%1 blood bag(s) lost the cold chain and spoiled.", {_x == "ACME_SpoiledBlood"} count _add], 3] call ace_common_fnc_displayTextStructured;
};
