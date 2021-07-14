% access  Access properties of Model objects
%
%{ Syntax
%--------------------------------------------------------------------------
%
%     output = access(model, what)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`model`__ [ Model ]
%>
%>    Model objects that will be queried about `what`.
%
%
% __`what`__ [ string ]
%>
%>    One of the valid queries listed in the below.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`output`__ [ * ]
%>
%>    Response to the query about `what`.
%
%
% Valid Queries
%--------------------------------------------------------------------------
%
% __`"measurement-variables"`__
%
% __`"transition-variables"`__
%
% __`"shocks"`__
%
% __`"parameters"`__
%
% __`"exogenous-variables"`__
%
%> Names of all measurement variables, or transition variables, or shocks,
%> or parameters, or exogenous variables in order of their apperance in the
%> declaration sections of the source model file(s).
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function [output, beenHandled] = access(this, input, options)

% >=R2019b
%{
arguments
    this (1, :) Model
    input (1, 1) string

    options.Error (1, 1) logical = true
end
%}
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


%==========================================================================
if lower(what)==lower("fileName")
    output = string(this.FileName);


elseif lower(what)==lower("preprocessor")
    output = this.Preprocessor;


elseif lower(what)==lower("postprocessor")
    output = this.Postprocessor;


elseif lower(what)==lower("parameterValues")
    inx = this.Quantity.Type==4;
    values = permute(this.Variant.Values(1, inx, :), [2, 3, 1]);
    output = locallyCreateStruct(this.Quantity.Name(inx), values);


elseif lower(what)==lower("stdValues")
    namesStd = stringify(getStdNames(this.Quantity));
    numShocks = numel(namesStd);
    values = permute(this.Variant.StdCorr(1, 1:numShocks, :), [2, 3, 1]);
    output = locallyCreateStruct(namesStd, values);


elseif startsWith(what, "steady", "ignoreCase", true)
    values = permute(this.Variant.Values, [2, 3, 1]);
    if endsWith(what, "level", "ignoreCase", true)
        values = real(values);
    elseif endsWith(what, ["change", "growth"], "ignoreCase", true)
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

