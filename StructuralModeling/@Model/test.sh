
echo -e "{%\n" > _start_md
echo -e "%}\n" > _end_md

function cat_md_m {
    cat _start_md $1 _end_md $2 | tee $2 > /dev/null
}

for m in $(find . -name *.m); do
    md = $m"d"
    if [[ -e $md ]]; then
        cat_md_m $md $m
    fi
done


