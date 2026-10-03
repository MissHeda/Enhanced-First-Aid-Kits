// ACM ACM_circulation_fnc_TransfusionMenu_SwitchTargetInventory, kit-aware for EFAK. Not a copy: ACM's own
// function runs first and fills the list from the loose bags, then the bags packed in the kits of the
// selected unit are added (or counted in) - the same rows, data and tooltip ACM writes.

// ACM Extended's transfusion menu already asks EFAK through its own item hooks: its own function only.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};

private _original = missionNamespace getVariable "efak_compat_acm_original_TransfusionMenu_SwitchTargetInventory";
if (isNil "_original") then {
    _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_TransfusionMenu_SwitchTargetInventory.sqf";
    missionNamespace setVariable ["efak_compat_acm_original_TransfusionMenu_SwitchTargetInventory", _original];
};

if (!efak_compat_acm_useCopies) exitWith {_this call _original};

private _fluids = +(missionNamespace getVariable ["ACM_circulation_Fluids_Array", []]);
private _fluidsData = +(missionNamespace getVariable ["ACM_circulation_Fluids_Array_Data", []]);

// ACM leaves the list as it was when the player carries no bag loose at all.
private _playerItems = [ACE_player, 0] call ace_common_fnc_uniqueItems;
private _hadLoose = (_fluids findIf {_x in _playerItems}) > -1;

_this call _original;

private _selection = missionNamespace getVariable ["ACM_circulation_TransfusionMenu_Selected_Inventory", 0];

// The vehicle's cargo is no kit.
if (_selection == 2) exitWith {};

private _target = [ACE_player, missionNamespace getVariable ["ACM_circulation_TransfusionMenu_Target", objNull]] select _selection;

if (isNull _target) exitWith {};

private _display = uiNamespace getVariable ["ACM_circulation_TransfusionMenu_DLG", displayNull];
private _ctrlInventoryPanel = _display displayCtrl 86005; // IDC_TRANSFUSIONMENU_RIGHTLISTPANEL

if (isNull _ctrlInventoryPanel) exitWith {};

private _cleared = _hadLoose;

{
    private _classname = _x;
    private _inKits = [_target, _classname] call efak_medical_fnc_countInKits;

    if (_inKits < 1) then {continue};

    private _config = configFile >> "CfgWeapons" >> _classname;

    // Fresh blood bags are named after their donor; ACM keeps those to itself.
    if (getNumber (_config >> "uniqueBag") > 0) then {continue};

    if (!_cleared) then {
        lbClear _ctrlInventoryPanel;
        _cleared = true;
    };

    private _row = -1;

    for "_i" from 0 to ((lbSize _ctrlInventoryPanel) - 1) do {
        if ((((_ctrlInventoryPanel lbData _i) splitString "|") param [0, ""]) == _classname) exitWith {_row = _i};
    };

    if (_row < 0) then {
        _row = _ctrlInventoryPanel lbAdd ([getText (_config >> "displayName"), getText (_config >> "shortName")] select (isText (_config >> "shortName")));
        _ctrlInventoryPanel lbSetPicture [_row, getText (_config >> "picture")];
        _ctrlInventoryPanel lbSetData [_row, format ["%1|%2", _classname, _fluidsData param [_forEachIndex, ""]]];
    };

    private _count = ([_target, _classname] call ace_common_fnc_getCountOfItem) + _inKits;
    _ctrlInventoryPanel lbSetTooltip [_row, format [localize "STR_ACM_circulation_Common_Available", _count]];
} forEach _fluids;
