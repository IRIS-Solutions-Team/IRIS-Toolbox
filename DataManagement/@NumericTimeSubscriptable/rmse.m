function [outputRmse, pe, dRmse, pe] = rmse(obs, pred, range, varargin)
% rmse  Compute RMSE for given observations and predictions
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [rmseArray, pe] = rmse(obs, pred, ~range, ...)
%
%
% ## Input Arguments ##
% 
% __`obs`__ [ NumericTimeSubscriptable ] -
% Input data with observations.
%
% __`pred`__ [ NumericTimeSubscriptable ] -
% Input data with predictions (a different prediction horizon in each
% column); `pred` is typically the outcome of the Kalman filter,
% [`model/filter`](model/filter) or [`VAR/filter`](VAR/filter), called with
% the option `'Ahead='`.
%
% __`~range`__ [ numeric | `Inf` ] -
% Date range on which the RMSEs will be evaluated; `Inf` means the entire
% possible range available; if omitted, `range=Inf`.
%
%
% ## Output Arguments ##
%
% __`rmseArray` [ numeric ] -
% Numeric array with RMSEs for each column of `pred`.
%
% __`pe` [ NumericTimeSubscriptable ] -
% Prediction errors, i.e. the difference `obs-pred` evaluated within
% `range`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

try
    range; %#ok<VUNUS>
catch %#ok<CTCH>
    range = Inf;
end

pp = inputParser( );
pp.addRequired('obs', @(x) isa(x, 'NumericTimeSubscriptable') && ndims(x) == 2 && size(x, 2) == 1); %#ok<ISMAT>
pp.addRequired('pred', @(x) isa(x, 'NumericTimeSubscriptable'));
pp.addRequired('range', @isnumeric);
pp.parse(obs, pred, range);

%--------------------------------------------------------------------------

obs0 = resize(obs, range) ;
pred0 = resize(pred, range) ;
pe = obs0 - pred0 ;

mse = mean(pe.data.^2, 1, 'OmitNaN');
outputRmse = sqrt(mse);

if nargout>2
    % Input data is in log levels; compute growth rate forecast errors
    dPred = pred - redate(obs, qqtoday, qqtoday-1) ;
    pe = diff(obs) - dPred ;
    pe = resize(pe, range) ;
    dRmse = sqrt(mean(pe.data.^2, 1, 'OmitNaN')) ;
end

end%

