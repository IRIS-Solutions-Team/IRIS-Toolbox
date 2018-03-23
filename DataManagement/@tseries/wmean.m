function x = wmean(this,dates,beta)
% wmean  Weighted average of time series observations.
%
% Syntax
% =======
%
%     Y = wmean(X,RANGE,BETA)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose data will be averaged
% column by column.
%
% * `RANGE` [ numeric ] - Date range on which the weighted average will be
% computed.
%
% * `BETA` [ numeric ] - Discount factor; the last observation gets a weight of
% of 1, the N-minus-1st observation gets a weight of `BETA`, the N-minus-2nd
% gets a weight of `BETA^2`, and so on.
%
% Output arguments
% =================
%
% * `Y` [ numeric ] - Array with weighted average of individual columns;
% the sizes of `Y` are identical to those of the input tseries object in
% 2nd and higher dimensions.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin < 2
    dates = Inf;
end

if nargin < 3
    beta = 1;
end

%**************************************************************************

% Get time series data.
s = struct( );
s.type = '()';
s.subs{1} = dates;
data = subsref(this,s);

% Compute weighted average.
tmpsize = size(data);
nper = size(data,1);
data = data(:,:);
if beta ~= 1
    w = beta.^(nper-1:-1:0);
    w = w(:);
    for i = 1 : size(this.data,2)
        data(:,i) = data(:,i) .* w;
    end
    sumw = sum(w);
else
    sumw = nper;
end
x = sum(data/sumw,1);
x = reshape(x,[1,tmpsize(2:end)]);

end