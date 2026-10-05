#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * ace_arsenal_cargoChanged handler: "+" or "-" on a row of ACE's container list.
 *
 * ACE only knows a kit by its type and takes out items of exactly that class. The kits in the
 * container are instances of it, so "-" took nothing. Whatever ACE could not take out comes out
 * here: as many kits of that type as "-" asked for (five with Shift). A kit taken out in the
 * arsenal is gone, so its id goes back to the pool with what it held.
 *
 * Arguments:
 * 0: ACE Arsenal display <DISPLAY>
 * 1: Item class of the row <STRING>
 * 2: 1 for "+", -1 for "-" - or 0, which the left arrow key sends <NUMBER>
 * 3: Shift held <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "efak_IFAK", -1, false] call efak_arsenal_fnc_onCargoChanged;
 *
 * Public: No
 */

params ["_display", "_item", "_addOrRemove", ["_shift", false]];

private _key = toLowerANSI _item;

if !(_key in EGVAR(core,prototypeOf)) exitWith {};

// The row of a kit with a name is that very kit: ACE took it out itself. It is gone, and its id goes
// back to the pool with what it held.
if !(_key in EGVAR(core,needsConversion)) exitWith {
    private _items = [] call FUNC(getContainerItems);

    if (_addOrRemove <= 0 && {!isNil "_items"} && {(_items findIf {(toLowerANSI _x) isEqualTo _key}) == -1}) then {
        [_item] call EFUNC(core,freeInstance);
    };

    [_display] call FUNC(recountKitRows);
};

if (_addOrRemove <= 0) then {
    private _items = [] call FUNC(getContainerItems);

    if (isNil "_items") exitWith {};

    // The type's row counts and takes out the kits without a name only - a named one has its own.
    private _fnc_isOfType = {
        (toLowerANSI (EGVAR(core,prototypeOf) getOrDefault [toLowerANSI _this, ""])) isEqualTo _key &&
        {([_this] call EFUNC(core,getKitLabel)) isEqualTo ""}
    };

    private _now = {_x call _fnc_isOfType} count _items;
    private _takenByAce = (GVAR(kitRowCounts) getOrDefault [_key, _now]) - _now;
    private _missing = ([1, 5] select _shift) - _takenByAce;

    if (_missing < 1) exitWith {};

    private _center = missionNamespace getVariable [QACEGVAR(arsenal,center), objNull];
    private _panel = missionNamespace getVariable [QACEGVAR(arsenal,currentLeftPanel), -1];

    {
        if (_missing < 1) exitWith {};

        if (_x call _fnc_isOfType && {!((toLowerANSI _x) in EGVAR(core,needsConversion))}) then {
            switch (_panel) do {
                case IDC_ACE_UNIFORM: {_center removeItemFromUniform _x};
                case IDC_ACE_VEST: {_center removeItemFromVest _x};
                case IDC_ACE_BACKPACK: {_center removeItemFromBackpack _x};
            };

            [_x] call EFUNC(core,freeInstance);
            _missing = _missing - 1;
        };
    } forEach _items;

    // ACE keeps its own copy of the container's contents and the load bar, see its buttonCargo.
    private _slot = [IDC_ACE_UNIFORM, IDC_ACE_VEST, IDC_ACE_BACKPACK] find _panel;
    private _currentItems = missionNamespace getVariable QACEGVAR(arsenal,currentItems);

    if (!isNil "_currentItems") then {
        _currentItems set [ACE_CURRENT_UNIFORM_ITEMS + _slot, ((getUnitLoadout _center) select (ACE_LOADOUT_UNIFORM + _slot)) param [1, []]];
    };

    (_display displayCtrl IDC_ACE_LOAD_BAR) progressSetPosition ([loadUniform _center, loadVest _center, loadBackpack _center] select _slot);
};

[_display] call FUNC(recountKitRows);
