function [exitFlag, dcy] = simulateFirstOrder(simulateFunc, rect, data, varargin)

simulateFunc(rect, data);
exitFlag = solver.ExitFlag.LINEAR_SYSTEM;
dcy = double.empty(0);

end%

