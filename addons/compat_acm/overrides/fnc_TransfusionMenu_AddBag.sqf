// ACM ACM_circulation_fnc_TransfusionMenu_AddBag, kit-aware for EFAK. Not a copy: when the chosen bag is not
// loose on the selected unit, one comes out of that unit's kits first, then ACM's own function hangs it
// and takes it with removeItem as always.

// ACM Extended's transfusion menu already asks EFAK through its own item hooks: its own function only.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};

private _original = missionNamespace getVariable "efak_compat_acm_original_TransfusionMenu_AddBag";
if (isNil "_original") then {
    _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_TransfusionMenu_AddBag.sqf";
    missionNamespace setVariable ["efak_compat_acm_original_TransfusionMenu_AddBag", _original];
};

if (efak_compat_acm_useCopies) then {
    private _selection = missionNamespace getVariable ["ACM_circulation_TransfusionMenu_Selected_Inventory", 0];
    private _display = uiNamespace getVariable ["ACM_circulation_TransfusionMenu_DLG", displayNull];
    private _ctrlInventoryPanel = _display displayCtrl 86005; // IDC_TRANSFUSIONMENU_RIGHTLISTPANEL
    private _row = lbCurSel _ctrlInventoryPanel;

    if (_selection != 2 && {_row >= 0}) then {
        private _classname = ((_ctrlInventoryPanel lbData _row) splitString "|") param [0, ""];
        private _target = [ACE_player, missionNamespace getVariable ["ACM_circulation_TransfusionMenu_Target", objNull]] select _selection;

        if (_classname isNotEqualTo "" && {!isNull _target}) then {
            [_target, _classname] call efak_medical_fnc_unpackForUse;
        };
    };
};

_this call _original
