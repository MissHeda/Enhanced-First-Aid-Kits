// EFAK compat: ACM Extended's own fn_epinephrinePrepare.sqf, with every
//   <unit> removeItem <item>
// replaced by
//   [<unit>, <item>] call efak_medical_fnc_takeItem
// which takes a loose one first and otherwise one straight out of an EFAK kit. Nothing else changed,
// apart from what EXTRA in the build script lists for this file.
// Generated from ACM Extended by tools/build_acme_overrides.py - regenerate after an ACM Extended update.
/* Canonical preparation, shared by the Narc Box and compatibility actions.
   _reservedFlush=true is ONLY for the legacy workflow that already removed its flush. */
params ["_medic", ["_reservedFlush", false], ["_customName", "", [""]]];
if (isNull _medic || {!local _medic}) exitWith {false};
private _reserved = _medic getVariable ["ACME_flush_State", []];
if (_reservedFlush && {!(_reserved isEqualTo [9, 1, false])}) exitWith {false};
if (!_reservedFlush && {([_medic, "ACM_SalineFlush_10"] call ace_common_fnc_getCountOfItem) < 1}) exitWith {false};
if !([_medic, 1] call ACME_fnc_epinephrineTakeSource) exitWith {false};
if (!_reservedFlush) then {[_medic, "ACM_SalineFlush_10"] call efak_medical_fnc_takeItem;} else {_medic setVariable ["ACME_flush_State", [], true];};
private _store = _medic getVariable ["ACME_narcStore", []];
private _label = if (_customName == "") then {"Push-dose epinephrine 10 mcg/mL (10 mL = 100 mcg)"} else {_customName};
private _entry = ["EpinephrineCardiac", 10, 1, _label, 9, [], "epiMixB12"];
if (!isNull (findDisplay 84000)) then {_entry = [_entry] call ACME_fnc_skApplyPendingTag;};
while {count _entry < 13} do {_entry pushBack "";};
_entry set [12,"flush"];
_store pushBack _entry;
[_medic, _store] call ACME_fnc_narcStoreCommit;
["Prepared epinephrine 10 mcg/mL: 10 mL contains 100 mcg. Select the syringe in the Narc Box to give 1 mL, 2 mL, or the full remaining volume.", 5, _medic] call ace_common_fnc_displayTextStructured;
true
