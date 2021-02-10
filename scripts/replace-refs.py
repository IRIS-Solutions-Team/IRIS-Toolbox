import re
import argparse

# parse input arguments
parser = argparse.ArgumentParser()
parser.add_argument("version", help="release version of the bundle")
args = parser.parse_args()
ver = args.version

# load HTML files
with open("../dist/report-template.html", "r") as f:
    html = f.read()
html_web = html
# replace vendor CSS block
html = re.sub(
    "<!\-\- build:vendor:css \-\->.*<!\-\- endbuild:vendor:css \-\->",
    '<link rel="stylesheet" inline href="lib/vendor.min.css">',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:vendor:css \-\->.*<!\-\- endbuild:vendor:css \-\->",
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/OGResearch/rephrase@'
    + ver
    + '/dist/lib/vendor.min.css">',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
# replace vendor JS block
html = re.sub(
    "<!\-\- build:vendor:js \-\->.*<!\-\- endbuild:vendor:js \-\->",
    '<script inline src="lib/vendor.min.js"></script>',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:vendor:js \-\->.*<!\-\- endbuild:vendor:js \-\->",
    '<script src="https://cdn.jsdelivr.net/gh/OGResearch/rephrase@'
    + ver
    + '/dist/lib/vendor.min.js"></script>',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
# replace report JS block
html = re.sub(
    "<!\-\- build:report:js \-\->.*<!\-\- endbuild:report:js \-\->",
    '<script inline src="lib/render.min.js"></script>',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:report:js \-\->.*<!\-\- endbuild:report:js \-\->",
    '<script src="https://cdn.jsdelivr.net/gh/OGResearch/rephrase@'
    + ver
    + '/dist/lib/render.min.js"></script>',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
# replace report data JS block
html = re.sub(
    "<!\-\- build:data:js \-\->.*<!\-\- endbuild:data:js \-\->",
    "<script>// report-data-script-here</script>",
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:data:js \-\->.*<!\-\- endbuild:data:js \-\->",
    "<script>// report-data-script-here</script>",
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
# replace main and custom CSS links
html = re.sub(
    "<!\-\- build:report:css \-\->.*<!\-\- endbuild:report:css \-\->",
    '<link rel="stylesheet" inline href="lib/report.min.css">',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:report:css \-\->.*<!\-\- endbuild:report:css \-\->",
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/OGResearch/rephrase@'
    + ver
    + '/dist/lib/report.min.css">',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
html = re.sub(
    "<!\-\- build:user:css \-\->.*<!\-\- endbuild:user:css \-\->",
    '<style>/* user-defined-css-here */</style>',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:user:css \-\->.*<!\-\- endbuild:user:css \-\->",
    '<style>/* user-defined-css-here */</style>',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
# replace logo image source
html = re.sub(
    "<!\-\- build:logo:img \-\->.*<!\-\- endbuild:logo:img \-\->",
    '<img inline class="report-default-logo" src="img/iris-logo.png">',
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "<!\-\- build:logo:img \-\->.*<!\-\- endbuild:logo:img \-\->",
    '<img class="report-default-logo" src="https://cdn.jsdelivr.net/gh/OGResearch/rephrase@'
    + ver
    + '/dist/img/iris-logo.png">',
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)

# save adjusted HTML file
with open("../dist/report-template.html", "w") as f:
    f.write(html)

# save adjusted HTML file with the web source
with open("../dist/report-template-web-source.html", "w") as f:
    f.write(html_web)

# create and save "no-plotly" version
html = re.sub(
    "lib/vendor\.min\.js",
    "lib/vendor-no-plotly.min.js",
    html,
    flags=re.DOTALL | re.MULTILINE,
)
html_web = re.sub(
    "lib/vendor\.min\.js",
    "lib/vendor-no-plotly.min.js",
    html_web,
    flags=re.DOTALL | re.MULTILINE,
)
with open("../dist/report-template-no-plotly.html", "w") as f:
    f.write(html)
with open("../dist/report-template-web-source-no-plotly.html", "w") as f:
    f.write(html_web)
