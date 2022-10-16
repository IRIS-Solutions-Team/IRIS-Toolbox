
function get_dirs_to_populate {
    ggrep -rFl "populate: true" --inc=index.md $iris | xargs dirname
}


function insert_topic {
    folder=$1

    # Get the topic from the index file, add parentheses
    topic=$(ggrep -Po '(?<=^topic: ).*' -m 1 $folder/index.md)

    # Add topic to H1 line in each md file in the current directory
    if [[ "_$topic" != "_" ]]; then
        topic="^^("$topic")^^"
        find $folder -maxdepth 1 -name '*md' | xargs gsed -i 's/^#\s*`\(.*\)`.*/# `\1` '$topic/
    fi
}


for folder in $(get_dirs_to_populate); do
    echo $folder
    insert_topic $folder
    python ./.scripts/populate_index.py $folder/index.md
done


