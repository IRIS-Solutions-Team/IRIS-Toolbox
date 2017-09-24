function [d, isDev] = zerodb(this, range, varargin)
% zerodb  Create model-specific zero-deviation database.
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = zerodb(M, Range, ~NCol, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object for which the zero database will be
% created.
%
% * `Range` [ numeric ] - Intended simulation range; the zero database will
% be created on a range that also automatically includes all the necessary
% lags.
%
% * `~NCol` [ numeric | *`1`* ] - Number of columns created in the time
% series object for each variable; the input argument `NCol` can be only
% used on models with one parameterisation; may be omitted.
%
%
% __Options__
%
% * `'shockFunc='` [ `@lhsnorm` | `@randn` | *`@zeros`* ] - Function used
% to generate data for shocks. If `@zeros`, the shocks will simply be
% filled with zeros. Otherwise, the random numbers will be drawn using the
% specified function and adjusted by the respective covariance matrix
% implied by the current model parameterization.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Database with a tseries object filled with zeros for
% each linearised variable, a tseries object filled with ones for each
% log-linearised variables, and a scalar or vector of the currently
% assigned values for each model parameter.
%
% * `IsDev` [ `true` ] - The second output argument is always `true`, and
% can be used to set the option `'deviation='` in
% [`model/simulate`](model/simulate).
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% zerodb, sstatedb

pp = inputParser( );
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.parse(this, range);

%--------------------------------------------------------------------------

isDev = true;
d = createSourceDbase(this, range, varargin{:}, 'Deviation=', isDev);

end
