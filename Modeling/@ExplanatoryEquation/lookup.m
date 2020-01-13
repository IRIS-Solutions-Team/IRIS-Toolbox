function varargout = lookup(this, varargin)
% lookup  Look up equations by the LHS names or attributes
%{
% ## Syntax ##
%
%
%     [inx, output, lhsNames] = function(input [, lookFor])
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ ExplanatoryEquation ]
% >
% Input ExlanatoryEquation object or array from which a subset of equations
% will be extracted.
%
%
% __`lookFor`__ [ char | string ]
% >
% LHS name or attribute that will be searched for in the `input`
% ExplanatoryEquation object or array.
%
%
% ## Output Arguments ##
%
%
% __`inx`__ [ logical ]
% >
% Logical index of equations within the `input` ExplanatoryEquation object
% or array that have at least one of the LHS names or attributes specified
% as the second and further input arguments `lookFor`.
%
%
% __`output`__ [ ExplanatoryEquation ]
% >
% Output ExplanatoryEquation object or array with only those equations
% included that have at least one of the LHS names or attributes specified
% as the second and further input arguments `lookFor`.
%
%
% __`lhsNames`__ [ string ]
% >
% List of LHS names for the equations included in the `output`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(varargin{1}, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('@ExplanatoryEquation/lookup');
    addRequired(pp, 'xq', @(x) isa(x, 'ExplanatoryEquation'));
    addOptional(pp, 'lookFor', cell.empty(1, 0), @(x) all(cellfun(@validate.stringScalar, x)));
end
parse(pp, this, varargin);

%--------------------------------------------------------------------------

inx = false(size(this));
lhsNames = reshape([this.LhsName], size(this));

for i = 1 : numel(varargin)
    identifier = string(varargin{i});
    if startsWith(identifier, ":")
        inx = inx | hasAttribute(this, identifier);
    else
        inx = inx | lhsNames==identifier;
    end
end

try
this = reshape(this(inx), [ ], 1);
catch, keyboard, end
lhsNames = [this.LhsName];


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout = { inx, this, lhsNames };
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end%




%
% Unit Tests 
%
%(
function tests = unitTests( )
    tests = functiontests({
        @setupOnce 
        @lhsNamesTest
        @attributesTest
        @combinedTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
    testCase.TestData.Object = ...
        ExplanatoryEquation.fromString([
            ":a :b :c x = 0"
            ":b :c :d y = 0"
            ":c :d :e z = 0"
            ":0 u = 0"
            ":1 v = 0"
        ]);
end%


function lhsNamesTest(testCase)
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, "x", "z");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);
end%


function attributesTest(testCase)
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, ":a", ":e");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);
end%


function combinedTest(testCase)
    q = testCase.TestData.Object;
    [inx, qq, lhsNames] = lookup(q, ":a", "z");
    assertEqual(testCase, inx, [true; false; true; false; false]);
    assertEqual(testCase, qq, q([1; 3]));
    assertEqual(testCase, lhsNames, ["x", "z"]);
end%
%)

