function ihelp(name, maxLines)

    DIVIDER = string(newline()) + string(repmat('=', 1, 80)) + string(newline());
    CUT = "%---8<---";
    WHICH = @(name) regexprep(string(which(name)), "\s+%.*", "");

    try, maxLines = double(string(maxLines));
        catch, maxLines = Inf; end

    resolved = WHICH(name);
    if ismissing(resolved) || strlength(resolved)==0
        [path, title, ~] = fileparts(name);
        resolved = WHICH(path);
        [path, ~, ~] = fileparts(resolved);
        resolved = fullfile(string(path), string(title)+".m");
    end

    try
        mdContent = string(fileread(resolved));
    catch
        exception.error([
            "Help"
            "No markdown help exists in IrisT for this file: %s"
        ], name);
    end

    if ~contains(mdContent, CUT)
        exception.error([
            "Help"
            "No markdown help exists in IrisT for this file: %s"
        ], name);
    end

    mdContent = extractBefore(mdContent, CUT);
    mdContent = regexp(mdContent, "%\{(.*)%\}", "tokens", "once");
    if ismissing(mdContent) || isempty(mdContent) ...
        || ismissing(mdContent(1)) || strlength(mdContent)==0
        exception.error([
            "Help"
            "No markdown help exists in IrisT for this file: %s"
        ], name);
    end
    mdContent = mdContent(1);

    mdContent = regexprep(mdContent, "\r", "");
    mdContent = regexprep(mdContent, "\n{4,}", "\n\n\n");
    mdContent = regexprep(mdContent, "^\s*---.*?---", "");
    mdContent = regexprep(mdContent, "^\s+", "\n");

    mdContent = regexprep(mdContent, "^# `?([^`\n]+)`?", "<a href="""">$1</a>", "lineAnchors");
    mdContent = regexprep(mdContent, "^## ([^\n]+)", "<a href="""">$1</a>", "lineAnchors");
    mdContent = regexprep(mdContent, "\{== (.*?) ==\}", "<strong>$1</strong>");
    mdContent = regexprep(mdContent, "^__`(.*?)`__", "<strong>$1</strong>", "lineAnchors");
    mdContent = regexprep(mdContent, "^>", ": ", "lineAnchors");
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

    disp("");
    disp(DIVIDER);
    disp(mdContent);
    disp("");

end%

