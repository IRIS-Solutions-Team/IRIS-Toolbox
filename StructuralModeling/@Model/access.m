%{
% 
% # `access` ^^(Model)^^
% 
% {== Access properties of Model objects ==}
% 
% 
% ## Syntax
% 
%     output = access(model, what)
%     output = model{what}
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ]
% > 
% > Model objects that will be queried about `what`.
% > 
% 
% __`what`__ [ string ]
% > 
% > One of the valid queries into the model object properties listed below.
% > 
% 
% ## Output arguments
% 
% __`output`__ [ * ]
% > 
% > Response to the query about `what`.
% > 
% 
% ## Valid queries
% 
% __`"file-name"`__
% > 
% > Returns a string, or an array of strings, with the name(s) of model source
% > files on which this model objects is based.
% > 
% 
% __`"transition-variables"`__
% 
% __`"transition-shocks"`__
% 
% __`"measurement-variables"`__
% 
% __`"measurement-shocks"`__
% 
% __`"parameters"`__
% 
% __`"exogenous-variables"`__
% 
% > 
% > Return a string array of all the names of the respective type in order of
% > their apperance in the declaration sections of the source model file(s).
% > 
% 
% __`"log-variables"`__
% > 
% > Returns the list of variables declared as 
% > [`!log-variables`](../Slang/!log-variables.md).
% > 
% 
% __`"log-status"`__
% > 
% > Returns a struct with `true` for all variables declared as
% > [`!log-variables`](../Slang/!log-variables.md)
% > and `false` for all other variables.
% > 
% 
% __`"names-descriptions"`__
% >
% > Returns a struct with the desriptions strings for all model quantities
% > (variables, shocks, parameters).
% > 
% 
% __`"transition-equations"`__
% 
% __`"measurement-equations"`__
% 
% __`"measurement-trends"`__
% 
% __`"links"`__
% 
% > 
% > Returns a vector of strings with all equations of the respective type.
% > 
% 
% __`"equations-descriptions"`__
% >
% > Returns a struct with the desriptions strings for all model equations,
% > ordered as follows: measurement equations, transition equations,
% > measurement trends, links.
% > 
% 
% __`"preprocessor"`__, __`"postprocessor"`__
% > 
% > Returns an array of Explanatory objects with the equations defined in thea
% > `!preprocessor` or `!postprocessor` section of the model source.
% > 
% 
% __`"parameter-values"`__ 
% > 
% > Returns a struct of all parameter values (not including std deviations or
% > cross-correlation coefficients).
% > 
% 
% __`"std-values"`__ 
% > 
% > Returns a struct of std deviations for all model shocks (transitory and
% > measurement).
% > 
% 
% __`"corr-values"`__
% > 
% > Returns a struct of cross-correlation coefficients for all pairs of
% > transition shocks and all pairs of measurement shocks.
% > 
% 
% __`"nonzero-corr-values"`__
% > 
% > Returns a struct of non-zero cross-correlation coefficients for all pairs
% > of transition shocks and all pairs of measurement shocks.
% > 
% 
% 
% __`"steady-level"`__
% > 
% > Returns a struct with the steady-state levels of all model variables.
% > 
% 
% __`"steady-change"`__
% > 
% > Returns a struct with the steady-state change (first difference or rate
% > of change depending on the log status of each variables) for all model
% > variables.
% > 
% 
% __`"initials"`__
% > 
% > Returns a vector of strings listing all initial conditions necessary for
% > a dynamic simulation.
% > 
% 
% __`"stable-roots"`__
% 
% __`"unit-roots"`__
% 
% __`"unstable-roots"`__
% 
% > 
% > Returns a vector of stable, unit o unstable eigenvalues, respectively.
% > 
% 
% __`"max-lag"`__
% 
% __`"max-lead"`__
% 
% > 
% > Returns the max lag or max lead occurring in the model equations.
% > 
% 
% __`"stationary-status"`__
% 
% > 
% > Returns a struct with `true` for all stationary variables, and `false`
% > for all nonstationary variables.
% > 
% 
% __`"transition-vector"`__
% 
% __`"measurement-vector"`__
% 
% __`"shocks-vector"`__
% 
% > 
% > Returns a list of strings with the respective variables or shocks,
% > including auxiliary lags and leads, as they appear in the rows of
% > first order solution matrices.
% > 
% 
% __`"forward-horizon"`__
% 
% > 
% > Horizon for which the forwared expansion of the model solution has been
% > calculated and is available in the model object.
% > 
% 
% 
% ## Description
% 
% 
% ## Example
% 
% 
%}
% --8<--


% >=R2019b
%{
function [output, beenHandled] = access(this, input, opt)

arguments
    this (1, :) Model
    input (1, 1) string

    opt.Error (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function [output, beenHandled] = access(this, input, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Error', true);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
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

