

ggrep -zrl 'title:[^-]*\s*---\s*{==' -m 1 --inc=*md . \
    | xargs python .scripts/insert_summary.py 

