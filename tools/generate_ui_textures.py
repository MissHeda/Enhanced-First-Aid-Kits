#!/usr/bin/env python3
"""Draws the textures of EFAK's windows and converts them to PAA.

Everything is drawn in white on transparent at eight times its size and scaled down, so the edges
are smooth; the game tints most of it (colorText). The two switch states are drawn in colour, the
windows' glass (gloss_*) as white of little alpha, each for the shape of its window.

    python tools/generate_ui_textures.py [path to ImageToPAA.exe]

Writes addons/gui/ui/*.paa. Needs Pillow, and ImageToPAA from Arma 3 Tools (default path below).
"""

import math
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageChops, ImageDraw

IMAGE_TO_PAA = r"D:\Steam\steamapps\common\Arma 3 Tools\ImageToPAA\ImageToPAA.exe"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "addons", "gui", "ui")
SS = 8  # supersampling

WHITE = (255, 255, 255, 255)

# The switch colours, the same as ACCENT / FIELD_HOVER / TEXT in addons/gui/defines.hpp.
ACCENT = (245, 165, 36, 255)
TRACK_OFF = (52, 58, 70, 255)
KNOB_ON = (22, 24, 29, 255)
KNOB_OFF = (163, 172, 185, 255)


def canvas(w, h):
    return Image.new("RGBA", (w * SS, h * SS), (0, 0, 0, 0))


def finish(im, w, h):
    return im.resize((w, h), Image.LANCZOS)


def corner(which, size=64):
    """A quarter of a filled circle, round towards the outside of the panel it sits in."""
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    s = size * SS
    # The circle's centre is the panel-side corner of the tile.
    cx = {"tl": s, "tr": 0, "bl": s, "br": 0}[which]
    cy = {"tl": s, "tr": s, "bl": 0, "br": 0}[which]
    d.ellipse([cx - s, cy - s, cx + s, cy + s], fill=WHITE)
    return finish(im, size, size)


def stroke_icon(draw_fn, size=128, width=10):
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    draw_fn(d, size * SS, width * SS)
    return finish(im, size, size)


def line(d, pts, w):
    """A polyline with round caps and joins."""
    d.line(pts, fill=WHITE, width=int(w), joint="curve")
    r = w / 2
    for x, y in (pts[0], pts[-1]):
        d.ellipse([x - r, y - r, x + r, y + r], fill=WHITE)


def chevron(d, s, w, direction, offset=0.0):
    k = s * 0.16
    cx = s / 2 + offset * s
    cy = s / 2
    if direction == "right":
        pts = [(cx - k * 0.8, cy - k * 1.6), (cx + k * 0.8, cy), (cx - k * 0.8, cy + k * 1.6)]
    elif direction == "left":
        pts = [(cx + k * 0.8, cy - k * 1.6), (cx - k * 0.8, cy), (cx + k * 0.8, cy + k * 1.6)]
    else:  # down
        pts = [(cx - k * 1.6, cy - k * 0.8), (cx, cy + k * 0.8), (cx + k * 1.6, cy - k * 0.8)]
    line(d, pts, w)


def icon_close(d, s, w):
    a, b = s * 0.3, s * 0.7
    line(d, [(a, a), (b, b)], w)
    line(d, [(b, a), (a, b)], w)


def icon_search(d, s, w):
    r = s * 0.22
    cx, cy = s * 0.44, s * 0.44
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=WHITE, width=int(w))
    k = r * 0.72
    line(d, [(cx + k, cy + k), (s * 0.78, s * 0.78)], w)


def icon_sort(d, s, w, ascending):
    # An arrow and three bars that grow or shrink with it.
    x = s * 0.3
    top, bottom = s * 0.24, s * 0.76
    line(d, [(x, top), (x, bottom)], w)
    if ascending:
        line(d, [(x - s * 0.12, top + s * 0.12), (x, top), (x + s * 0.12, top + s * 0.12)], w)
        bars = [0.16, 0.26, 0.36]
    else:
        line(d, [(x - s * 0.12, bottom - s * 0.12), (x, bottom), (x + s * 0.12, bottom - s * 0.12)], w)
        bars = [0.36, 0.26, 0.16]
    for i, length in enumerate(bars):
        y = s * (0.3 + i * 0.2)
        line(d, [(s * 0.5, y), (s * (0.5 + length), y)], w)


