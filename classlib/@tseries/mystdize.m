function [x,xmean,xstd] = mystdize(x,flag)
% MYSTDIZE  [Not a public function] Standardize data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin < 2
    % |flag == 0| means std devs will be calculated using `nper-1`, otherwise
    % means they will be calculated using `nper`.
    flag = 0;
end

%**************************************************************************

% Compute, remove and store mean.
xmean = tseries.mynanmean(x,1);
x = bsxfun(@minus,x,xmean);

% Compute, remove and store std deviations.
xstd = tseries.mynanstd(x,flag,1);
x = bsxfun(@rdivide,x,xstd);

end