

all_dirs="./StructuralModeling/@Model"

for d in $all_dirs; do
    all_md_files=$(find $d -name "*.md")
    for md in $all_md_files; do
        mfile=${md%".md"}.m
        if [[ -f $mfile ]]; then
            echo $md
            python .scripts/insert_help.py $mfile $md
        fi
    done
done

