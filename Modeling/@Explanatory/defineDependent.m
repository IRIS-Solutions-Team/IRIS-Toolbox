function varargout = defineDependent(this, varargin)
% defineDependent  Define dependent term in Explanatory
%{
% ## Syntax ##
%
%
%     xq = defineDependent(xq, name, ~transform)
%     xq = defineDependent(xq, position, ~transform)
%     xq = defineDependent(xq, expression)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ Explanatory ]
% >
% Explanatory object whose dependent (LHS) variable will be
% defined; `xq` needs to have its `VariableNames` defined before calling
% `defineDependent(...)`.
%
%
% __`name`__ [ string ]
% >
% Name of the dependent (LHS) varible; the name must be from the list of
% `VariableNames` in the Explanatory object `xq`.
%
%
% __`position`__ [ numeric ]
% >
% Pointer to a name from the `VariableNames` list in the
% Explanatory object `xq`.
%
%
% __`expression`__ [ string ]
% > 
% Expression to define the dependent (LHS) term. The `expression` may
% involved a variable from the `VariableNames` list in the
% Explanatory object `xq` and one of the tranform functions (see
% `transform`).
%
%
% __`~transform=[ ]`__ [ empty | `'diff'` | `'log'` | `'difflog'` ]
% >
% Tranform function applied to the depedent (LHS) variable; the `transform`
% function can only be specified when the dependent variable is entered as
% a `name` or a `position`, not as an `expression`; if not specified, no
% transformation is applied.
%
%
% ## Output Arguments ##
%
%
% __`xq`__ [ Explanatory ]
% >
% The Explanatory object with a dependent (LHS) term defined.
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
    pp = extend.InputParser('Explanatory.defineDependent');
    addRequired(pp, 'explanatoryEquation', @(x) isa(x, 'Explanatory'));
end
parse(pp, this);

%--------------------------------------------------------------------------

term = regression.Term(this, varargin{:}, "Type=", ["Pointer", "Name", "Transform"]);
this.Dependent = term;
checkNames(this);


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = this;
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end%


%
% Unit Tests
%
%(
function tests = unitTests( )
    tests = functiontests({ 
        @setupOnce
        @pointerTest
        @nameTest
        @transformTest 
        @invalidShiftTest 
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
    m = Explanatory( );
    m.VariableNames = ["x", "y", "z"];
    testCase.TestData.Model = m;
end%


function pointerTest(testCase)
    m = testCase.TestData.Model;
    m = defineDependent(m, 3, "Transform=", "log");
    act = m.Dependent;
    exp = regression.Term(m, 3, "Transform", "log");
    exp.Fixed = 1;
    exp.ContainsLhsName = true;
    assertEqual(testCase, act, exp);
    act = m.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);
end%


function nameTest(testCase)
    m = testCase.TestData.Model;
    m = defineDependent(m, "z", "Transform=", "log");
    act = m.Dependent;
    exp = regression.Term(m, 3, "Transform", "log");
    exp.Fixed = 1;
    exp.ContainsLhsName = true;
    assertEqual(testCase, act, exp);
    act = m.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);
end%


function transformTest(testCase)
    m = testCase.TestData.Model;
    m = defineDependent(m, "log(z)");
    act = m.Dependent;
    exp = regression.Term(m, 3, "Transform", "log");
    exp.Fixed = 1;
    exp.ContainsLhsName = true;
    assertEqual(testCase, act, exp);
    act = m.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);
end%


function invalidShiftTest(testCase)
    m = testCase.TestData.Model;
    thrownError = false;
    try
        m = defineDependent(m, "z", "Transform=", "log", "Shift=", -1);
    catch exc
        thrownError = true;
    end
    assertEqual(testCase, thrownError, true);
end%
%)

