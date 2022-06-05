function ihelp(name, maxLines)

try, maxLines = double(string(maxLines));
    catch, maxLines = Inf; end

resolved = string(which(name));
[path, title, ~] = fileparts(resolved);
mdPath = fullfile(string(path), string(title) + ".md");

if ~exist(mdPath, "file")
    exception.error([
        "Help"
        "No help file exists in IrisT for this file: %s"
    ], name);
end

mdContent = fileread(mdPath);

mdContent = regexprep(mdContent, "\n{4,}", "\n\n\n");
mdContent = regexprep(mdContent, "^---.*?---", "");
mdContent = regexprep(mdContent, "^\s+", "\n");

mdContent = regexprep(mdContent, "^# `?([^`\n]+)`?", "<a href="""">$1</a>", "lineAnchors");
mdContent = regexprep(mdContent, "^## ([^\n]+)", "<a href="""">$1</a>", "lineAnchors");
mdContent = regexprep(mdContent, "\{== (.*?) ==\}", "<strong>$1</strong>");
mdContent = regexprep(mdContent, "^__`(.*?)`__", "<strong>$1</strong>", "lineAnchors");
mdContent = regexprep(mdContent, "^>", "| ", "lineAnchors");
mdContent = regexprep(mdContent, "^(.)", "  $1", "lineAnchors");
mdContent = regexprep(mdContent, "```matlab(.*?)```", "${regexprep($1, ""^  "", ""       "", ""lineAnchors"")}", "lineAnchors");

mdContent = join([
    mdContent
    ""
    "  [IrisToolbox] for Macroeconomic Modeling"
    sprintf("  Copyright (c) 2007-%g [IrisToolbox] Solutions Team", year(now()));
    ""
    ""
], newline());

if ~isinf(maxLines) && nnz(strfind(char(mdContent), newline()))>maxLines
    lines = split(mdContent, newline());
    mdContent = join(lines(1:maxLines), newline());
end

mdContent = string(newline()) + string(repmat('=', 1, 80)) + string(newline()) + mdContent;

disp("");
disp(mdContent);
disp("");

end%

