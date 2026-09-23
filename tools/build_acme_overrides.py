#!/usr/bin/env python3
"""Builds the legacy ACME function overrides of efak_compat_acme from ACM Extended's own files.

Only for ACM Extended versions without ACME_fnc_itemCount: newer ones ask EFAK themselves, and
efak_compat_acme loads these overrides only when that function is missing (see its config.cpp).

ACM Extended takes medical items from the medic with the engine's removeItem, which only finds loose
items. Every such place is pointed at efak_medical_fnc_takeItem instead - a loose one first,
otherwise straight out of an EFAK kit. Nothing else in those files changes.

Re-run after every ACM Extended update, pointing it at the mod's addons folder:

    python tools/build_acme_overrides.py "<Steam>/steamapps/workshop/content/107410/3749759934/addons"

(3800798331 for the dev branch.) The copies replace ACME's own functions, so they have to come from
the ACM Extended version that is played: copies of another version undo its fixes or call functions
it does not have.

It rewrites addons/compat_acme/legacy/acme/ and addons/compat_acme/legacy/CfgFunctions.hpp.
"""

import io
import os
import re
import shutil
import struct
import sys
import tempfile

# The blood cooler and fridge move bags between the cooler and the inventory - not a kit's business -
# and stay ACME's own.
SKIP = {"fn_coolerAutoStore.sqf", "fn_coolerBoxDeploy.sqf", "fn_coolerLoad.sqf"}

# ACM Extended's copy of ACM_circulation: the syringe draw, the transfusion menu and the AED, which
# looks for itself with "in (items _medic)".
CIRCULATION = ["fnc_Syringe_PrepareFinish.sqf", "fnc_TransfusionMenu_AddBag.sqf", "fnc_canConnectAED.sqf"]

# What those two files use of ACM's macros, spelled out.
MACROS = [
    (r"ACEFUNC\((\w+),(\w+)\)", r"ace_\1_fnc_\2"),
    (r"EFUNC\((\w+),(\w+)\)", r"ACM_\1_fnc_\2"),
    (r"\bQGVAR\((\w+)\)", r'"ACM_circulation_\1"'),
    (r"\bGVAR\((\w+)\)", r"ACM_circulation_\1"),
    (r"\bFUNC\((\w+)\)", r"ACM_circulation_fnc_\1"),
    (r"\bLLSTRING\((\w+)\)", r'localize "STR_ACM_Circulation_\1"'),
    (r"\bIDC_TRANSFUSIONMENU_RIGHTLISTPANEL\b", "86005"),
]

REMOVE = re.compile(r"\b(_\w+|ACE_player)\s+removeItem\s+([^;}\n]+?)(\s*[;}])")
TAKE = r"[\1, \2] call efak_medical_fnc_takeItem\3"

# Places that look for an item without taking it, each changed by hand - the build stops when one no
# longer matches, so an ACME update that moved the code cannot slip through unnoticed.
EXTRA = {
    # The non-rebreather needs an oxygen tank and only looked for a loose one. The tank is drawn from
    # through ACM_breathing_fnc_useOxygenTankReserve, which opens one out of a kit (overrides\).
    "fn_nrbApply.sqf": [(
        "} forEach [uniformContainer _medic, vestContainer _medic, backpackContainer _medic];\n",
        "} forEach [uniformContainer _medic, vestContainer _medic, backpackContainer _medic];\n"
        "if (!_hasO2) then {_hasO2 = ([_medic, \"ACM_OxygenTank_425\"] call efak_medical_fnc_countInKits) > 0;};\n",
    )],
}

# 'ACM_AED' in (items _medic) - a look at the loose inventory only.
IN_ITEMS = re.compile(r"'(\w+)' in \(items (_\w+)\)")
HAS = r"(([\2, '\1'] call efak_medical_fnc_countItem) > 0)"

HEADER = """// EFAK compat: ACM Extended's own {name}, with every
//   <unit> removeItem <item>
// replaced by
//   [<unit>, <item>] call efak_medical_fnc_takeItem
// which takes a loose one first and otherwise one straight out of an EFAK kit. Nothing else changed,
// apart from what EXTRA in the build script lists for this file.
// Generated from ACM Extended by tools/build_acme_overrides.py - regenerate after an ACM Extended update.
"""


