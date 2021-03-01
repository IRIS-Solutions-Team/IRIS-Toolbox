% Type `web Series/linearTrend.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

function this = linearTrend(range, varargin)

this = NumericTimeSubscriptable.linearTrend(@Series, range, varargin{:});

end%

