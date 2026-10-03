// ACM ACM_circulation_fnc_Syringe_UpdateMedicationList, kit-aware for EFAK. Copied from ACM 1.5.0.4 with
// its macros written out; ACM counts the vials in the unit's own inventory only, so vials packed in a
// kit never showed up in the draw window.

// This copy always stands in for ACM, whatever its version - ACM rarely touches these functions.
// Only ACM Extended, which ships its own reworked ACM that already looks into kits, runs its own
// function from its own file, untouched.
if (isNil "efak_compat_acm_useCopies") then {
    efak_compat_acm_useCopies = !isClass (configFile >> "CfgPatches" >> "ACM_Extended");
};
if (!efak_compat_acm_useCopies) exitWith {
    private _original = missionNamespace getVariable "efak_compat_acm_original_Syringe_UpdateMedicationList";
    if (isNil "_original") then {
        _original = compile preprocessFileLineNumbers "\x\ACM\addons\circulation\functions\fnc_Syringe_UpdateMedicationList.sqf";
        missionNamespace setVariable ["efak_compat_acm_original_Syringe_UpdateMedicationList", _original];
    };
    call _original
};

/*
 * Author: Blue
 * Prepare medication into syringe
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ACM_circulation_fnc_Syringe_UpdateMedicationList;
 *
 * Public: No
 */
private _display = uiNamespace getVariable ["ACM_circulation_SyringeDraw_DLG", displayNull];
private _ctrlMedList = _display displayCtrl 84006; // IDC_SYRINGEDRAW_MEDLIST

lbClear _ctrlMedList;

if (ACM_circulation_SyringeDraw_InventorySelection == 2) then {
    private _vehicle = objectParent ACE_player;
    {
        private _classname = _x;
        private _vehicleInventory = getItemCargo _vehicle;
        private _targetIndex = (_vehicleInventory select 0) findIf {_x == _classname};
        if (_targetIndex < 0) then {
            continue;
        };
        private _count = (_vehicleInventory select 1) select _targetIndex;

        if (_count > 0) then {
            private _config = (configFile >> "CfgWeapons" >> _classname);

            private _i = _ctrlMedList lbAdd getText (_config >> "displayName");
            _ctrlMedList lbSetPicture [_i, getText (_config >> "picture")];
            _ctrlMedList lbSetData [_i, ((_classname splitString "_") select 2)];
            _ctrlMedList lbSetTooltip [_i, (format [localize "STR_ACM_circulation_Common_Available", _count])];
        };
    } forEach ACM_circulation_MedicationVialList;
} else {
    private _inventoryTarget = [ACE_player, ACM_circulation_SyringeDraw_Target] select ACM_circulation_SyringeDraw_InventorySelection;

    {
        private _classname = _x;
        private _count = [_inventoryTarget, _classname] call efak_medical_fnc_countItem;

        if (_count > 0) then {
            private _config = (configFile >> "CfgWeapons" >> _classname);

            private _i = _ctrlMedList lbAdd getText (_config >> "displayName");
            _ctrlMedList lbSetPicture [_i, getText (_config >> "picture")];
            _ctrlMedList lbSetData [_i, ((_classname splitString "_") select 2)];
            _ctrlMedList lbSetTooltip [_i, (format [localize "STR_ACM_circulation_Common_Available", _count])];
        };
    } forEach ACM_circulation_MedicationVialList;
};