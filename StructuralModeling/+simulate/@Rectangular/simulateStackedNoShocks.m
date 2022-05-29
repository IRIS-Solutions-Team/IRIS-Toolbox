% simulateStackedNoShocks  Stacked time simulation for selected data points with no shocks
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function simulateStackedNoShocks(this, data)

inxLog = this.Quantity.InxLog;

TT = this.StackedNoShocks_Transition;
KK = 0;
if ~this.Deviation
    KK = this.StackedNoShocks_Constant;
end
inxDataPoints = this.StackedNoShocks_InxDataPoints;

YXEPG = data.YXEPG;
if any(inxLog)
    YXEPG(inxLog, :) = log(YXEPG(inxLog, :));
end

% Initial condition
linxXib = this.LinxOfXib;
stepForLinx = size(YXEPG, 1);
linxInit = linxXib - stepForLinx;
if isempty(data.ForceInit)
    Xib_0 = YXEPG(linxInit);
else
    Xib_0 = reshape(data.ForceInit, [ ], 1);
    YXEPG(linxInit) = Xib_0;
end


%===========================================================================
YXEPG(inxDataPoints) = TT*Xib_0 + KK;
%===========================================================================


if any(inxLog)
    YXEPG(inxLog, :) = exp(YXEPG(inxLog, :));
end
data.YXEPG(inxDataPoints) = YXEPG(inxDataPoints);

end%

