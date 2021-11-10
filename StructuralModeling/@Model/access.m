% Type `web Model/access.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function [output, beenHandled] = access(this, input, options)

% >=R2019b
%(
arguments
    this (1, :) Model
    input (1, 1) string

    options.Error (1, 1) logical = true
end
%)
% >=R2019b

stringify = @(x) reshape(string(x), 1, []);

%
% Preprocess the input query
%
what = input;
what = erase(what, ["_", "-", ":", "."]);

%
% Model components
%
[output, beenHandled] = access(this.Quantity, what);
if beenHandled, return, end

[output, beenHandled] = access(this.Equation, what);
if beenHandled, return, end

[output, beenHandled] = access(this.Pairing, what, this.Quantity);
if beenHandled, return, end


output = [ ];
beenHandled = true;
numVariants = countVariants(this);


%==========================================================================
if lower(what)==lower("fileName")
    output = string(this.FileName);


elseif lower(what)==lower("preprocessor")
    output = this.Preprocessor;


elseif lower(what)==lower("postprocessor")
    output = this.Postprocessor;


elseif any(lower(what)==erase(["parameter-values", "parameters-struct"], "-"))
    inx = this.Quantity.Type==4;
    values = permute(this.Variant.Values(1, inx, :), [2, 3, 1]);
    output = locallyCreateStruct(this.Quantity.Name(inx), values);


elseif lower(what)==lower("stdValues")
    namesStd = stringify(getStdNames(this.Quantity));
    numShocks = numel(namesStd);
    values = permute(this.Variant.StdCorr(1, 1:numShocks, :), [2, 3, 1]);
    output = locallyCreateStruct(namesStd, values);


elseif lower(what)==lower("corrValues")
    output = implementGet(this, "corr");


elseif lower(what)==lower("nonzeroCorrValues")
    output = implementGet(this, "nonzeroCorr");


elseif startsWith(what, "steady", "ignoreCase", true)
    values = permute(this.Variant.Values, [2, 3, 1]);
    if endsWith(what, ["level", "levels"], "ignoreCase", true)
        values = real(values);
    elseif endsWith(what, ["change", "growth", "changes"], "ignoreCase", true)
        values = imag(values);
    end
    output = locallyCreateStruct(this.Quantity.Name, values);


elseif any(lower(what)==lower(["required", "initials"]))
    logStyle = "none";
    idInit = getIdInitialConditions(this);
    output = printSolutionVector(this, idInit, logStyle);
    output = reshape(string(output), 1, []);


elseif lower(what)==lower("initCond")
    logStyle = "log()";
    idInit = getIdInitialConditions(this);
    output = printSolutionVector(this, idInit, logStyle);
    output = reshape(string(output), 1, []);


elseif lower(what)==lower("eigenValues")
    output = this.Variant.EigenValues;


elseif any(lower(what)==lower(["stableRoots", "unitRoots", "unstableRoots"]))
    eigenValues = this.Variant.EigenValues;
    eigenStability = this.Variant.EigenStability;
    if startsWith(what, "stable", "ignoreCase", true)
        inxSelect = eigenStability==0;
    elseif startsWith(what, "unit", "ignoreCase", true)
        inxSelect = eigenStability==1;
    elseif startsWith(what, "unstable", "ignoreCase", true)
        inxSelect = eigenStability==2;
    end
    output = nan(size(eigenValues));
    for v = 1 : numVariants
        n = nnz(inxSelect(1, :, v));
        output(1, 1:n, v) = eigenValues(1, inxSelect(1, :, v), v);
    end
    output(:, all(isnan(output), 3), :) = [ ];
    if ~isreal(output) && any(isnan(output(:)))
        output(isnan(output)) = complex(NaN, NaN);
    end


elseif any(lower(what)==lower("maxLag"))
    [~, ~, output] = getActualMinMaxShifts(this);


elseif any(lower(what)==lower("maxLead"))
    [~, output] = getActualMinMaxShifts(this);


elseif any(lower(what)==lower(["stationaryStatus", "isStationary"]))
    output = implementGet(this, "stationary");


elseif any(lower(what)==lower(["stationaryList", "nonstationaryList"]))
    output = textual.stringify(implementGet(this, lower(what)));


elseif lower(what)==lower("transitionVector")
    output = textual.stringify(implementGet(this, "xVector"));


elseif lower(what)==lower("measurementVector")
    output = textual.stringify(implementGet(this, "yVector"));


elseif lower(what)==lower("shockVector")
    output = textual.stringify(implementGet(this, "eVector"));


elseif lower(what)==lower("forwardHorizon")
    output = implementGet(this, "forward");


else
    beenHandled = false;

end
%==========================================================================


if ~beenHandled && options.Error
    exception.error([
        "Model:InvalidAccessQuery"
        "This is not a valid query into Model objects: %s "
    ], input);
end

end%

%
% Local functions
%

function output = locallyCreateStruct(names, values)
    %(
    names = reshape(string(names), 1, []);
    output = struct();
    for i = 1 : numel(names)
        output.(names(i)) = values(i, :);
    end
    %)
end%

