#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * How many rounds a full magazine of a class holds - the charges of a pill bottle, the units of an
 * oxygen tank. 0 for anything that is not a magazine.
 *
 * A kit keeps a count per class; magazines with more than one round also keep the rounds of every
 * opened one (see fnc_setContents), so an opened bottle comes back out as it went in.
 *
 * Arguments:
 * 0: Item class <STRING>
 *
 * Return Value:
 * Rounds <NUMBER>
 *
 * Example:
 * ["ACE_painkillers"] call efak_core_fnc_getMagazineSize;
 *
 * Public: Yes
 */

params ["_class"];

private _config = configFile >> "CfgMagazines" >> _class;

if !(isClass _config) exitWith {0};

getNumber (_config >> "count")
