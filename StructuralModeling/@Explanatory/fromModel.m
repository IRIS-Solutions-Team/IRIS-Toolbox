function this = fromModel(model, lhsNames, varargin)
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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

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

this = Explanatory.fromString(equations, pp.UnmatchedInCell{:});

return

    function hereReportNotFound( )
        report = lhsNames(numEquations==0);
        thisError = [
            "Explanatorys:FromModel"
            "No equation exists for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%


    function hereReportMultiple( )
        report = lhsNames(numEquations>1);
        thisError = [
            "Explanatorys:FromModel"
            "Multiple equations exist for this LHS variable in the Model object: %s"
        ];
        throw(exception.Base(thisError, 'error'), report{:});
    end%
end%




%
% Unit Tests 
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/fromModelUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set Up Once
    f = ModelSource( );
    f.FileName = "test.model";
    f.Code = [
        "!variables"
        "   u, v, w, x, y, z, a"
        "!equations"
        "   u = 1 !! u = 2;"
        "   v = 1 !! v = 2;"
        "   w = 1 !! w = 2;"
        "   x = 1;"
        "   y = 1;"
        "   z = 1;"
        "   u = a;"
    ];
    testCase.TestData.Model = Model(f);

                                                                           
%% Unique Test
    m = testCase.TestData.Model;
    q = Explanatory.fromModel(m, ["v", "y", "w"]);
    assertEqual(testCase, [q.LhsName], ["v", "y", "w"]);
    assertEqual(testCase, [q.InputString], ["v=1;", "y=1;", "w=1;"]); 

                                                                           
%% Nonunique Test
    m = testCase.TestData.Model;
    errorThrown = false;
    try
        q = Explanatory.fromModel(m, ["u", "y", "w"]);
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, true);


##### SOURCE END #####
%}

