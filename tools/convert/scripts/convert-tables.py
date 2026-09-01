#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import re
import os
import commentjson as json
import glob
import subprocess
import yaml
from os import path
from concurrent.futures import ProcessPoolExecutor


def load_pandoc_default(dataDir: str):
    # Settings general defaults
    pandocGeneralDefaults = os.path.join(dataDir,
                                         "defaults/pandoc-general.yaml")
    with open(pandocGeneralDefaults, "r") as f:
        return yaml.load(f, Loader=yaml.FullLoader)


def set_environment(dataDir: str):
    # Setting important env. variables
    filters = os.path.join(dataDir, "filters")
    s = os.environ.get("PYTHONPATH")
    os.environ["PYTHONPATH"] = "{0}:{1}".format(filters, s if s else "")


def replace_column_type(match):
    columns = ""
    for c in match.group(2):
        columns += "S" + c
    return match.group(1) + columns + match.group(3)


defaultTableRegexes = {
    "latex": [
        (  # Remove pandoc inserted struct
            re.compile(r"\\end\{itemize\}\\strut"),
            r"\\end{itemize}",
        ),
        (  # Remove \endfirsthead, its not needed
            re.compile(r"\\endfirsthead.*?\\endhead", re.DOTALL),
            r"\\endhead",
        )
    ]
}


def get_stretch_regexes(spacing):
    return [(  # Set spacing for in between tabularnewline
        re.compile(r"\\tabularnewline"),
        r"\\tabularnewline\\addlinespace[{0}]".format(spacing),
    )]


def get_format(file, pandocDefaults):
    ext = os.path.splitext(file)[1]

    if ext == ".html":
        return "html+tex_math_dollars"
    elif ext == ".tex":
        return "latex"
    elif ext == ".md":
        return pandocDefaults["from"]
    else:
        raise ValueError("Wrong format {0}".format(ext))


def get_extension(format):

    if "html" in format:
        return ".html"
    elif "latex" in format:
        return ".tex"
    elif "markdown" in format:
        return ".md"
    else:
        raise ValueError("Wrong format {0}".format(format))


def set_latex_spacing(output, spacing):
    startTag = "\\endhead"
    endTag = "\\bottomrule"

    start = output.find(startTag) + len(startTag)
    end = output.find(endTag)

    print("Found cell body between '{0}-{1}'".format(start, end))
    substring = output[start:end]

    for reg, repl in get_stretch_regexes(spacing):
        substring = reg.sub(repl, substring)

    return output[0:start] + substring + output[end:]


def get_column_sizes(output,
                     scaleToOne=False,
                     scaleToFullMargin=0,
                     columnRatios=None):
    endTag = "\\endhead"
    end = output.find(endTag)

    widths = []
    formats = []

    if end < 0:
        return widths, formats

    # Extract all widths
    part = output[0:end]
    r = re.compile(r">\{(.*)\}.*p\{.*\\real\{(\d+(?:\.\d+)?)\}\}")

    for m in r.finditer(part):
        w = float(m.group(2))
        widths.append(w)

        formats.append(m.group(1))

    if len(widths) == 0:
        raise ValueError(f"Regex failed {r.pattern}")

    # Overwrite by new column ratios
    if columnRatios:
        assert len(columnRatios) == len(widths)
        totalWidth = sum(columnRatios)
        widths = [c / float(totalWidth) for c in columnRatios]
        print("Set ratios to '{0}'".format(widths))

    if scaleToOne or columnRatios:
        print("Scale to full width ...")
        totalWidth = sum(widths)
        scale = (1.0 - scaleToFullMargin) / totalWidth
        widths = [w * scale for w in widths]

    print("Found widths [tot: '{0}'] '{1}'".format(sum(widths), widths))
    print("Found formats '{0}'".format(formats))

    return widths, formats


def set_column_format(output, widths, formats):

    # Remove all minipages
    reg = re.compile(r"\\end\{minipage\}")
    output = reg.sub(r"", output)

    reg = re.compile(r"\\begin\{minipage\}.*")
    return reg.sub(r"", output)


def delete_empty_lines(output):
    reg = re.compile(r"^\s*\n", re.MULTILINE)
    return reg.sub("", output)


