
% >=R2019b
%(
function [output, beenHandled] = access(this, input, opt)

arguments
    this (1, :) Model
    input (1, 1) string

    opt.Error (1, 1) logical = true
end
%)
% >=R2019b


% <=R2019a
%{
function [output, beenHandled] = access(this, input, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Error', true);
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


stringify = @(x) reshape(string(x), 1, []);

%
% Preprocess the input query
%
F = @(x) erase(lower(x), ["s", "_", "-", ":", "."]);
what = F(input);

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
if what==F("file-name")
    output = string(this.FileName);


elseif what==F("preprocessor")
    output = this.Preprocessor;


elseif what==F("postprocessor")
    output = this.Postprocessor;


elseif any(what==F(["parameter-values", "parameters-struct"]))
    inx = this.Quantity.Type==4;
    names = this.Quantity.Name(inx);
    values = permute(this.Variant.Values(1, inx, :), [2, 3, 1]);
    output = local_createStruct(names, values);


elseif what==F("std-values")
    namesStd = stringify(getStdNames(this.Quantity));
    numShocks = numel(namesStd);
    values = permute(this.Variant.StdCorr(1, 1:numShocks, :), [2, 3, 1]);
    output = local_createStruct(namesStd, values);


elseif what==F("corr-values")
    output = implementGet(this, "corr");


elseif what==F("nonzero-corr-values")
    output = implementGet(this, "nonzeroCorr");


elseif what==F("steady")
    values = permute(this.Variant.Values, [2, 3, 1]);
    output = local_createStruct(this.Quantity.Name, values);

elseif what==F("steady-level")
    values = permute(this.Variant.Values, [2, 3, 1]);
    output = local_createStruct(this.Quantity.Name, real(values));

elseif what==F("steady-change")
    values = permute(this.Variant.Values, [2, 3, 1]);
    output = local_createStruct(this.Quantity.Name, imag(values));


elseif any(what==F(["required", "initials"]))
    logStyle = "none";
    idInit = getIdInitialConditions(this);
    output = printSolutionVector(this, idInit, logStyle);
    output = reshape(string(output), 1, []);


elseif what==F("init-cond")
    logStyle = "log()";
    idInit = getIdInitialConditions(this);
    output = printSolutionVector(this, idInit, logStyle);
    output = reshape(string(output), 1, []);


elseif what==F("eigen-values")
    output = this.Variant.EigenValues;


elseif any(what==F(["stable-roots", "unit-roots", "unstable-roots"]))
    eigenValues = this.Variant.EigenValues;
    eigenStability = this.Variant.EigenStability;
    if startsWith(what, F("stable"), "ignoreCase", true)
        inxSelect = eigenStability==0;
    elseif startsWith(what, F("unit"), "ignoreCase", true)
        inxSelect = eigenStability==1;
    elseif startsWith(what, F("unstable"), "ignoreCase", true)
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


elseif any(what==F("max-lag"))
    [~, ~, output] = getActualMinMaxShifts(this);


elseif any(what==F("max-lead"))
    [~, output] = getActualMinMaxShifts(this);


elseif any(what==F(["stationary-status", "is-stationary"]))
    output = implementGet(this, "stationary");


elseif any(what==F(["stationary-list", "nonstationary-list"]))
    output = textual.stringify(implementGet(this, input));


elseif what==F("transition-vector")
    output = textual.stringify(implementGet(this, "xVector"));


elseif what==F("measurement-vector")
    output = textual.stringify(implementGet(this, "yVector"));


elseif what==F("shock-vector")
    output = textual.stringify(implementGet(this, "eVector"));


elseif what==F("forward-horizon")
    output = implementGet(this, "forward");


else
    beenHandled = false;

end
%==========================================================================


if ~beenHandled && opt.Error
    exception.error([
        "Model:InvalidAccessQuery"
        "This is not a valid query into Model objects: %s "
    ], input);
end

end%

%
% Local functions
%

function output = local_createStruct(names, values)
    %(
    names = reshape(string(names), 1, []);
    output = struct();
    for i = 1 : numel(names)
        output.(names(i)) = values(i, :);
    end
    %)
end%

