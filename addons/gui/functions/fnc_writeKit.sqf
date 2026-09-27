#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Miss Heda
 * Writes the contents of the kit being shown, and removes the kit when that emptied it and its type
 * is set to disappear when empty.
 *
 * Every move writes the kit once, with the whole result, rather than item by item: a kit that is
 * written one class at a time can briefly hold more than it may, and a kit that is momentarily over
 * capacity refuses the next item and silently loses it.
 *
 * Arguments:
 * 0: New contents <ARRAY> of [class, count]
 *
 * Return Value:
 * None
 *
 * Example:
 * [[["ACE_morphine", 2]]] call efak_gui_fnc_writeKit;
 *
 * Public: No
 */

params ["_contents", ["_charges", -1]];

// Taken once: removing an emptied kit frees its id, which on a host raises contentsChanged right
// away - and that must neither refresh the window in the middle of this nor point it at another kit
// before the one that went is written down as gone.
private _kitClass = GVAR(kitClass);
private _owner = GVAR(owner);

// Writing the contents fires contentsChanged, which the window listens to in order to notice
// somebody else digging through the same kit. Our own write is not somebody else.
GVAR(applying) = true;

[_kitClass, _contents, _charges] call EFUNC(core,setContents);

// Does nothing unless the kit is both empty and set up to disappear when it is. The next refresh
// then finds it gone and switches to another kit, or closes the window.
if (_contents isEqualTo [] && {[_kitClass, "removeWhenEmpty", false] call EFUNC(core,getKitSetting)}) then {
    GVAR(removedKits) set [toLowerANSI _kitClass, true];

    if !([_owner, _kitClass] call EFUNC(core,removeKit)) then {
        GVAR(removedKits) deleteAt (toLowerANSI _kitClass);
    };
};

GVAR(applying) = false;
