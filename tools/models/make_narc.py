"""Procedural narc box: a black hard case (Pelican style) for EFAK.

Axes follow EFAK's other kit models: x width, y depth (front = +y), z up from 0.
Writes narcbox.p3d (MLOD: LODs 1/2/4, shadow 10000, geometry), narcbox.obj for rendering.
MLOD conventions measured from mfakplus.p3d: cross(p1-p0, p2-p0) and the stored normals point
inwards; UV origin is the top left of the texture.
"""
import math
import struct
import sys

W, D, H = 0.26, 0.18, 0.11
X0, X1 = -W / 2, W / 2
Y0, Y1 = -D / 2, D / 2
SEAM = 0.066  # where lid and base meet

TEX = "z\\efak\\addons\\kits\\data\\narcbox_co.paa"
MAT = "z\\efak\\addons\\kits\\data\\narcbox.rvmat"

# UV regions of the 2048 atlas (u0, v0, u1, v1), painted by paint_narc.py
R_PLASTIC = (0.0, 0.0, 0.5, 0.5)
R_LABEL = (0.5, 0.0, 1.0, 0.25)
R_LATCH = (0.5, 0.25, 0.75, 0.5)
R_METAL = (0.75, 0.25, 1.0, 0.375)
R_LOCK = (0.75, 0.375, 1.0, 0.5)
R_RUBBER = (0.0, 0.5, 0.25, 0.75)
PLASTIC_SCALE = 0.5 / 0.30  # 0.30 m of case across the plastic region


def norm(v):
    l = math.sqrt(v[0] ** 2 + v[1] ** 2 + v[2] ** 2) or 1.0
    return (v[0] / l, v[1] / l, v[2] / l)


def axis_coords(a, b, r, seg):
    """Grid along one axis of a rounded box: arcs at both ends, flat between."""
    if seg == 0 or r <= 0:
        return [a, b]
    out = []
    for k in range(seg, 0, -1):
        out.append(a + r - r * math.tan(math.radians(45.0 * k / seg)))
    out.append(a + r)
    if b - r > a + r + 1e-9:
        out.append(b - r)
    for k in range(1, seg + 1):
        out.append(b - r + r * math.tan(math.radians(45.0 * k / seg)))
    return out


class Mesh:
    def __init__(self):
        self.tris = []  # each: [(pos, normal, uv)] * 3, counter-clockwise seen from outside

    def add(self, tri):
        self.tris.append(tri)


def rbox(mesh, x0, x1, y0, y1, z0, z1, r, seg, uvfn, skip=()):
    """Rounded box. uvfn(face, pos) -> (u, v); face is one of +x -x +y -y +z -z."""
    lo = (x0, y0, z0)
    hi = (x1, y1, z1)
    r = min(r, (x1 - x0) / 2, (y1 - y0) / 2, (z1 - z0) / 2)
    grids = [axis_coords(lo[i], hi[i], r, seg) for i in range(3)]

    def place(s):
        c = [min(max(s[i], lo[i] + r), hi[i] - r) for i in range(3)]
        d = [s[i] - c[i] for i in range(3)]
        n = norm(d)
        if r <= 0:
            return tuple(s), n
        return (c[0] + r * n[0], c[1] + r * n[1], c[2] + r * n[2]), n

    for axis in range(3):
        for sign in (-1, 1):
            name = ("+" if sign > 0 else "-") + "xyz"[axis]
            if name in skip:
                continue
            a1, a2 = [i for i in range(3) if i != axis]
            fixed = hi[axis] if sign > 0 else lo[axis]
            g1, g2 = grids[a1], grids[a2]
            for i in range(len(g1) - 1):
                for j in range(len(g2) - 1):
                    quad = []
                    for (ii, jj) in ((i, j), (i + 1, j), (i + 1, j + 1), (i, j + 1)):
                        s = [0, 0, 0]
                        s[axis] = fixed
                        s[a1] = g1[ii]
                        s[a2] = g2[jj]
                        p, n = place(s)
                        if n == (0.0, 0.0, 0.0):
                            n = [0.0, 0.0, 0.0]; n[axis] = float(sign); n = tuple(n)
                        quad.append((p, n, uvfn(name, p)))
                    # orientation: (a1, a2) basis; outward normal along sign*axis
                    e1 = [0, 0, 0]; e1[a1] = 1
                    e2 = [0, 0, 0]; e2[a2] = 1
                    c = (e1[1] * e2[2] - e1[2] * e2[1], e1[2] * e2[0] - e1[0] * e2[2], e1[0] * e2[1] - e1[1] * e2[0])
                    ccw = (c[axis] * sign) > 0
                    if not ccw:
                        quad = quad[::-1]
                    mesh.add([quad[0], quad[1], quad[2]])
                    mesh.add([quad[0], quad[2], quad[3]])


