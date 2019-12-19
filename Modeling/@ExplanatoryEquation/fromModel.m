function this = fromModel(model, lhsNames, varargin)
% fromModel  Extract ExplanatoryEquations from Model object
%{
% ## Syntax ##
%
%
%     output = function(input, ...)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ | ]
% >
% Description
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Description
%
%
% ## Options ##
%
%
% __`OptionName=Default`__ [ | ]
% >
% Description
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.fromModel');
    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'lhsNames', @(x) validate.list(x));
end
parse(pp, model, lhsNames, varargin{:});

%--------------------------------------------------------------------------

lhsNames = cellstr(lhsNames);
equationStrings = cell(size(lhsNames));
lhsNamesEqual = strcat(lhsNames, '=');
[equationStrings{1:end}] = equationStartsWith(model, lhsNames{:});
numEquations = cellfun(@numel, equationStrings);
if any(numEquations==0)
    hereReportNotFound( );
end
if any(numEquations>1)
    hereReportMultiple( );
end

equationStrings = [equationStrings{:}];
inxHasSteady = arrayfun(@(x) contains(x, "!!"), equationStrings);
equationStrings(inxHasSteady) ...
    = arrayfun( ...
        @(x) replaceBetween(x, "!!", strlength(x), "", "Boundaries", "Inclusive"), ...
        equationStrings ...
    );

this = ExplanatoryEquation.fromString(equationStrings);

return

    function hereReportNotFound( )
        report = lhsNames(numEquations==0);
        thisError = [
            "ExplanatoryEquations:FromModel"
            "No equation exists for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%

    function hereReportMultiple( )
        report = lhsNames(numEquations>1);
        thisError = [
            "ExplanatoryEquations:FromModel"
            "Multiple equations exist for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%
end%

