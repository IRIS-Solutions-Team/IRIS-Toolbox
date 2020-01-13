function varargout = exogenizeWhenData(this, dates, names, varargin)
% exogenize  Exogenize some endogenous quantities in some periods only if data are available
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(dates, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/exogenizeWhenData');
    pp.KeepUnmatched = true;
    addParameter(pp, 'SwapLink', this.DEFAULT_SWAP_LINK, @(x) validate.roundScalar(x) && x~=Plan.ZERO_SWAP_LINK);
end
parse(pp, varargin{:});
unmatched = pp.UnmatchedInCell;
opt = pp.Options;

%--------------------------------------------------------------------------

this = implementExogenize( ...
    this, dates, names, opt.SwapLink, unmatched{:}, ...
    'MissingValue=', 'KeepEndogenous' ...
);


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = this;
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end%




%
% Unit Tests 
% (
function tests = unitTests( )
    tests = functiontests({
        @setupOnce 
        @indexTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
end%


function indexTest(testCase)
    x = ExplanatoryEquation.fromString(["x=x{-1}", "y=x+y{-1}"]);
    p = Plan.forExplanatoryEquation(x, 1:5);
    p = exogenize(p, 1:2, "x");
    p = exogenizeWhenData(p, 3:5, "x");
    p = exogenizeWhenData(p, 1:5, "y");
    exp = false(2, 5);
    exp(1, 3:5) = true;
    exp(2, 1:5) = true;
    exp = [false(2, 1), exp];
    assertEqual(testCase, p.InxToKeepEndogenousNaN, exp);
end%
% )
