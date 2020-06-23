import re

# load HTML files
with open("../dist/report-template.html", "r") as f:
    html = f.read()
# replace vendor CSS block
html = re.sub(
    "<!\-\- build:vendor:css \-\->.*<!\-\- endbuild:vendor:css \-\->",
    '<link rel="stylesheet" inline href="lib/vendor.min.css">',
    html,
    flags=re.DOTALL|re.MULTILINE,
)
# replace vendor JS block
html = re.sub(
    "<!\-\- build:vendor:js \-\->.*<!\-\- endbuild:vendor:js \-\->",
    '<script inline src="lib/vendor.min.js"></script>',
    html,
    flags=re.DOTALL|re.MULTILINE,
)
# replace report JS block
html = re.sub(
    "<!\-\- build:report:js \-\->.*<!\-\- endbuild:report:js \-\->",
    '<script inline src="lib/render.min.js"></script>',
    html,
    flags=re.DOTALL|re.MULTILINE,
)
# replace report data JS block
html = re.sub(
    "<!\-\- build:data:js \-\->.*<!\-\- endbuild:data:js \-\->",
    '<script>// report-data-script-here</script>',
    html,
    flags=re.DOTALL|re.MULTILINE,
)
# replace main and custom CSS links
html = re.sub(
    "<!\-\- build:report:css \-\->.*<!\-\- endbuild:report:css \-\->",
    '<link rel="stylesheet" inline href="lib/report.min.css">',
    html,
    flags=re.DOTALL|re.MULTILINE,
)
html = re.sub(
    "<!\-\- build:user:css \-\->.*<!\-\- endbuild:user:css \-\->",
    '<link rel="stylesheet" href="user-defined.css">',
    html,
    flags=re.DOTALL|re.MULTILINE,
)

# save adjusted HTML file
with open("../dist/report-template.html", "w") as f:
    f.write(html)

# create and save "no-plotly" version
html = re.sub(
    "lib/vendor\.min\.js",
    "lib/vendor-no-plotly.min.js",
    html,
    flags=re.DOTALL|re.MULTILINE,
)
with open("../dist/report-template-no-plotly.html", "w") as f:
    f.write(html)