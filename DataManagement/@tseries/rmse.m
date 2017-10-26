function [Rmse, Pe, dRmse, dPe] = rmse(Obs, Pred, Range, varargin)
% rmse  Compute RMSE for given observations and predictions.
%
% __Syntax__
%
%     [Rmse, Pe] = rmse(Obs, Pred)
%     [Rmse, Pe] = rmse(Obs, Pred, Range, ...)
%
%
% __Input Arguments__
% 
% * `Obs` [ tseries ] - Input data with observations.
%
% * `Pred` [ tseries ] - Input data with predictions (a different prediction
% horizon in each column); `Pred` is typically the outcome of the Kalman
% filter, [`model/filter`](model/filter) or [`VAR/filter`](VAR/filter), 
% called with the option `'Ahead='`.
%
% * `Range` [ numeric | `Inf` ] - Date range on which the RMSEs will be
% evaluated; `Inf` means the entire possible range available.
%
%
% __Output Arguments__
%
% * `Rmse` [ numeric ] - Numeric array with RMSEs for each column of
% `Pred`.
%
% * `Pe` [ tseries ] - Prediction errors, i.e. the difference `Obs - Pred`
% evaluated within `Range`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Range; %#ok<VUNUS>
catch %#ok<CTCH>
    Range = Inf;
end

pp = inputParser( );
pp.addRequired('Obs', ...
    @(x) isa(x, 'tseries') && ndims(x) == 2 && size(x, 2) == 1); %#ok<ISMAT>
pp.addRequired('Pred', @(x) isa(x, 'tseries'));
pp.addRequired('Range', @isnumeric);
pp.parse(Obs, Pred, Range);

%--------------------------------------------------------------------------

Obs0 = resize(Obs, Range) ;
Pred0 = resize(Pred, Range) ;
Pe = Obs0 - Pred0 ;

Mse = tseries.mynanmean(Pe.data.^2, 1);
Rmse = sqrt(Mse);

if nargout>2
    % Input data is in log levels; compute growth rate forecast errors
    dPred = Pred - redate(Obs, qqtoday, qqtoday-1) ;
    dPe = diff(Obs) - dPred ;
    dPe = resize(dPe, Range) ;
    dRmse = sqrt(tseries.mynanmean(dPe.data.^2, 1)) ;
end

end
