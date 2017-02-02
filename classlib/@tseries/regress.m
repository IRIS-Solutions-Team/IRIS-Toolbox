function [B,BStd,E,EStd,YFit,Range,BCov] = regress(Y,X,varargin)
% regress  Ordinary or weighted least-square regression.
%
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [B,BStd,E,EStd,YFit,Range,BCov] = regress(Y,X,~Range,...)
%
%
% Input arguments
% ================
%
% * `Y` [ tseries ] - Tseries object with independent (LHS) variables.
%
% * `X` [ tseries] - Tseries object with regressors (RHS) variables.
%
% * `~Range` [ numeric ] - Date range on which the regression will be run;
% if omitted, the entire range available will be used.
%
%
% Output arguments
% =================
%
% * `B` [ numeric ] - Vector of estimated regression coefficients.
%
% * `BStd` [ numeric ] - Vector of std errors of the estimates.
%
% * `E` [ tseries ] - Tseries object with the regression residuals.
%
% * `EStd` [ numeric ] - Estimate of the std deviation of the regression
% residuals.
%
% * `YFit` [ tseries ] - Tseries object with fitted LHS variables.
%
% * `Range` [ numeric ] - The actually used date range.
%
% * `bBCov` [ numeric ] - Covariance matrix of the coefficient estimates.
%
%
% Options
% ========
%
% * `'constant='` [ `true` | *`false`* ] - Include a constant vector in the
% regression; if `true` the constant will be placed last in the matrix of
% regressors.
%
% * `'weighting='` [ tseries | *empty* ] - Tseries object with weights on
% observations in individual periods.
%
%
% Description
% ============
%
% This function calls the built-in `lscov` function.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
    Range = varargin{1};
    varargin(1) = [ ];
else
    Range = Inf;
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Y',@istseries);
pp.addRequired('X',@istseries);
pp.addRequired('Range',@isnumeric);
pp.parse(Y,X,Range);

% Parse options.
opt = passvalopt('tseries.regress',varargin{:});

%--------------------------------------------------------------------------

if length(Range) == 1 && isinf(Range)
    Range = get([X,Y],'minRange');
else
    Range = Range(1) : Range(end);
end

xData = rangedata(X,Range);
yData = rangedata(Y,Range);
if opt.constant
    xData(:,end+1) = 1;
end

rowInx = all(~isnan([xData,yData]),2);

if isempty(opt.weighting)
    [B,BStd,eVar,BCov] = lscov(xData(rowInx,:),yData(rowInx,:));
else
    w = rangedata(opt.weighting,Range);
    [B,BStd,eVar,BCov] = lscov(xData(rowInx,:),yData(rowInx,:),w(rowInx,:));
end
EStd = sqrt(eVar);

if nargout>2
    E = replace(Y,yData - xData*B,Range(1));
end

if nargout>4
    YFit = replace(Y,xData*B,Range(1));
end

end