def plastic_uv(face, p):
    """Box projection into the plastic region."""
    u0, v0, u1, v1 = R_PLASTIC
    if face[1] == "x":
        a, b = p[1], -p[2]
    elif face[1] == "y":
        a, b = p[0], -p[2]
    else:
        a, b = p[0], p[1]
    return (u0 + (a + 0.15) * PLASTIC_SCALE * (u1 - u0) / 0.5,
            v0 + (b + 0.15) * PLASTIC_SCALE * (v1 - v0) / 0.5)


def region_uv(region, front, rect):
    """front face (+y) maps rect=(xa, xb, za, zb) onto region; other faces fall back to plastic."""
    xa, xb, za, zb = rect
    u0, v0, u1, v1 = region

    def fn(face, p):
        if face == front:
            return (u0 + (p[0] - xa) / (xb - xa) * (u1 - u0),
                    v0 + (zb - p[2]) / (zb - za) * (v1 - v0))
        return plastic_uv(face, p)
    return fn


def solid_uv(region):
    u0, v0, u1, v1 = region
    cu, cv = (u0 + u1) / 2, (v0 + v1) / 2

    def fn(face, p):
        # small wobble around the centre so the metal grain shows a little
        return (cu + (p[0] + p[1] * 0.5) * 0.3 * (u1 - u0), cv + p[2] * 0.3 * (v1 - v0))
    return fn


