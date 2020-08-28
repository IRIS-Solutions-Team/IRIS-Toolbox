function outputSpecs = extractInfo(outputFiles)

%
% Seasonal adjustment mode; only applicable in seasonal adjustment runs
%

outputSpecs.X11_Mode = "";
if isfield(outputFiles, "out") && strlength(outputFiles.out)>0
    x = regexpi(outputFiles.out, "Type of run\s*-\s*(\w+)", "tokens", "once");
    if ~isempty(x)
        if startsWith(x, "m", "IgnoreCase", true)
            outputSpecs.X11_Mode = "mult";
        elseif startsWith(x, "a", "IgnoreCase", true)
            outputSpecs.X11_Mode = "add";
        elseif startsWith(x, "p", "IgnoreCase", true)
            outputSpecs.X11_Mode = "pseudoadd";
        elseif startsWith(x, "l", "IgnoreCase", true)
            outputSpecs.X11_Mode = "logadd";
        end
    end
end

%
% ARIMA model specification
%

outputSpecs.Arima_Model = string.empty(1, 0);
outputSpecs.Arima_AR = double.empty(1, 0);
outputSpecs.Arima_MA = double.empty(1, 0);
if isfield(outputFiles, "mdl") && strlength(outputFiles.mdl)>0
    mdl = string(outputFiles.mdl);

    model = regexp(mdl, "(?<=model=\s*)[^\n\r]*", "match", "once");
    if ~isempty(model) && ~ismissing(model)
        model = strip(model);
        model = replace(model, " ", ",");
        outputSpecs.Arima_Model = strip(model);
    end

    ar = regexp(mdl, "(?<=ar\s*=\s*\().*?(?=\))", "match", "once");
    if ~isempty(ar) && ~ismissing(ar) && isstring(ar) && strlength(ar)>0
        ar = erase(ar, ["f", "F"]);
        outputSpecs.Arima_AR = reshape(eval("[" + ar + "]"), 1, [ ]);
    end

    ma = regexp(mdl, "(?<=ma\s*=\s*\().*?(?=\))", "match", "once");
    if ~isempty(ma) && ~ismissing(ma) && isstring(ma) && strlength(ma)>0
        ma = erase(ma, ["f", "F"]);
        outputSpecs.Arima_MA = reshape(eval("[" + ma + "]"), 1, [ ]);
    end
end

end%