def icon_inventory(d, s, w):
    # A backpack: rounded body, carry loop on top, front pocket.
    d.rounded_rectangle([s * 0.24, s * 0.3, s * 0.76, s * 0.84], radius=s * 0.13, outline=WHITE, width=int(w))
    line(d, [(s * 0.39, s * 0.3), (s * 0.39, s * 0.2), (s * 0.61, s * 0.2), (s * 0.61, s * 0.3)], w)
    d.rounded_rectangle([s * 0.35, s * 0.56, s * 0.65, s * 0.84], radius=s * 0.05, outline=WHITE, width=int(w))


def icon_crate(d, s, w):
    # A package seen from a corner: hexagon outline, the front edge and the top faces.
    cx, top, bottom = s * 0.5, s * 0.16, s * 0.84
    left, right, upper, lower = s * 0.2, s * 0.8, s * 0.33, s * 0.67
    mid = s * 0.5
    line(d, [(cx, top), (right, upper), (right, lower), (cx, bottom), (left, lower), (left, upper), (cx, top)], w)
    line(d, [(left, upper), (cx, mid), (right, upper)], w)
    line(d, [(cx, mid), (cx, bottom)], w)


def icon_ground(d, s, w):
    # An arrow down onto a line.
    line(d, [(s * 0.5, s * 0.2), (s * 0.5, s * 0.62)], w)
    line(d, [(s * 0.34, s * 0.47), (s * 0.5, s * 0.63), (s * 0.66, s * 0.47)], w)
    line(d, [(s * 0.24, s * 0.8), (s * 0.76, s * 0.8)], w)


def icon_kit(d, s, w):
    # A medical cross in a rounded square.
    d.rounded_rectangle([s * 0.18, s * 0.18, s * 0.82, s * 0.82], radius=s * 0.14, outline=WHITE, width=int(w))
    line(d, [(s * 0.5, s * 0.34), (s * 0.5, s * 0.66)], w)
    line(d, [(s * 0.34, s * 0.5), (s * 0.66, s * 0.5)], w)


def icon_check(d, s, w):
    # The tick on the chosen row of a drop down menu.
    line(d, [(s * 0.24, s * 0.52), (s * 0.42, s * 0.7), (s * 0.77, s * 0.32)], w)


def icon_auto(d, s, w):
    # Two arrows chasing each other round a circle: "whichever fits".
    r = s * 0.27
    c = s / 2
    box = [c - r, c - r, c + r, c + r]
    d.arc(box, start=195, end=318, fill=WHITE, width=int(w))
    d.arc(box, start=15, end=138, fill=WHITE, width=int(w))
    k = s * 0.1
    for angle in (318, 138):
        a = math.radians(angle)
        x, y = c + r * math.cos(a), c + r * math.sin(a)
        # A solid head at the end of each arc, pointing on round the circle, clockwise.
        tx, ty = -math.sin(a), math.cos(a)
        nx, ny = math.cos(a), math.sin(a)
        d.polygon([
            (x + tx * k * 1.2, y + ty * k * 1.2),
            (x - tx * k * 0.2 + nx * k, y - ty * k * 0.2 + ny * k),
            (x - tx * k * 0.2 - nx * k, y - ty * k * 0.2 - ny * k),
        ], fill=WHITE)


def toggle(on, w=128, h=64):
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    W, H = w * SS, h * SS
    pad = H * 0.08
    d.rounded_rectangle([pad, pad, W - pad, H - pad], radius=(H - 2 * pad) / 2, fill=ACCENT if on else TRACK_OFF)
    r = (H - 2 * pad) / 2 - H * 0.1
    cy = H / 2
    cx = W - pad - (H - 2 * pad) / 2 if on else pad + (H - 2 * pad) / 2
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=KNOB_ON if on else KNOB_OFF)
    return finish(im, w, h)


def scroll_thumb(w=32, h=256):
    """A scroll bar's thumb: a slim bar with round ends in the middle of the bar's width. The game
    stretches it to the thumb's length, so its ends are drawn a little flat to come out round."""
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    bar = w * SS * 0.4
    x0 = (w * SS - bar) / 2
    d.rounded_rectangle([x0, SS * 3, x0 + bar, h * SS - SS * 3], radius=bar / 2, fill=WHITE)
    return finish(im, w, h)