def add_mid_rules(match):
    s = match.group(0)
    count = s.count(r"\\")
    return s.replace(r"\\", r"\\ \midrule" + "\n", count - 1)


def post_process_latex_tables(config, output):
    print("Post-process latex tables ...")
    rTable = re.compile(r"\\begin\{longtable\}.*?\\end\{longtable\}", re.DOTALL)
    rLines = re.compile(r"\\endlastfoot.*?\\end\{longtable\}", re.DOTALL)

    def postProcessLatexTable(match):
        table = match.group(0)

        # Count column sized
        widths, formats = get_column_sizes(
            table, config.get("scaleColumnsToFull", False),
            config.get("scaleColumnsToFullMargin", 0.0),
            config.get("columnRatios", None))

        table = set_column_format(table, widths, formats)

        # Stretch cell rows in latex output
        spacing = config.get("rowSpacing")
        if spacing:
            print("Apply spacing ...")
            table = set_latex_spacing(table, spacing)

        table = delete_empty_lines(table)

        if config.get("addMidRules", False):
            table = rLines.sub(add_mid_rules, table)

        return table

    return rTable.sub(postProcessLatexTable, output)


def convertTable(file, config, rootDir, dataDir, pandocDefaults):

    fromFormat = config["from"] if "from" in config else get_format(
        file, pandocDefaults)
    toFormat = config["to"]
    toExt = get_extension(toFormat)

    # Make output file
    baseName, ext = os.path.splitext(os.path.split(file)[1])
    outputDir = config["outputDir"].format(rootDir=rootDir, ext=toExt[1:])
    outFile = os.path.join(outputDir, baseName + toExt)

    # Run pandoc
    print("--------------------------------------------------------------")
    print("Converting '{0}' -> '{1}' [{2} -> {3}]".format(
        file, outFile, fromFormat, toFormat))

    output = subprocess.check_output([
        "pandoc",
        "--fail-if-warnings",
        "--verbose",
        f"--data-dir={dataDir}",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-table.yaml",
        "--defaults=pandoc-filters.yaml",
    ] + config.get("pandocArgs", []) + [
        "-f",
        fromFormat,
        "-t",
        toFormat,
        file,
    ],
                                     encoding="utf-8")

    # Pre save...
    os.makedirs(path.dirname(outFile), exist_ok=True)
    with open(outFile, "w") as o:
        o.write(output)

    # Modify regexes
    if config.get("defaultPostProcessing"):
        regs = defaultTableRegexes.get(toFormat, [])
        for reg, repl in regs:
            print("Apply default output regexes ...")
            output = reg.sub(repl, output)

    if toFormat == "latex":
        output = post_process_latex_tables(config, output)

    with open(outFile, "w") as o:
        o.write(output)


def convert_tables(config, rootDir, dataDir, pandocDefaults):

    globs = config["globs"]
    if isinstance(globs, str):
        globs = [globs]

    # Get all files by globbing
    files = []
    for g in globs:

        # Replace 'rootDir'
        g = g.format(rootDir=rootDir)
        # Get files
        files += glob.glob(g, recursive=True)

    for f in files:
        convertTable(f, config, rootDir, dataDir, pandocDefaults)


def run(configs, rootDir, dataDir, parallel=False):

    set_environment(dataDir)
    pandocDefaults = load_pandoc_default(dataDir)

    if parallel:
        with ProcessPoolExecutor() as executor:
            for r in executor.map(
                    lambda x: convert_tables(x, rootDir, dataDir, pandocDefaults
                                             ), configs):
                pass
    else:
        for c in configs:
            convert_tables(c, rootDir, dataDir, pandocDefaults)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--data-dir',
                        required=True,
                        help="Pandoc data directory.")
    parser.add_argument('--root-dir',
                        required=True,
                        help="The repository with the source.")
    parser.add_argument(
        '--config',
        required=True,
        help='Config file with tables to convert.',
    )

    parser.add_argument(
        '--parallel',
        action="store_true",
        help='Config file with tables',
    )

    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = json.load(f)

    run(config, dataDir=args.data_dir, rootDir=args.root_dir, parallel=False)
