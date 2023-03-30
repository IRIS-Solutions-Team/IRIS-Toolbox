% fromModel  Extract Explanatorys from Model object
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


function this = fromModel(model, lhsNames, varargin)

    % Parse input arguments
    %(
    persistent pp
    if isempty(pp)
        pp = extend.InputParser('Explanatory/fromModel');
        pp.KeepUnmatched = true;
        addRequired(pp, 'model', @(x) isa(x, 'Model'));
        addRequired(pp, 'lhsNames', @(x) validate.list(x));
    end
    parse(pp, model, lhsNames, varargin{:});
    opt = pp.Options;
    %)



    lhsNames = cellstr(lhsNames);
    equations = cell(size(lhsNames));
    lhsNamesEqual = strcat(lhsNames, '=');
    [equations{1:end}] = equationStartsWith(model, lhsNames{:});
    numEquations = cellfun(@numel, equations);
    if any(numEquations==0)
        here_reportNotFound();
    end
    if any(numEquations>1)
        here_reportMultiple();
    end

    equations = [equations{:}];
    inxHasSteady = arrayfun(@(x) contains(x, "!!"), equations);
    equations(inxHasSteady) = arrayfun(@(x) extractBefore(x, "!!"), equations(inxHasSteady));

    this = Explanatory.fromString(equations, pp.UnmatchedInCell{:});

return

    function here_reportNotFound()
        report = lhsNames(numEquations==0);
        thisError = [
            "Explanatorys:FromModel"
            "No equation exists for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%


    function here_reportMultiple()
        report = lhsNames(numEquations>1);
        thisError = [
            "Explanatorys:FromModel"
            "Multiple equations exist for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%

end%

