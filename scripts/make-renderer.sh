rm ../dist/lib/render.min.js
declare -a js_report_list=(
  "../js/report-utils.js"
  "../js/report-settings.js"
  "../js/report-renderer.js"
)
uglifyjs $(IFS=" " ; echo "${js_report_list[*]}") -o ../dist/lib/render.min.js -c