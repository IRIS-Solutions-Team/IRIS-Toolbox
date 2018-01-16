function [x, meanX, stdX] = stdize(x, flag)
% stdize  Standardize numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if nargin<2
    flag = 0;
end

%--------------------------------------------------------------------------

% Compute, remove and store mean
meanX = tseries.mynanmean(x, 1);
x = bsxfun(@minus, x, meanX);

% Compute, remove and store std deviations
stdX = tseries.mynanstd(x, flag, 1);
x = bsxfun(@rdivide, x, stdX);

end
