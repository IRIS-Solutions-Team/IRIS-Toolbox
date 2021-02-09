# install NPM packages needed for bundling
# npm i -g inline-source-cli uglify-es clean-css-cli

# clean create ./dist folder
rm -rf ../dist
mkdir -p ../dist/lib

# minify, concat and copy all vendor scripts into one ./dist/lib/vendor.min.js
declare -a js_vendor_list_no_plotly=(
  "../js/vendor/jquery.min.js"
  "../js/vendor/what-input.js"
  "../js/vendor/foundation.min.js"
  "../js/vendor/moment.min.js"
  "../js/vendor/Chart.min.js"
  "../js/vendor/chartjs-plugin-annotation.min.js"
  "../js/vendor/katex.min.js"
  "../js/vendor/auto-render.min.js"
  "../js/vendor/marked.min.js"
  "../js/vendor/highlight.min.js"
)
declare -a js_vendor_list=("${js_vendor_list_no_plotly[@]}" "../js/vendor/plotly.min.js")
uglifyjs $(IFS=" " ; echo "${js_vendor_list[*]}") -o ../dist/lib/vendor.min.js -c
uglifyjs $(IFS=" " ; echo "${js_vendor_list_no_plotly[*]}") -o ../dist/lib/vendor-no-plotly.min.js -c

# minify, concat and copy all vendor styles into one ./dist/lib/vendor.min.css
declare -a css_vendor_list=(
  "../css/foundation.min.css"
  "../css/katex-embed-fonts.min.css"
  "../css/highlight.min.css"
)
cleancss -o ../dist/lib/vendor.min.css $(IFS=" " ; echo "${css_vendor_list[*]}")

# minify main report CSS file and copy it together with the example 
# of custom.css to ./dist
cleancss -o ../dist/lib/report.min.css ../css/main.css
cp ../css/custom.css ../dist/user-defined.css

# minify, concat and copy all report rendering scripts into one ./dist/lib/render.min.js
declare -a js_report_list=(
  "../js/report-utils.js"
  "../js/report-settings.js"
  "../js/report-renderer.js"
)
uglifyjs $(IFS=" " ; echo "${js_report_list[*]}") -o ../dist/lib/render.min.js -c

# copy IRIS logo to ./dist/img/
mkdir -p ../dist/img
cp ../img/iris-logo.png ../dist/img/iris-logo.png

# preprocess html replacing vendor and report <script> and <link>
# tags with the references to their bundles
cp ../report-template.html ../dist/report-template.html
python replace-refs.py $1

# create bundled version of HTML
cd ../dist
inline-source --compress true report-template.html report-template.bundle.html
inline-source --compress true report-template-no-plotly.html report-template-no-plotly.bundle.html