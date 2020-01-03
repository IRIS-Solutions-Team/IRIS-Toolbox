function ww = getExpSmoothMatrix(beta, numPeriods)
% getExpSmoothMatrix  Get projection matrix for exponential smoothing
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

betap = beta.^(0:numPeriods-1);
w = toeplitz(betap(1:end-1));
w = tril(w);
w = w * (1-beta);
ww = zeros(numPeriods);
ww(:, 1) = betap.';
ww(2:end, 2:end) = w;

end%

