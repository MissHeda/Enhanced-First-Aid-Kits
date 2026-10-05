#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Gives one kit a name of its own, on every machine. An empty name takes it away again.
 *
 * Kept to one line of plain text: trimmed, at most KIT_LABEL_MAX characters, without the characters
 * the game's structured text and the stringtables read as markup.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Name <STRING>
 *
 * Return Value:
 * The name as it was stored <STRING>
 *
 * Example:
 * ["eup_UtilityPouch_7", "Ammo spare"] call efak_core_fnc_setKitLabel;
 *
 * Public: Yes
 */

params [["_kitClass", "", [""]], ["_label", "", [""]]];

private _key = toLowerANSI _kitClass;

// Only real kits: a prototype has no identity yet, and a name on it would go to every kit of the type.
if (!(_key in GVAR(prototypeOf)) || {_key in GVAR(needsConversion)}) exitWith {""};

_label = (trim ((_label splitString ("<>&""$" + toString [10, 13, 9])) joinString "")) select [0, KIT_LABEL_MAX];

if (_label isEqualTo (GVAR(labels) getOrDefault [_key, ""])) exitWith {_label};

[QGVAR(labelChanged), [_kitClass, _label]] call CBA_fnc_globalEvent;

_label