def extract(pbo, outdir):
    """The .sqf and .hpp files of a PBO - ACM ships its sources next to the compiled .sqfc."""
    buf = io.open(pbo, "rb").read()
    pos = 0
    entries = []

    def asciiz(start):
        end = buf.index(b"\0", start)
        return buf[start:end].decode("utf-8", "replace"), end + 1

    while True:
        name, pos = asciiz(pos)
        method, _orig, _res, _time, size = struct.unpack_from("<5I", buf, pos)
        pos += 20
        if name == "" and method == 0:
            break
        if name == "":
            while True:
                key, pos = asciiz(pos)
                if key == "":
                    break
                _value, pos = asciiz(pos)
            continue
        entries.append((name, size))

    data = pos
    for name, size in entries:
        blob = buf[data:data + size]
        data += size
        if not name.endswith((".sqf", ".hpp")):
            continue
        path = os.path.join(outdir, name.replace("\\", os.sep))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, "wb").write(blob)


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)

    src = tempfile.mkdtemp()
    for name in ["ACM_acm_extended", "ACM_circulation"]:
        extract(os.path.join(sys.argv[1], name + ".pbo"), os.path.join(src, name))

    dst = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "addons", "compat_acme", "legacy")
    out = os.path.join(dst, "acme")
    if os.path.isdir(out):
        shutil.rmtree(out)
    os.makedirs(out)

    acme = []
    acme_dir = os.path.join(src, "ACM_acm_extended", "functions")
    for name in sorted(os.listdir(acme_dir)):
        if not name.endswith(".sqf") or name in SKIP:
            continue
        code = io.open(os.path.join(acme_dir, name), encoding="utf-8", errors="replace").read()
        code, count = REMOVE.subn(TAKE, code)
        for old, new in EXTRA.get(name, []):
            if old not in code:
                raise SystemExit("%s changed: %r not found - update EXTRA" % (name, old))
            code = code.replace(old, new, 1)
            count += 1
        if count == 0:
            continue
        io.open(os.path.join(out, name), "w", encoding="utf-8", newline="").write(HEADER.format(name=name) + code)
        acme.append((name[3:-4], count))

    circulation = []
    circ_dir = os.path.join(src, "ACM_circulation", "functions")
    for name in CIRCULATION:
        code = io.open(os.path.join(circ_dir, name), encoding="utf-8", errors="replace").read()
        code = re.sub(r"^#include .*\n", "", code, flags=re.M)
        for pattern, replacement in MACROS:
            code = re.sub(pattern, replacement, code)
        left = sorted(set(re.findall(r"\b[A-Z][A-Z_]+\([^)]*\)|\bIDC_\w+", code)))
        if left:
            raise SystemExit("macros left in %s: %s - add them to MACROS" % (name, left))
        code, count = REMOVE.subn(TAKE, code)
        code, looks = IN_ITEMS.subn(HAS, code)
        count += looks
        function = name[4:-4]
        io.open(os.path.join(out, "fn_" + function + ".sqf"), "w", encoding="utf-8", newline="").write(
            HEADER.format(name="ACM_circulation_fnc_" + function) + code)
        circulation.append((function, count))

    shutil.rmtree(src, ignore_errors=True)

    def classes(names):
        return "".join("            class %s {};\n" % n for n, _ in names)

    config = """// Generated by tools/build_acme_overrides.py - do not edit by hand.
//
// ACM Extended reads and takes the medic's supplies itself instead of asking ACE medical: it counts
// with ace_common_fnc_getCountOfItem and ace_common_fnc_uniqueItems and takes with the engine's
// removeItem. Nothing of that sees into a kit.
//
// - The two ACE functions are redefined with ACE's own code plus the unit's kits (overrides\\).
// - ACM's portable oxygen opens a tank out of a kit when none is loose, and the refill at a
//   medical vehicle takes the empty tank out of a kit (overrides\\).
// - Every function of ACM Extended that takes an item with removeItem is redefined with the same
//   code, the removeItem replaced by efak_medical_fnc_takeItem (acme\\).
//
// The function library takes the last definition it sees, and this addon loads after ACE and ACM
// Extended. ACE and ACM compile final, so a runtime reassignment would be refused.
class CfgFunctions {
    class EFAK_overwrite_common {
        tag = "ace_common";

        class ace_common {
            class getCountOfItem {
                file = QPATHTOF(legacy\\overrides\\fnc_getCountOfItem.sqf);
            };
            class uniqueItems {
                file = QPATHTOF(legacy\\overrides\\fnc_uniqueItems.sqf);
            };
        };
    };

    class EFAK_overwrite_ACME {
        tag = "ACME";

        class infusion {
            file = QPATHTOF(legacy\\acme);
%s        };
    };

    class EFAK_overwrite_ACM_circulation {
        tag = "ACM_circulation";

        class ACM_circulation {
            file = QPATHTOF(legacy\\acme);
%s        };
    };

    class EFAK_overwrite_ACM_breathing {
        tag = "ACM_breathing";

        class ACM_breathing {
            class refillOxygenTank {
                file = QPATHTOF(legacy\\overrides\\fnc_refillOxygenTank.sqf);
            };
            class useOxygenTankReserve {
                file = QPATHTOF(legacy\\overrides\\fnc_useOxygenTankReserve.sqf);
            };
        };
    };
};
""" % (classes(acme), classes(circulation))
    io.open(os.path.join(dst, "CfgFunctions.hpp"), "w", encoding="utf-8", newline="").write(config)

    total = sum(c for _, c in acme + circulation)
    print("%d ACME files, %d ACM_circulation files, %d removeItem replaced" % (len(acme), len(circulation), total))


if __name__ == "__main__":
    main()
