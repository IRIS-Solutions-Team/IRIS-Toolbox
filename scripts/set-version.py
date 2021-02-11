import re
import argparse

# parse input arguments
parser = argparse.ArgumentParser()
parser.add_argument("version", help="release version of the bundle")
args = parser.parse_args()
ver = args.version

suffixes = ["", "-no-plotly"]

for sfx in suffixes:
    f_name = "../dist/report-template-web-source" + sfx + ".html"
    with open(f_name, "r") as f:
        html = f.read()
    html = re.sub("#VERSION#", ver, html, flags=re.DOTALL | re.MULTILINE)
    with open(f_name, "w") as f:
        f.write(html)
