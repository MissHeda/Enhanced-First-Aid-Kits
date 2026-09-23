#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * How full the left panel's source is: the player's clothing, or the crate.
 *
 * Both numbers are summed per container - (load _container) * (maxLoad _container). Neither of
 * the unit level commands works here: loadAbs counts the weapon, the helmet and the bags
 * themselves, which take up no container space, and load is relative to a wider base than the
 * three containers, so scaling it by their capacity comes out short.
 *
 * Arguments:
 * 0: Source <NUMBER> (default: whichever tab is open)
 *
 * Return Value:
 * 0: Load <NUMBER>
 * 1: What the source holds in total <NUMBER>
 *
 * Example:
 * call efak_gui_fnc_getSourceLoad;
 *
 * Public: No
 */

params [["_source", GVAR(leftSource)]];

if (_source isEqualTo SOURCE_CRATE) exitWith {
    private _crate = GVAR(crate);

    if (isNull _crate) exitWith {[0, 0]};

    private _maxLoad = maxLoad _crate;

    [(load _crate) * _maxLoad, _maxLoad]
};

private _maxLoad = 0;
private _load = 0;

{
    if (isNull _x) then {continue};

    private _max = maxLoad _x;

    _maxLoad = _maxLoad + _max;
    _load = _load + (load _x) * _max;
} forEach [uniformContainer ACE_player, vestContainer ACE_player, backpackContainer ACE_player];

[_load, _maxLoad]
