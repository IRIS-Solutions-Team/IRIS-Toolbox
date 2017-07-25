function This = windex(This,W,Range,varargin)
% windex  Simple weighted or Divisia index.
%
% Syntax
% =======
%
%     Y = windex(X,W,Range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input times series.
%
% * `W` [ tseries | numeric ] - Fixed or time-varying weights on the input
% time series.
%
% * `Range` [ numeric ] - Range on which the Divisia index is computed.
%
% Output arguments
% =================
%
% * `Y` [ tseries ] - Weighted index based on `X`.
%
% Options
% ========
%
% * `'method='` [ 'divisia' | *'simple'* ] - Weighting method.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the input data before
% computing the index, delogarithmise the output data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin < 3
    Range = Inf;
end

pp = inputParser( );
pp.addRequired('X',@istseries);
pp.addRequired('W',@(x) isnumeric(x) || istseries(x));
pp.addRequired('Range',@isnumeric);
pp.parse(This,W,Range);

options = passvalopt('tseries.windex',varargin{:});

%--------------------------------------------------------------------------

This.data = This.data(:,:);
temp = This;
if istseries(W)
    W.data = W.data(:,:);
    temp = trim([temp,W]);
end

% Generate the range.
Range = specrange(temp,Range);
data = rangedata(This,Range);
nPer = length(Range);

% Get the weights.
if istseries(W)
    W = rangedata(W,Range);
elseif size(W,1) == 1
    W = W(ones([1,nPer]),:);
end
W = W(:,:);

wSum = sum(W,2);
if size(W,2) == size(data,2)
    % Normalise weights.
    for i = 1 : size(W,2)
        W(:,i) = W(:,i) ./ wSum(:);
    end
elseif size(W,2) == size(data,2)-1
    % Add the last weight.
    W = [W,1-wSum];
end

switch lower(options.method)
    case 'simple'
        if options.log
            data = log(data);
        end
        data = sum(W .* data,2);
        if options.log
            data = exp(data);
        end
    case 'divisia'
        % Compute the average weights between t and t-1.
        wavg = (W(2:end,:) + W(1:end-1,:))/2;
        % Construct the Divisia index.
        data = sum(wavg .* log(data(2:end,:)./data(1:end-1,:)),2);
        % Set the first observation to 1 and cumulate back.
        data = exp(cumsum([0;data]));
end

This.data = data;
This.start = Range(1);
This.Comment = {''};

end
