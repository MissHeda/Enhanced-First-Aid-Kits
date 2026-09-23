#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * The weapon holder the kit window puts things on the ground into.
 *
 * One holder for as long as the window is open, so everything put down lands in one pile the ground
 * list can show and take back from - rather than one pile per move. It is only reused while it
 * exists and is still at the player's feet; the engine deletes a holder that is emptied.
 *
 * Arguments:
 * 0: Make one when there is none <BOOL> (default: false)
 *
 * Return Value:
 * Weapon holder <OBJECT>, objNull when there is none and none was made
 *
 * Example:
 * [true] call efak_gui_fnc_getGroundHolder;
 *
 * Public: No
 */

params [["_create", false]];

private _holder = GVAR(groundHolder);

if (!isNull _holder && {_holder distance ACE_player > GROUND_RANGE}) then {
    _holder = objNull;
};

if (isNull _holder && {_create}) then {
    _holder = createVehicle ["GroundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _holder setPosASL (getPosASL ACE_player);

    GVAR(groundHolder) = _holder;
};

_holder
