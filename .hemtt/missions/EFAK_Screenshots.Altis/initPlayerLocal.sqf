// Screenshot mission for the workshop page:
//   hemtt launch screenshots
// A medical scene near the airfield on Altis in the evening sun, seen through a fixed camera. Keys:
//   F5  the kit window              F6  the kit window with the kit menu open
//   F7  Quick access                F8  camera on / off (off: the player's own view)
// Windows HDR off while taking them. hemtt starts Arma without the Steam overlay, so F12 does nothing:
// capture the window's own content instead (PrintWindow), which leaves out the desktop around it.

[] spawn {
    waitUntil {!isNull player && {time > 0.5}};

    // Evening light, a clear sky, no grass in the way.
    setDate [2035, 6, 24, 18, 50];
    setTerrainGrid 50;
    0 setOvercast 0.1;
    0 setFog 0;
    0 setRain 0;
    forceWeatherChange;
    setViewDistance 3000;
    setObjectViewDistance 2500;

    // Somewhere flat and open near the airfield.
    private _found = [[14620, 16760, 0], 0, 400, 12, 0, 0.08, 0] call BIS_fnc_findSafePos;
    private _center = [_found select 0, _found select 1, 0];

    private _fnc_at = {
        params ["_class", "_offset", ["_dir", 0]];

        private _pos = _center vectorAdd _offset;
        private _object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];

        _object setDir _dir;
        _object setPosATL _pos;
        _object
    };

    // The scene faces west, towards the camera and the low sun.
    ["B_Truck_01_medical_F", [7, 4, 0], 200] call _fnc_at;
    private _crate = ["ACE_medicalSupplyCrate_advanced", [-1.2, -2.6, 0], 30] call _fnc_at;
    ["Box_NATO_Support_F", [-0.2, -3.8, 0], 75] call _fnc_at;
    ["Land_CampingTable_F", [3.2, -2.4, 0], 90] call _fnc_at;
    ["Land_CampingChair_V1_F", [3.8, -1.2, 0], 120] call _fnc_at;
    ["Land_BagFence_Long_F", [-3, 3.5, 0], 90] call _fnc_at;
    ["Land_BagFence_Round_F", [-2.2, 5.6, 0], 45] call _fnc_at;

    // A casualty on the ground and a medic at work.
    private _group = createGroup [west, true];
    private _casualty = _group createUnit ["B_Soldier_F", _center vectorAdd [1, 0.4, 0], [], 0, "CAN_COLLIDE"];
    private _medic = _group createUnit ["B_medic_F", _center vectorAdd [0.2, 1.4, 0], [], 0, "CAN_COLLIDE"];

    {
        _x allowDamage false;
        _x disableAI "ALL";
    } forEach [_casualty, _medic];

    _casualty setDir 20;
    _medic setDir 190;
    [_casualty, "PRONE_INJURED", "ASIS"] call BIS_fnc_ambientAnim;
    [_medic, "KNEEL_TREAT", "ASIS"] call BIS_fnc_ambientAnim;

    // Once both are in their animations: the casualty across in front of the medic, the chest under
    // the medic's hands (set by eye in the game).
    sleep 1;
    detach _casualty;
    _casualty setDir (getDir _medic + 90);

    private _front = _medic modelToWorld [0, 0.8, 0];
    _casualty setPosATL [_front select 0, _front select 1, 0];

    private _chest = _casualty modelToWorld [-0.15, 0.82, 0];
    _casualty setPosATL [_chest select 0, _chest select 1, 0];

    // The player stands out of the picture at the crate, carrying three kits and some supplies.
    player setPosATL (_center vectorAdd [-2.6, -1.4, 0]);
    player hideObject true;
    removeAllWeapons player;
    removeBackpack player;
    player addBackpack "B_Kitbag_rgr";
    player addItemToBackpack "efak_MFAKPlus";
    player addItemToBackpack "efak_AFAK";
    player addItemToVest "efak_IFAK";

    {
        _x params ["_class", "_count"];

        for "_i" from 1 to _count do {player addItemToBackpack _class};
    } forEach [
        ["ACE_elasticBandage", 8],
        ["ACE_packingBandage", 6],
        ["ACE_quikclot", 4],
        ["ACE_tourniquet", 2],
        ["ACE_morphine", 3],
        ["ACE_epinephrine", 2],
        ["ACE_splint", 2],
        ["ACE_salineIV_500", 2]
    ];

    // The camera.
    private _cam = "camera" camCreate (_center vectorAdd [-5.2, -2.4, 1.5]);
    _cam camSetTarget (_center vectorAdd [1.8, 1.2, 0.4]);
    _cam camSetFov 0.55;
    _cam cameraEffect ["internal", "back"];
    _cam camCommit 0;
    showCinemaBorder false;
    missionNamespace setVariable ["efak_shots_camera", _cam];
    missionNamespace setVariable ["efak_shots_cameraOn", true];

    // The kits become instances a moment after they are carried.
    waitUntil {count ([player] call efak_core_fnc_getCarriedKits) >= 3};

    hintSilent "F5 kit window - F6 with kit menu - F7 Quick access - F8 camera";

    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["", "_key"];

        private _kit = (([player] call efak_core_fnc_getCarriedKits) select {"MFAKPlus" in _x}) param [0, ""];

        switch (_key) do {
            case 63: {
                hintSilent "";
                [player, _kit] call efak_gui_fnc_openPouch;
                true
            };
            case 64: {
                hintSilent "";
                [player, _kit] call efak_gui_fnc_openPouch;

                // Once the window is open: its kit menu.
                [{
                    private _display = uiNamespace getVariable ["efak_gui_display", displayNull];
                    private _hit = ((_display getVariable ["efak_gui_buttons", createHashMap]) getOrDefault ["KitSwitch", []]) param [4, controlNull];

                    if (!isNull _hit) then {[_hit] call efak_gui_fnc_onDropdownClick};
                }, [], 1] call CBA_fnc_waitAndExecute;
                true
            };
            case 65: {
                hintSilent "";
                [_kit, player] call efak_gui_fnc_showContents;
                true
            };
            case 66: {
                private _cam = missionNamespace getVariable ["efak_shots_camera", objNull];
                private _on = !(missionNamespace getVariable ["efak_shots_cameraOn", true]);

                _cam cameraEffect [["terminate", "internal"] select _on, "back"];
                missionNamespace setVariable ["efak_shots_cameraOn", _on];
                true
            };
            default {false};
        };
    }];
};
