#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * A text of the kits tab that names what the kits are - "first aid kits" - from EFAK_Arsenal, where
 * a mod that adds containers of its own (pouches) can word it for both.
 *
 * Arguments:
 * 0: Entry of EFAK_Arsenal <STRING>
 *
 * Return Value:
 * Text, localised <STRING>
 *
 * Example:
 * ["rowNoKits"] call efak_arsenal_fnc_getText;
 *
 * Public: No
 */

params ["_entry"];

private _text = getText (configFile >> "EFAK_Arsenal" >> _entry);

if ((_text select [0, 1]) == "$") then {localize (_text select [1])} else {_text}
