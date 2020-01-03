function [exitFlag, dcy] = simulateFirstOrder(simulateFunc, rect, data, ~)
% simulateFirstOrder  Run first-order simulation on one time frame
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

simulateFunc(rect, data);
exitFlag = solver.ExitFlag.LINEAR_SYSTEM;
dcy = double.empty(0);

end%

