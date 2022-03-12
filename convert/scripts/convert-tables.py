#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import re
import os
import commentjson as json
import glob
import subprocess
import yaml
from concurrent.futures import ProcessPoolExecutor


def loadPandocDefault(dataDir: str):
    # Settings general defaults
    pandocGeneralDefaults = os.path.join(dataDir, "defaults/pandoc-general.yaml")
    with open(pandocGeneralDefaults, "r") as f:
        return yaml.load(f, Loader=yaml.FullLoader)


def setEnvironment(dataDir: str):
    # Setting important env. variables
    filters = os.path.join(dataDir, "filters")
    s = os.environ.get("LUA_PATH")
    os.environ["LUA_PATH"] = "{0}/?;{0}/?.lua;{1}".format(filters, s if s else "")
    s = os.environ.get("PYTHONPATH")
    os.environ["PYTHONPATH"] = "{0}:{1}".format(filters, s if s else "")


def replaceColumnType(match):
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


def getStretchRegexes(spacing):
    return [(  # Set spacing for in between tabularnewline
        re.compile(r"\\tabularnewline"),
        r"\\tabularnewline\\addlinespace[{0}]".format(spacing),
    )]


def getFormat(file, pandocDefaults):
    ext = os.path.splitext(file)[1]

    if ext == ".html":
        return "html+tex_math_dollars"
    elif ext == ".tex":
        return "latex"
    elif ext == ".md":
        return pandocDefaults["from"]
    else:
        raise ValueError("Wrong format {0}".format(ext))


def getExtension(format):

    if "html" in format:
        return ".html"
    elif "latex" in format:
        return ".tex"
    elif "markdown" in format:
        return ".md"
    else:
        raise ValueError("Wrong format {0}".format(format))


def setLatexSpacing(output, spacing):
    startTag = "\\endhead"
    endTag = "\\bottomrule"

    start = output.find(startTag) + len(startTag)
    end = output.find(endTag)

    print("Found cell body between '{0}-{1}'".format(start, end))
    substring = output[start:end]

    for reg, repl in getStretchRegexes(spacing):
        substring = reg.sub(repl, substring)

    return output[0:start] + substring + output[end:]


def getColumnSizes(output, scaleToOne=False, scaleToFullMargin=0, columnRatios=None):
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


def setColumnFormat(output, widths, formats):
    
    # Remove all minipages
    reg = re.compile(r"\\end\{minipage\}")
    output = reg.sub(r"", output)

    reg = re.compile(r"\\begin\{minipage\}.*")
    return reg.sub(r"", output)


def deleteEmptyLines(output):
    reg = re.compile(r"^\s*\n", re.MULTILINE)
    return reg.sub("", output)


def postProcessLatexTables(config, output):
    print("Post-process latex tables ...")
    r = re.compile(r"\\begin\{longtable\}.*?\\end\{longtable\}", re.DOTALL)

    def postProcessLatexTable(match):
        table = match.group(0)

        # Count column sized
        widths, formats = getColumnSizes(table, config.get("scaleColumnsToFull", False),
                                         config.get("scaleColumnsToFullMargin", 0.0),
                                         config.get("columnRatios", None))

        table = setColumnFormat(table, widths, formats)

        # Stretch cell rows in latex output
        spacing = config.get("rowSpacing")
        if spacing:
            print("Apply spacing ...")
            table = setLatexSpacing(table, spacing)

        return deleteEmptyLines(table)

    return r.sub(postProcessLatexTable, output)


def convertTable(file, config, rootDir, dataDir, pandocDefaults):

    fromFormat = config["from"] if "from" in config else getFormat(file, pandocDefaults)
    toFormat = config["to"]
    toExt = getExtension(toFormat)

    # Make output file
    baseName, ext = os.path.splitext(os.path.split(file)[1])
    outputDir = config["outputDir"].format(rootDir=rootDir, ext=toExt[1:])
    outFile = os.path.join(outputDir, baseName + toExt)

    # Run pandoc
    print("--------------------------------------------------------------")
    print("Converting '{0}' -> '{1}' [{2} -> {3}]".format(file, outFile, fromFormat, toFormat))

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
    ], encoding="utf-8")

    # Pre save...
    with open(outFile, "w") as o:
        o.write(output)

    # Modify regexes
    if config.get("defaultPostProcessing"):
        regs = defaultTableRegexes.get(toFormat, [])
        for reg, repl in regs:
            print("Apply default output regexes ...")
            output = reg.sub(repl, output)

    if toFormat == "latex":
        output = postProcessLatexTables(config, output)

    with open(outFile, "w") as o:
        o.write(output)


def convertTables(config, rootDir, dataDir, pandocDefaults):

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

    setEnvironment(dataDir)
    pandocDefaults = loadPandocDefault(dataDir)

    if parallel:
        with ProcessPoolExecutor() as executor:
            executor.map(lambda x: convertTables(x, rootDir, dataDir, pandocDefaults), configs)
    else:
        for c in configs:
            convertTables(c, rootDir, dataDir, pandocDefaults)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--data-dir',
        required=True,
        help="Pandoc data directory."
    )
    parser.add_argument(
        '--root-dir',
        required=True,
        help="The repository with the source."
    )
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