def gloss(tex_w, tex_h, width, height, radius, screen_h):
    """The sheen on a window's glass: light along the top that fades out, and a thin light edge.

    width, height and radius are the window's size in its own rows (see defines.hpp), screen_h its
    height in pixels at 1080p. Drawn at the window's true shape, then squeezed into a power-of-two
    texture - the game stretches it back over the window, so the corners come out round.
    """
    scale = 4096 / max(width, height)
    w, h = round(width * scale), round(height * scale)
    r = radius * scale
    px = h / screen_h  # one screen pixel, in drawing pixels

    shape = Image.new("L", (w, h), 0)
    ImageDraw.Draw(shape).rounded_rectangle([0, 0, w - 1, h - 1], radius=r, fill=255)
    inner = Image.new("L", (w, h), 0)
    edge = 1.2 * px
    ImageDraw.Draw(inner).rounded_rectangle([edge, edge, w - 1 - edge, h - 1 - edge], radius=max(r - edge, 0), fill=255)

    # The sheen over the top of the window, and the edge brighter at the top than at the bottom - each
    # a column of alpha, spread over the width.
    sheen_h = min(h * 0.5, 7.5 * scale)
    sheen = Image.new("L", (1, h))
    rim = Image.new("L", (1, h))
    for y in range(h):
        sheen.putpixel((0, y), round(255 * 0.055 * max(0.0, 1 - y / sheen_h) ** 1.6))
        rim.putpixel((0, y), round(255 * (0.16 - 0.1 * y / h)))
    sheen = sheen.resize((w, h), Image.NEAREST)
    rim = rim.resize((w, h), Image.NEAREST)

    ring = ImageChops.subtract(shape, inner)
    alpha = ImageChops.add(ImageChops.multiply(sheen, inner), ImageChops.multiply(rim, ring))

    im = Image.merge("RGBA", (Image.new("L", (w, h), 255),) * 3 + (alpha,))
    return im.resize((tex_w, tex_h), Image.LANCZOS)


def main():
    tool = sys.argv[1] if len(sys.argv) > 1 else IMAGE_TO_PAA
    if not os.path.isfile(tool):
        raise SystemExit("ImageToPAA not found: %s" % tool)

    images = {
        "corner_tl_ca": corner("tl"),
        "corner_tr_ca": corner("tr"),
        "corner_bl_ca": corner("bl"),
        "corner_br_ca": corner("br"),
        "icon_close_ca": stroke_icon(icon_close),
        "icon_search_ca": stroke_icon(icon_search),
        "icon_sort_asc_ca": stroke_icon(lambda d, s, w: icon_sort(d, s, w, True)),
        "icon_sort_desc_ca": stroke_icon(lambda d, s, w: icon_sort(d, s, w, False)),
        "icon_chevron_right_ca": stroke_icon(lambda d, s, w: chevron(d, s, w, "right")),
        "icon_chevron_left_ca": stroke_icon(lambda d, s, w: chevron(d, s, w, "left")),
        "icon_chevron_down_ca": stroke_icon(lambda d, s, w: chevron(d, s, w, "down")),
        "icon_chevrons_right_ca": stroke_icon(lambda d, s, w: (chevron(d, s, w, "right", -0.1), chevron(d, s, w, "right", 0.1))),
        "icon_chevrons_left_ca": stroke_icon(lambda d, s, w: (chevron(d, s, w, "left", -0.1), chevron(d, s, w, "left", 0.1))),
        "icon_inventory_ca": stroke_icon(icon_inventory),
        "icon_crate_ca": stroke_icon(icon_crate),
        "icon_ground_ca": stroke_icon(icon_ground),
        "icon_kit_ca": stroke_icon(icon_kit),
        "icon_check_ca": stroke_icon(icon_check),
        "icon_auto_ca": stroke_icon(icon_auto),
        "toggle_on_ca": toggle(True),
        "toggle_off_ca": toggle(False),
        "scroll_thumb_ca": scroll_thumb(),
        # The windows' glass, each for its own shape: the kit window (POUCH_W x POUCH_VISIBLE_H, in
        # rows of POUCH_H / 37) and the contents window (in rows of POPUP_ROW).
        "gloss_pouch_ca": gloss(1024, 1024, 1.1 * 37 / 0.95, 36, 0.6, 36 * 0.95 * 1080 / 37),
        "gloss_contents_ca": gloss(512, 1024, 14.9, 23.05, 0.6, 23.05 * 1080 / 40),
    }

    os.makedirs(OUT, exist_ok=True)
    tmp = tempfile.mkdtemp()
    for name, im in images.items():
        png = os.path.join(tmp, name + ".png")
        im.save(png)
        paa = os.path.join(OUT, name + ".paa")
        subprocess.run([tool, png, paa], check=True, capture_output=True)
        if not os.path.isfile(paa):
            raise SystemExit("ImageToPAA made nothing for " + name)
    print("%d textures written to %s" % (len(images), os.path.normpath(OUT)))


if __name__ == "__main__":
    main()
