% lookup  Look up equations by the LHS names or attributes
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     [inx, output, lhsNames] = lookup(input [, lookFor])
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`input`__ [ Explanatory ]
%
%     Input Explanatory object or array from which a subset of equations
%     will be extracted.
%
%
% __`lookFor`__ [ string ]
%
%     LHS name or attribute that will be searched for in the `input`
%     Explanatory object or array.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`inx`__ [ logical ]
% 
%     Logical index of equations within the `input` Explanatory object or
%     array that have at least one of the LHS names or attributes specified
%     as the second and further input arguments `lookFor`.
%
%
% __`output`__ [ Explanatory ]
%
%     Output Explanatory object or array with only those equations included
%     that have at least one of the LHS names or attributes specified as
%     the second and further input arguments `lookFor`.
%
%
% __`lhsNames`__ [ string ]
%
%     List of LHS names for the equations included in the `output`.
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
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [inx, this, lhsNames] = lookup(this, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Explanatory/lookup');
    addRequired(pp, 'xq', @(x) isa(x, 'Explanatory'));
    addOptional(pp, 'lookFor', cell.empty(1, 0), @(x) all(cellfun(@(y) isstring(y) || ischar(y) || iscellstr(y), x)));
end
%)
parse(pp, this, varargin);

%--------------------------------------------------------------------------

inx = false(size(this));
lhsNames = reshape([this.LhsName], size(this));

for v = varargin
    for identifier = reshape(strip(string(v{:})), 1, [ ])
        if startsWith(identifier, ":")
            inx = inx | hasAttribute(this, identifier);
        else
            inx = inx | lhsNames==identifier;
        end
    end
end

if nargout>=2
    this = reshape(this(inx), [ ], 1);
    if nargout>=3
        lhsNames = reshape(lhsNames(inx), 1, [ ]);
    end
end

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/lookupUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once
testCase.TestData.Object = Explanatory.fromString([
        ":a :b :c x = 0"
        ":b :c :d y = 0"
        ":c :d :e z = 0"
        ":0 u = 0"
        ":1 v = 0"
]);


%% Test LHS Names
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, "x", "z");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);


%% Test Attributes
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, ":a", ":e");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);


%% Test Combined
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, ":a", "z");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);

##### SOURCE END #####
%}

