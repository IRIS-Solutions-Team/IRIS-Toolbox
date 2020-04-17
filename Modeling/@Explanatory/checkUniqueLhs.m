function varargout = checkUniqueLhs(this, varargin)
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(varargin{1}, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('@Explanatory/checkUniqueLhs');
    addRequired(pp, 'xq', @(x) isa(x, 'Explanatory'));
    addParameter(pp, 'ThrowAs', 'Error', @(x) validate.anyString(x, 'Error', 'Warning'));
end
parse(pp, this, varargin{:});
opt = pp.Options;

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
%(
function tests = unitTests( )
    tests = functiontests({
        @setupOnce
        @nonuniqueErrorTest
        @uniqueTest
        @nonuniqueWarningTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
    testCase.TestData.Object = ...
        Explanatory.fromString(["x=x{-1}", "diff(y)=z", "diff(x)=z"]);
end%


function nonuniqueErrorTest(testCase)
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
        checkUniqueLhs(q, 'ThrowAs=', 'Error');
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, true);
end%


function uniqueTest(testCase)
    q = testCase.TestData.Object;
    errorThrown = false;
    try
        checkUniqueLhs(q([1, 2]));
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, false);
end%


function nonuniqueWarningTest(testCase)
    q = testCase.TestData.Object;
    errorThrown = false;
    lastwarn('');
    try
        checkUniqueLhs(q, 'ThrowAs=', 'Warning');
    catch
        errorThrown = true;
    end
    assertEqual(testCase, errorThrown, false);
    assertNotEmpty(testCase, lastwarn( ));
end%
%}
