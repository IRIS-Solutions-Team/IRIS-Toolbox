function this = endogenize(this, dates, names, varargin)
% endogenize  Endogenize some exogenous quantities in some periods
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.endogenize');
    pp.KeepUnmatched = true;
    addParameter(pp, 'SwapLink', this.DEFAULT_SWAP_LINK, @(x) validate.roundScalar(x) && x~=Plan.ZERO_SWAP_LINK);
end
parse(pp, varargin{:});
unmatched = pp.UnmatchedInCell;
opt = pp.Options;

%--------------------------------------------------------------------------

this = implementEndogenize(this, dates, names, opt.SwapLink, unmatched{:});

end%

