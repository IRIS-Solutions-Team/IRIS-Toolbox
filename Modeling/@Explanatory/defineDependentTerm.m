function this = defineDependenTerm(this, varargin)
% defineDependenTerm  Define dependent term in Explanatory object
%{
% ## Syntax ##
%
%
%     expy = defineDependenTerm(expy, name, ~transform)
%     expy = defineDependenTerm(expy, position, ~transform)
%     expy = defineDependenTerm(expy, expression)
%
%
% ## Input Arguments ##
%
%
% __`expy`__ [ Explanatory ]
% >
% Explanatory object whose dependent (LHS) variable will be
% defined; `expy` needs to have its `VariableNames` defined before calling
% `defineDependenTerm(...)`.
%
%
% __`name`__ [ string ]
% >
% Name of the dependent (LHS) varible; the name must be from the list of
% `VariableNames` in the Explanatory object `expy`.
%
%
% __`position`__ [ numeric ]
% >
% Pointer to a name from the `VariableNames` list in the
% Explanatory object `expy`.
%
%
% __`expression`__ [ string ]
% > 
% Expression to define the dependent (LHS) term. The `expression` may
% involved a variable from the `VariableNames` list in the
% Explanatory object `expy` and one of the tranform functions (see
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
% __`expy`__ [ Explanatory ]
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
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.defineDependenTerm');
    addRequired(pp, 'expy', @(x) isa(x, 'Explanatory'));
end
%)
opt = parse(pp, this);

%--------------------------------------------------------------------------

term = regression.Term(this, varargin{:}, "Type=", ["Pointer", "Name", "Transform"]);
this.DependentTerm = term;
checkNames(this);

end%




%
% Unit Tests
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/defineDependentTermUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once
    expy = Explanatory( );
    expy = setp(expy, 'VariableNames', ["x", "y", "z"]);
    testCase.TestData.Model = expy;


%% Test Pointer
    expy = testCase.TestData.Model;
    expy = defineDependentTerm(expy, 3, "Transform=", "log");
    act = getp(expy, 'DependentTerm');
    exp = regression.Term(expy, 3, "Transform", "log");
    exp.ContainsLhsName = true;
    exp.ContainsCurrentLhsName = true;
    assertEqual(testCase, act, exp);
    act = expy.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);


%% Test Name
    expy = testCase.TestData.Model;
    expy = defineDependentTerm(expy, "z", "Transform=", "log");
    act = getp(expy, 'DependentTerm');
    exp = regression.Term(expy, 3, "Transform", "log");
    exp.ContainsLhsName = true;
    exp.ContainsCurrentLhsName = true;
    assertEqual(testCase, act, exp);
    act = expy.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);


%% Test Transform
    expy = testCase.TestData.Model;
    expy = defineDependentTerm(expy, "log(z)");
    act = getp(expy, 'DependentTerm');
    exp = regression.Term(expy, 3, "Transform", "log");
    exp.ContainsLhsName = true;
    exp.ContainsCurrentLhsName = true;    
    assertEqual(testCase, act, exp);
    act = expy.LhsName;
    exp = "z";
    assertEqual(testCase, act, exp);


%% Test Invalid Shift
    expy = testCase.TestData.Model;
    thrownError = false;
    try
        expy = defineDependentTerm(expy, "z", "Transform=", "log", "Shift=", -1);
    catch exc
        thrownError = true;
    end
    assertEqual(testCase, thrownError, true);

##### SOURCE END #####
%}

