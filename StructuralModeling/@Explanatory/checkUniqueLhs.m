% checkUniqueLhs  Verify that all LHS names are unique and throw an error if not
%{
% ## Syntax ##
%
%
%     checkUniqueLhs(xq)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ Explanatory ]
% >
% An Explanatory array whose LHS names will be checked
%
%
% Description
%
% 
% If the same name is found on the LHS of more than one equation (even
% transformed), an error is thrown. Use `verifyUniqueLhs( )` to get a flag
% and the list of duplicate names without an error.
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function checkUniqueLhs(this, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Explanatory/checkUniqueLhs');
    addRequired(pp, 'xq', @(x) isa(x, 'Explanatory'));
    addParameter(pp, 'ThrowAs', 'Error', @(x) validate.anyString(x, 'Error', 'Warning'));
end
%)
opt = parse(pp, this, varargin{:});

%--------------------------------------------------------------------------

[flag, list] = verifyUniqueLhs(this);
if ~flag
    thisError = [ "Explanatory:NonuniqueLhs"
                  "This name occurs on the LHS of more than "
                  "one equation in the Explanatory array: %s " ];
    throw(exception.Base(thisError, opt.ThrowAs));
end

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/checkUniqueLhsUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
    testCase.TestData.Object = ...
        Explanatory.fromString(["x=x{-1}", "diff(y)=z", "diff(x)=z"]);


%% Test Non Unique Error
    q = testCase.TestData.Object;
    errorThrown = false;
    try
        checkUniqueLhs(q);
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, true);
    errorThrown = false;
    try
        checkUniqueLhs(q, 'ThrowAs', 'Error');
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, true);


%% Test Unique
    q = testCase.TestData.Object;
    errorThrown = false;
    try
        checkUniqueLhs(q([1, 2]));
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, false);


%% Test Non Unique Warning
    q = testCase.TestData.Object;
    errorThrown = false;
    lastwarn('');
    try
        checkUniqueLhs(q, 'ThrowAs', 'Warning');
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, false);
    assertNotEmpty(testCase, lastwarn( ));

##### SOURCE END #####
%}
