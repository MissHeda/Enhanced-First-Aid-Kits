#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Returns a kit's contents in a form that can leave the running mission: kits
 * packed inside it are written as their prototype plus their own contents,
 * never as their instance id. An id only means something in the mission that
 * handed it out, and copying it would make two kits share one set of contents.
 *
 * Tree format:
 * [[class, count], ...] for ordinary items, and [prototype, count, tree] for a
 * packed kit instance. A packed prototype stays [class, count]
 * and gets the default contents once it is taken out and converted.
 *
 * Arguments:
 * 0: Kit instance class <STRING>
 * 1: Nesting depth, internal <NUMBER> (default: 0)
 *
 * Return Value:
 * Contents tree <ARRAY>
 *
 * Example:
 * ["efak_IFAK_7"] call efak_core_fnc_getContentsTree;
 *
 * Public: Yes
 */

params ["_kitClass", ["_depth", 0]];

([_kitClass] call FUNC(getContents)) apply {
    _x params ["_class", "_count"];

    private _key = toLowerANSI _class;
    private _prototype = GVAR(prototypeOf) getOrDefault [_key, ""];

    switch (true) do {
        // Opened magazines take their rounds along, so a loadout does not refill them.
        case (_prototype isEqualTo "" && {([_kitClass, _class] call FUNC(getCharges)) isNotEqualTo []}): {
            [_class, _count, -1, [_kitClass, _class] call FUNC(getCharges)]
        };
        case (_prototype isEqualTo "");
        case (_key in GVAR(needsConversion)): {
            [_class, _count]
        };
        // Deeper than a restore would ever read: keep the kit, lose what is inside it.
        case (_depth >= EFAK_RESTORE_MAX_DEPTH);
        // A packed kit nobody touched, or one marked to follow the defaults, goes in as a fresh one.
        case (_key in GVAR(followDefaults));
        case (([_class] call FUNC(getCharges)) isEqualTo [] && {[_prototype, [_class] call FUNC(getContents)] call FUNC(isDefaultContents)}): {
            [_prototype, _count]
        };
        default {
            [_prototype, _count, [_class, _depth + 1] call FUNC(getContentsTree)]
        };
    };
}
