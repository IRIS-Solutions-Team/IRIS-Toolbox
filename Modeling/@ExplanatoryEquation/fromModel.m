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
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation/fromModel');
    pp.KeepUnmatched = true;
    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'lhsNames', @(x) validate.list(x));
end
parse(pp, model, lhsNames, varargin{:});

%--------------------------------------------------------------------------

lhsNames = cellstr(lhsNames);
equations = cell(size(lhsNames));
lhsNamesEqual = strcat(lhsNames, '=');
[equations{1:end}] = equationStartsWith(model, lhsNames{:});
numEquations = cellfun(@numel, equations);
if any(numEquations==0)
    hereReportNotFound( );
end
if any(numEquations>1)
    hereReportMultiple( );
end

equations = [equations{:}];
inxHasSteady = arrayfun(@(x) contains(x, "!!"), equations);
equations(inxHasSteady) = arrayfun(@(x) extractBefore(x, "!!"), equations(inxHasSteady));

this = ExplanatoryEquation.fromString(equations, pp.UnmatchedInCell{:});

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

