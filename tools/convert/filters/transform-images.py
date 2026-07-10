#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Pandoc filter to convert image includes to latex commands:
    - `\\imageWithCaption` or `\\svgWithCaption` (for `.svg` extensions)
    - or `\\includePDF` if class attribute `includepdf`
      Attribute `pages=s-e` defines which pages to include.
      The start and end page `s,e` can be omitted to include from the beginning
      or up to the last page.
"""

import sys
import os
import yaml
import subprocess
from typing import Union
from panflute import Doc, Element, Image, RawInline, run_filter
from module.utils import log

assert sys.version_info >= (3, 0)

fName = "tfImg"


def latexblock(code):
    return RawInline(code, format="tex")


def include_image(
    attributes,
    baseCommand,
    url,
    caption,
    graphicsOpts,
    label=None,
):

    opts = ["{0}={1}".format(k, v) for k, v in graphicsOpts.items()]

    return [
        latexblock(r"\{0}{{{1}}}{{".format(baseCommand, url)),
        *caption,
        latexblock(r"}}{{{0}}}[{1}]".format(",".join(opts), label))
    ]


def get_pdf_pages(url):
    pages = None
    try:
        cmd = None
        if sys.platform == "linux":
            cmd = ["pdfinfo", url]
            info = yaml.safe_load(subprocess.check_output(cmd))
            pages = info.get("Pages", None)
            if not pages:
                pages = info.get("pages", None)
        elif sys.platform == "darwin":
            cmd = ["mdls", "-name", "kMDItemNumberOfPages", "-raw", url]
            pages = int(subprocess.check_output(cmd, encoding="utf-8").strip())

    except Exception as e:
        log("Command '{0}' failed for '{1}':", fName, cmd, url)
        log(str(e), fName)

    return pages if pages else None


def include_pdf(
    attributes,
    baseCommand,
    url,
    caption,
    graphicsOpts,
    label=None,
):

    pages = attributes.get("pages", None)  # Insert all pages
    pageStart = 1

    try:
        if not pages:
            pageEnd = get_pdf_pages(url)
        else:
            if "-" in pages:
                p = pages.split("-")
                if p[0]:
                    pageStart = int(p[0])

                if p[1]:
                    pageEnd = int(p[1])
                else:
                    pageEnd = get_pdf_pages(url)
            else:
                pageEnd = int(p)
    except ValueError:
        raise ValueError("Wrong pages attribute '{0}' for '{1}'".format(
            pages,
            url,
        ))

    if not pageEnd:
        log(
            "You need to specify the pages atrribute as 'pages=[<start-page>-]<end-page>",
            fName,
        )
        raise ValueError("Pages could not be determined")

    if "width" not in graphicsOpts:
        graphicsOpts["width"] = r"\textwidth"

    opts = ["{0}={1}".format(k, v) for k, v in graphicsOpts.items()]

    log(" - page start: {0}, page end {1}", fName, pageStart, pageEnd)
    return [
        latexblock(r"\{0}{{{1}}}[{2}]{{{3}}}[{4}]".format(
            baseCommand,
            url,
            str(pageStart),
            str(pageEnd),
            ",".join(opts),
        )),
    ]


def transform_img_to_latex(image: Image):

    url = image.url
    label = image.identifier
    caption = image.content

    log("Transforming image '{0}' to latex ...", fName, url)

    # Set `/fig.png` to `./fig.png`
    if os.path.isabs(url):
        url = "." + os.path.splitdrive(url)[1]

    baseCommand = None
    blockBuilder = None
    graphicsOpts = {}

    if "includepdf" in image.classes:
        baseCommand = r"includePDF"
        blockBuilder = include_pdf
    else:
        baseCommand = r"imageWithCaption"
        if os.path.splitext(url)[1] == ".svg":
            baseCommand = r"svgWithCaption"
        blockBuilder = include_image

    # Parse witdh/height
    def to_scaling(size: Union[str, None], proportionalTo: str):
        if size and "%" in size:
            s = float(size.strip().replace("%", "")) / 100.0
            return "{0}{1}".format(s, proportionalTo)
        else:
            return size

    width = to_scaling(
        image.attributes.get("width", None),
        proportionalTo=r"\textwidth",
    )
    height = to_scaling(
        image.attributes.get("height", None),
        proportionalTo=r"\textwidth",
    )

    log(" - height: {0}, width: {1}", fName, height, width)

    if width:
        graphicsOpts["width"] = "{0}".format(width)
    if height:
        graphicsOpts["height"] = "{0}".format(height)

    return blockBuilder(
        image.attributes,
        baseCommand,
        url,
        caption,
        graphicsOpts,
        label,
    )


def transform_images(elem: Element, doc: Doc):
    if doc.format == "latex":
        if isinstance(elem, Image):
            return transform_img_to_latex(elem)


def main(doc: Doc = None):
    return run_filter(transform_images, doc=doc)


if __name__ == "__main__":
    main()
