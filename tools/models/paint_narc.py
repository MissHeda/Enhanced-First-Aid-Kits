"""Paints the narc box atlas (narcbox_co.png, narcbox_nohq.png), regions as in make_narc.py."""
import random
from PIL import Image, ImageDraw, ImageFilter, ImageFont

S = 2048
random.seed(7)


def px(r):
    return tuple(int(c * S) for c in r)


def noise(size, base, amp, blur=0.6, seed=1):
    rnd = random.Random(seed)
    im = Image.effect_noise(size, 64).filter(ImageFilter.GaussianBlur(blur))
    im = im.point(lambda v: max(0, min(255, int(base + (v - 128) / 128 * amp))))
    return im


def plastic(size, base=34, seed=1):
    # moulded black plastic: fine stipple plus a faint larger mottling
    fine = noise(size, base, 5, 0.7, seed)
    coarse = noise((max(1, size[0] // 32), max(1, size[1] // 32)), 0, 3, 0.0, seed + 1).resize(size, Image.BICUBIC)
    g = Image.merge("RGB", [Image.eval(Image.blend(fine, coarse, 0.0), lambda v: v)] * 3)
    arr = Image.new("RGB", size, (base, base, base + 2))
    return Image.blend(arr, g, 0.85)


co = plastic((S, S), 30, 3)
d = ImageDraw.Draw(co)

# latch front: slightly lighter, with grip ribs
x0, y0, x1, y1 = px((0.5, 0.25, 0.75, 0.5))
co.paste(plastic((x1 - x0, y1 - y0), 44, 5), (x0, y0))
for k in range(14):
    yy = y0 + int((y1 - y0) * (0.14 + k * 0.052))
    d.rectangle([x0 + 40, yy, x1 - 40, yy + 6], fill=(26, 26, 28))
    d.rectangle([x0 + 40, yy + 7, x1 - 40, yy + 9], fill=(58, 58, 60))

# metal and padlock tab
x0, y0, x1, y1 = px((0.75, 0.25, 1.0, 0.375))
m = Image.effect_noise((x1 - x0, y1 - y0), 40).filter(ImageFilter.BoxBlur(1)).resize((x1 - x0, y1 - y0))
m = m.transform(m.size, Image.AFFINE, (1, 0, 0, 0, 0.02, 0)).point(lambda v: int(110 + (v - 128) * 0.25))
co.paste(Image.merge("RGB", [m] * 3), (x0, y0))
x0, y0, x1, y1 = px((0.75, 0.375, 1.0, 0.5))
co.paste(plastic((x1 - x0, y1 - y0), 40, 9), (x0, y0))
w, h = x1 - x0, y1 - y0
d.rounded_rectangle([x0 + w * 0.22, y0 + h * 0.32, x0 + w * 0.78, y0 + h * 0.62], radius=int(w * 0.12),
                    fill=(150, 150, 155), outline=(90, 90, 95), width=6)
d.rounded_rectangle([x0 + w * 0.36, y0 + h * 0.40, x0 + w * 0.64, y0 + h * 0.54], radius=int(w * 0.06),
                    fill=(8, 8, 9))

# rubber (handle grip, feet)
x0, y0, x1, y1 = px((0.0, 0.5, 0.25, 0.75))
co.paste(plastic((x1 - x0, y1 - y0), 22, 11), (x0, y0))

# label: white, red frame, red cross, text
x0, y0, x1, y1 = px((0.5, 0.0, 1.0, 0.25))
w, h = x1 - x0, y1 - y0
lab = Image.new("RGB", (w, h), (226, 224, 216))
ld = ImageDraw.Draw(lab)
red = (176, 30, 34)
ld.rectangle([0, 0, w - 1, h - 1], outline=red, width=26)
ld.rectangle([40, 40, w - 41, h - 41], outline=red, width=6)
cx, cy, a = 150, h // 2, 70
ld.rectangle([cx - a, cy - a // 3, cx + a, cy + a // 3], fill=red)
ld.rectangle([cx - a // 3, cy - a, cx + a // 3, cy + a], fill=red)


def font(size, bold=True):
    for name in (("arialbd.ttf" if bold else "arial.ttf"), "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


ld.text((262, 100), "NARCOTICS", font=font(118), fill=red)
ld.text((268, 250), "CONTROLLED SUBSTANCES", font=font(46), fill=(30, 30, 32))
ld.text((268, 330), "AUTHORISED MEDICAL PERSONNEL ONLY", font=font(31, False), fill=(30, 30, 32))
# wear: a little grime and scuffs
grime = Image.effect_noise((w, h), 50).filter(ImageFilter.GaussianBlur(6)).point(lambda v: max(0, v - 150) * 2)
lab = Image.composite(Image.new("RGB", (w, h), (150, 145, 132)), lab, grime)
co.paste(lab, (x0, y0))

co = co.filter(ImageFilter.GaussianBlur(0.4))
co.save("narcbox_co.png")

# normal map: flat with a fine stipple on the plastic
hgt = Image.effect_noise((S, S), 64).filter(ImageFilter.GaussianBlur(1.2))
# keep label, lock and latch faces flat
fl = Image.new("L", (S, S), 128)
mask = Image.new("L", (S, S), 255)
md = ImageDraw.Draw(mask)
md.rectangle(px((0.5, 0.0, 1.0, 0.5)), fill=0)
hgt = Image.composite(hgt, fl, mask)
import numpy as np
h = np.asarray(hgt, dtype=np.float32) / 255.0
k = 0.6
dx = (np.roll(h, -1, 1) - np.roll(h, 1, 1)) * k
dy = (np.roll(h, -1, 0) - np.roll(h, 1, 0)) * k
nm = Image.fromarray(np.dstack([128 - dx * 127, 128 - dy * 127, np.full_like(h, 255)]).clip(0, 255).astype(np.uint8))
nm.save("narcbox_nohq.png")
print("ok")
