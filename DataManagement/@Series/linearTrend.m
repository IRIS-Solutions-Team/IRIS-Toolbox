% Type `web Series/linearTrend.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = linearTrend(range, varargin)

this = TimeSubscriptable.linearTrend(@Series, range, varargin{:});

end%

