function this = exogenize(this, dates, names, varargin)
% exogenize  Exogenize some endogenous quantities in some periods
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/exogenize');
    pp.KeepUnmatched = true;
    addParameter(pp, 'SwapLink', this.DEFAULT_SWAP_LINK, @(x) validate.roundScalar(x) && x~=Plan.ZERO_SWAP_LINK);
end % if
parse(pp, varargin{:});
unmatched = pp.UnmatchedInCell;
opt = pp.Options;

%--------------------------------------------------------------------------

this = implementExogenize(this, dates, names, opt.SwapLink, unmatched{:});

end%

