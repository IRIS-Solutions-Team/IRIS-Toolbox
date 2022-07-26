% range  Date range from the first to the last available observation.
%
% Syntax
% =======
%
%     rng = range(x)
%
%
% Input arguments
% ================
%
% * `x` [ Series ] - Time series.
%
%
% Output arguments
% =================
%
% * `rng` [ numeric ] - Vector of IRIS serial date numbers representing the
% range from the first to the last available observation in the input
% tseries.
%
%
% Description
% ============
%
% The `range` function is equivalent to calling
%
%     get(x, 'range')
%
%
% Example
% ========
%

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputRange = range(x)

if isempty(x.Data)
    outputRange = nan(1, 0);
else
    numRows = size(x.Data, 1);
    outputRange = dater.plus(double(x.Start), 0:numRows-1);
end
outputRange = Dater(outputRange);

end%

