#!/usr/bin/env python3
# Generate the images of the installer from the ViAI logo.
#
# Requires pycairo, Pillow, the DejaVu Sans font and a ViAI source tree for
# tools/viai_logo.py.  Run from anywhere:
#	python3 nsis/icons/viai_images.py [VIAI_DIR]
# VIAI_DIR defaults to ../viai next to this repository.
#
# Writes into the directory of this script:
#	in_welcome.bmp, un_welcome.bmp	328 x 628
#	in_header.bmp, un_header.bmp	300 x 114
#	in_viai_32bpp.ico, un_viai_32bpp.ico
# The uninstaller uses grayscale images and a crossed out icon.

import importlib.util
import io
import math
import os
import sys

import cairo
from PIL import Image, ImageOps

ICONS_DIR = os.path.dirname(os.path.abspath(__file__))
TOP_DIR = os.path.dirname(os.path.dirname(ICONS_DIR))

BG = (0xe8, 0xf3, 0xec)
SUB = (0x2b, 0x7a, 0x52)
FONT = 'DejaVu Sans'
TAGLINE = 'Vim Advanced Integrated'
ICO_SIZES = (256, 128, 48, 32, 16)
CROSS_COLOR = (0xe0, 0x10, 0x10)


def load_logo(viai_dir):
    path = os.path.join(viai_dir, 'tools', 'viai_logo.py')
    spec = importlib.util.spec_from_file_location('viai_logo', path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def to_image(surf):
    buf = io.BytesIO()
    surf.write_to_png(buf)
    buf.seek(0)
    return Image.open(buf).convert('RGBA')


def rgb(ctx, color):
    ctx.set_source_rgb(*[c / 255 for c in color])


def text(ctx, s, size, color, x=None, cx=None, y=0):
    ctx.select_font_face(FONT, cairo.FONT_SLANT_NORMAL,
                         cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(size)
    ext = ctx.text_extents(s)
    if cx is not None:
        x = cx - ext.width / 2 - ext.x_bearing
    rgb(ctx, color)
    ctx.move_to(x, y)
    ctx.show_text(s)


def fit_size(ctx, s, size, width):
    # largest font size, in steps of 0.5, for which "s" fits in "width"
    ctx.select_font_face(FONT, cairo.FONT_SLANT_NORMAL,
                         cairo.FONT_WEIGHT_BOLD)
    while True:
        ctx.set_font_size(size)
        if ctx.text_extents(s).x_advance <= width:
            return size
        size -= 0.5


def banner(logo, w, h, layout):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    rgb(ctx, BG)
    ctx.paint()
    logo_size, logo_x, logo_y = layout(ctx)
    im = to_image(surf)
    im.alpha_composite(logo.render(logo_size), (logo_x, logo_y))
    return im.convert('RGB')


def welcome(logo):
    w, h = 328, 628

    def layout(ctx):
        text(ctx, 'ViAI', 64, logo.BLOCK_COLOR, cx=w / 2, y=470)
        text(ctx, TAGLINE, 21, SUB, cx=w / 2, y=510)
        return 220, (w - 220) // 2, 175
    return banner(logo, w, h, layout)


def header(logo):
    w, h = 300, 114

    def layout(ctx):
        text(ctx, 'ViAI', 44, logo.BLOCK_COLOR, x=118, y=62)
        text(ctx, TAGLINE, fit_size(ctx, TAGLINE, 13, w - 125), SUB,
             x=119, y=86)
        return 96, 10, 9
    return banner(logo, w, h, layout)


def gray(im):
    return ImageOps.grayscale(im).convert('RGB')


def crossed(logo, size):
    im = logo.render(size)
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
    ctx = cairo.Context(surf)
    lw = max(size * 0.075, 1.5)
    r = size / 2 - lw / 2
    rgb(ctx, CROSS_COLOR)
    ctx.set_line_width(lw)
    ctx.arc(size / 2, size / 2, r, 0, 2 * math.pi)
    ctx.stroke()
    d = r / math.sqrt(2)
    ctx.move_to(size / 2 - d, size / 2 - d)
    ctx.line_to(size / 2 + d, size / 2 + d)
    ctx.stroke()
    im.alpha_composite(to_image(surf))
    return im


def save_ico(images, path):
    images[0].save(path, sizes=[im.size for im in images],
                   append_images=images[1:])


def main():
    viai_dir = (sys.argv[1] if len(sys.argv) > 1
                else os.path.join(os.path.dirname(TOP_DIR), 'viai'))
    logo = load_logo(viai_dir)

    wl = welcome(logo)
    wl.save(os.path.join(ICONS_DIR, 'in_welcome.bmp'))
    gray(wl).save(os.path.join(ICONS_DIR, 'un_welcome.bmp'))
    hd = header(logo)
    hd.save(os.path.join(ICONS_DIR, 'in_header.bmp'))
    gray(hd).save(os.path.join(ICONS_DIR, 'un_header.bmp'))

    save_ico([logo.render(s) for s in ICO_SIZES],
             os.path.join(ICONS_DIR, 'in_viai_32bpp.ico'))
    save_ico([crossed(logo, s) for s in ICO_SIZES],
             os.path.join(ICONS_DIR, 'un_viai_32bpp.ico'))


if __name__ == '__main__':
    main()
