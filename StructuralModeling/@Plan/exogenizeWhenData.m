% exogenizeWhenData  Exogenize endogenous quantities only if data are available
%{
% Syntax
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = exogenizeWhenData(this, dates, names, varargin)

% Parse input arguments
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/exogenizeWhenData');
    pp.KeepUnmatched = true;
    addParameter(pp, 'SwapLink', this.DEFAULT_SWAP_LINK, @(x) validate.roundScalar(x) && x~=Plan.ZERO_SWAP_LINK);
end
parse(pp, varargin{:});
unmatched = pp.UnmatchedInCell;
opt = pp.Options;
%)

%--------------------------------------------------------------------------

this = implementExogenize( ...
    this, dates, names, opt.SwapLink, unmatched{:}, ...
    'MissingValue', 'KeepEndogenous' ...
);

end%
