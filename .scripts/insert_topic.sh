#
# In each non-index md file in the directory, add the topic to the H1
# heading
#
# # `function` ^^(topic)^^
# 
# The topic is hidden in .md-typeset but show in search results
#


# Get the topic from the index file, add parentheses
topic=$(ggrep -Po '(?<=^topic: ).*' -m 1 index.md)
echo $topic


# Add topic to H1 line in each md file in the current directory
if [[ "_$topic" != "_" ]]; then
    topic="^^("$topic")^^"
    find . -maxdepth 1 -name '*md' | xargs gsed -i 's/^#\s*`\(.*\)`.*/# `\1` '$topic/
fi


