function [this, sizeData] = reshape(this, newSize)
% reshape  Reshape size of time series in 2nd and higher dimensions.
%
% __Syntax__
%
%     X = reshape(X, NewSize)
%
%
% __Input Arguments__
%
% * `X` [ TimeSubscriptable ] - Time series  whose data will be reshaped in
% 2nd and/or higher dimensions.
%
% * `NewSize` [ numeric ] - New size of the time series data; the first
% dimension (time) must be preserved or may be set to `Inf`.
%
%
% __Output Arguments__
%
% * `X` [ TimeSubscriptable ] - Reshaped time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

sizeData = size(this.Data);
if nargin<2
   newSize = prod(sizeData(2:end));
else
   if ~isinf(newSize(1)) && newSize(1)~=sizeData(1)
      utils.error('tseries:reshape', ...
         'First dimension of tseries objects must remain unchanged after RESHAPE.');
   end
   newSize(1) = sizeData(1);
end

% Reshape data and comments.
this.Data = reshape(this.Data, newSize);
this.Comment = reshape(this.Comment, [1, newSize(2:end)]);

end
