function this = endogenize(this, dates, names, varargin)
% endogenize  Endogenize some exogenous quantities in some periods
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.endogenize');
    parser.KeepUnmatched = true;
    addParameter(parser, 'SwapLink', this.DEFAULT_SWAP_ID, @Plan.validateSwapLink);
end
parse(parser, varargin{:});
unmatched = parser.UnmatchedInCell;
opt = parser.Options;

%--------------------------------------------------------------------------

this = implementEndogenize(this, dates, names, opt.SwapLink, unmatched{:});

end%

