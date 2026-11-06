#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Puts the theme (class EFAK_Theme, read by XEH_preInit) on a freshly opened window: every control
 * drawn in EFAK's own accent, soft accent or window colour gets the theme's instead, and
 * the gloss textures are swapped. Run time colours (buttons, bars, menus) read the theme directly.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call efak_gui_fnc_applyTheme;
 *
 * Public: No
 */

disableSerialization;

params ["_display"];

if (!GVAR(themed)) exitWith {};

// EFAK's own colour -> the theme's
private _swap = [
    [[RGBA_ACCENT], S_ACCENT],
    [[RGBA_ACCENT_SOFT], GVAR(themeAccentSoft)],
    [[RGBA_WINDOW], S_WINDOW]
];

private _gloss = [
    [UI_TEX(gloss_pouch_ca), GVAR(themeGlossPouch)],
    [UI_TEX(gloss_contents_ca), GVAR(themeGlossContents)]
];

// The engine hands colours back in single precision, so compare with a little room.
private _fnc_same = {
    params ["_a", "_b"];
    count _a == 4 && {([0, 1, 2, 3] findIf {abs ((_a select _x) - (_b select _x)) > 0.002}) == -1}
};

{
    private _ctrl = _x;
    private _background = ctrlBackgroundColor _ctrl;
    private _text = ctrlTextColor _ctrl;

    {
        _x params ["_own", "_new"];

        if ([_background, _own] call _fnc_same) then {_ctrl ctrlSetBackgroundColor _new};
        if ([_text, _own] call _fnc_same) then {_ctrl ctrlSetTextColor _new};
    } forEach _swap;

    private _texture = toLowerANSI ctrlText _ctrl;

    {
        _x params ["_own", "_new"];

        if (_texture isEqualTo toLowerANSI _own) then {_ctrl ctrlSetText _new};
    } forEach _gloss;
} forEach (allControls _display);