def build(seg):
    m = Mesh()
    r = 0.011
    # base and lid: two shells whose rounded edges meet in a groove at the seam
    rbox(m, X0, X1, Y0, Y1, 0.0, SEAM + 0.003, r, seg, plastic_uv)
    # the lid stands out a little over the base, like a real case's
    rbox(m, X0 - 0.0015, X1 + 0.0015, Y0 - 0.0015, Y1 + 0.0015, SEAM - 0.001, H, r + 0.0015, seg, plastic_uv)
    # raised panel on the lid
    rbox(m, X0 + 0.02, X1 - 0.02, Y0 + 0.018, Y1 - 0.018, H - 0.004, H + 0.004, 0.004,
         max(1, seg // 2), plastic_uv, skip=("-z",))
    # base ribs along the bottom of the front and back
    for (ya, yb) in ((Y1 - 0.004, Y1 + 0.002), (Y0 - 0.002, Y0 + 0.004)):
        rbox(m, X0 + 0.03, X1 - 0.03, ya, yb, 0.012, 0.020, 0.002, max(1, seg // 3), plastic_uv)
    # two latches over the seam on the front
    for cx in (-0.075, 0.075):
        rect = (cx - 0.022, cx + 0.022, SEAM - 0.028, SEAM + 0.024)
        rbox(m, rect[0], rect[1], Y1 - 0.004, Y1 + 0.009, rect[2], rect[3], 0.004,
             max(1, seg // 2), region_uv(R_LATCH, "+y", rect))
        # hinge bead the latch hangs from, on the lid
        rbox(m, cx - 0.024, cx + 0.024, Y1 - 0.003, Y1 + 0.007, SEAM + 0.022, SEAM + 0.031, 0.0045,
             max(1, seg // 2), plastic_uv)
    # padlock tab in the middle of the front
    rect = (-0.012, 0.012, SEAM - 0.026, SEAM + 0.004)
    rbox(m, rect[0], rect[1], Y1 - 0.004, Y1 + 0.006, rect[2], rect[3], 0.003,
         max(1, seg // 2), region_uv(R_LOCK, "+y", rect))
    # folding handle on the left side, lying flat against the case
    rbox(m, X0 - 0.015, X0 - 0.007, -0.045, 0.045, SEAM - 0.034, SEAM - 0.018, 0.004,
         max(1, seg // 2), solid_uv(R_RUBBER))
    for cy in (-0.040, 0.040):
        rbox(m, X0 - 0.010, X0 + 0.002, cy - 0.007, cy + 0.007, SEAM - 0.034, SEAM - 0.018, 0.003,
             max(1, seg // 3), plastic_uv)
    # hinge rod along the back
    rbox(m, X0 + 0.025, X1 - 0.025, Y0 - 0.008, Y0 + 0.002, SEAM - 0.004, SEAM + 0.006, 0.005,
         max(2, seg), plastic_uv)
    # small feet under the base
    for fx in (X0 + 0.03, X1 - 0.03):
        for fy in (Y0 + 0.03, Y1 - 0.03):
            rbox(m, fx - 0.012, fx + 0.012, fy - 0.012, fy + 0.012, -0.003, 0.002, 0.002, 1,
                 solid_uv(R_RUBBER), skip=("+z",))
    # label on the panel (single quad, faces up)
    lx0, lx1, ly0, ly1, lz = -0.08, 0.08, -0.04, 0.04, H + 0.0046
    u0, v0, u1, v1 = R_LABEL
    q = [((lx0, ly0, lz), (0, 0, 1), (u0, v0)), ((lx1, ly0, lz), (0, 0, 1), (u1, v0)),
         ((lx1, ly1, lz), (0, 0, 1), (u1, v1)), ((lx0, ly1, lz), (0, 0, 1), (u0, v1))]
    # u along +x, v along +y: read from the front, the top of the text points to the back.
    # Counter-clockwise seen from +z.
    a, b, c, d = q
    m.add([a, b, c]); m.add([a, c, d])
    return m


def weld(tris, eps=1e-6):
    pts, pidx = [], {}
    nrm, nidx = [], {}
    faces = []
    for t in tris:
        f = []
        for p, n, uv in t:
            kp = tuple(round(c / eps) for c in p)
            if kp not in pidx:
                pidx[kp] = len(pts); pts.append(p)
            kn = tuple(round(c * 1e5) for c in n)
            if kn not in nidx:
                nidx[kn] = len(nrm); nrm.append(n)
            f.append((pidx[kp], nidx[kn], uv))
        faces.append(f)
    return pts, nrm, faces


def asciiz(s):
    return s.encode("latin1") + b"\0"


def tagg(name, data):
    return b"\x01" + asciiz(name) + struct.pack("<I", len(data)) + data


def lod_bytes(resolution, tris, tex, mat, sharp=False, mass=None, props=()):
    pts, nrm, faces = weld(tris)
    out = bytearray(b"P3DM")
    out += struct.pack("<IIIIII", 28, 256, len(pts), len(nrm), len(faces), 0)
    for p in pts:
        out += struct.pack("<fffI", p[0], p[1], p[2], 0)
    for n in nrm:  # stored inwards
        out += struct.pack("<fff", -n[0], -n[1], -n[2])
    uvset = bytearray(struct.pack("<I", 0))
    for f in faces:
        f = [f[0], f[2], f[1]]  # flip winding: MLOD wants the inward cross product
        out += struct.pack("<I", 3)
        for pi, ni, (u, v) in f:
            out += struct.pack("<IIff", pi, ni, u, v)
            uvset += struct.pack("<ff", u, v)
        out += struct.pack("<IIff", 0, 0, 0, 0)
        out += struct.pack("<I", 0)
        out += asciiz(tex) + asciiz(mat)
    out += b"TAGG"
    if sharp:
        edges = set()
        for f in faces:
            for i in range(3):
                a, b = f[i][0], f[(i + 1) % 3][0]
                edges.add((min(a, b), max(a, b)))
        out += tagg("#SharpEdges#", b"".join(struct.pack("<II", a, b) for a, b in sorted(edges)))
    if mass is not None:
        out += tagg("#Mass#", b"".join(struct.pack("<f", mass / len(pts)) for _ in pts))
    for k, v in props:
        out += tagg("#Property#", k.encode().ljust(64, b"\0") + v.encode().ljust(64, b"\0"))
    if mass is None:
        out += tagg("#UVSet#", bytes(uvset))
    out += tagg("#EndOfFile#", b"")
    out += struct.pack("<f", resolution)
    return bytes(out), len(pts), len(faces)


def box_tris(x0, x1, y0, y1, z0, z1):
    m = Mesh()
    rbox(m, x0, x1, y0, y1, z0, z1, 0.0, 0, lambda f, p: (0.0, 0.0))
    return m.tris


def shadow_tris():
    m = Mesh()
    rbox(m, X0, X1, Y0, Y1, 0.0, H, 0.008, 1, lambda f, p: (0.0, 0.0))
    return m.tris


def write_obj(path, tris, mtl="narcbox"):
    with open(path, "w") as f:
        f.write("mtllib narcbox.mtl\nusemtl %s\n" % mtl)
        k = 1
        for t in tris:
            # Arma reads the file left-handed: mirror x so a right-handed renderer shows the game's view
            for p, n, uv in t[::-1]:
                # obj: y up; our z up, y depth -> obj (-x, z, -y)
                f.write("v %f %f %f\n" % (-p[0], p[2], -p[1]))
                f.write("vn %f %f %f\n" % (-n[0], n[2], -n[1]))
                f.write("vt %f %f\n" % (uv[0], 1.0 - uv[1]))
            f.write("f %d/%d/%d %d/%d/%d %d/%d/%d\n" % (k, k, k, k + 1, k + 1, k + 1, k + 2, k + 2, k + 2))
            k += 3


def main(out_p3d, out_obj):
    lods = []
    for res, seg in ((1, 5), (2, 2), (4, 1)):
        tris = build(seg).tris
        data, np_, nf = lod_bytes(res, tris, TEX, MAT)
        print("LOD", res, "points", np_, "faces", nf)
        lods.append(data)
        if res == 1:
            write_obj(out_obj, tris)
    data, np_, nf = lod_bytes(10000, shadow_tris(), "", "", sharp=True)
    print("shadow points", np_, "faces", nf)
    lods.append(data)
    data, np_, nf = lod_bytes(1e13, box_tris(X0, X1, Y0 - 0.006, Y1 + 0.008, -0.003, H + 0.004), "", "",
                              mass=1.0, props=(("autocenter", "0"),))
    lods.append(data)
    with open(out_p3d, "wb") as f:
        f.write(b"MLOD" + struct.pack("<II", 257, len(lods)))
        for l in lods:
            f.write(l)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
