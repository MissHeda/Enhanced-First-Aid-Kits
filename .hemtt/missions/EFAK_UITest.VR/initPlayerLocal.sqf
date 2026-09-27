// Development mission for EFAK's windows: gear, a crate, and the kit window opened straight away.
//   hemtt launch ui-test
// Escape closes a window; the debug console reopens them:
//   [player, ([player] call efak_core_fnc_getCarriedKits) select 0] call efak_gui_fnc_openPouch;
//   [([player] call efak_core_fnc_getCarriedKits) select 0, player] call efak_gui_fnc_showContents;

[] spawn {
    waitUntil {!isNull player && {time > 1}};

    player addBackpack "B_Kitbag_rgr";
    player addItemToBackpack "efak_MFAKPlus";
    player addItemToVest "efak_IFAK";

    {
        _x params ["_class", "_count"];
        for "_i" from 1 to _count do {player addItemToBackpack _class};
    } forEach [
        ["ACE_elasticBandage", 6],
        ["ACE_packingBandage", 4],
        ["ACE_tourniquet", 2],
        ["ACE_morphine", 3],
        ["ACE_splint", 1],
        ["ACE_salineIV_500", 2]
    ];
    player addMagazines ["ACE_painkillers", 2];

    private _crate = "Box_NATO_Support_F" createVehicle (player modelToWorld [0, 2, 0]);
    clearItemCargoGlobal _crate;
    clearMagazineCargoGlobal _crate;
    clearWeaponCargoGlobal _crate;
    _crate addItemCargoGlobal ["ACE_fieldDressing", 20];
    _crate addItemCargoGlobal ["ACE_quikclot", 15];
    _crate addItemCargoGlobal ["ACE_epinephrine", 5];

    // The kits become instances a moment after they are carried.
    waitUntil {count ([player] call efak_core_fnc_getCarriedKits) >= 2};
    sleep 1;

    private _kit = ([player] call efak_core_fnc_getCarriedKits) select {"MFAKPlus" in _x};
    [player, (_kit + ([player] call efak_core_fnc_getCarriedKits)) select 0] call efak_gui_fnc_openPouch;
};
