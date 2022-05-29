% zerodb  Create model-specific zero-deviation database
%
%
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = zerodb(Model, SimulationRange, ~NumColumns, ...)
%
%
% ## Input Arguments ##
%
% * `Model` [ model ] - Model object for which the zero database will be
% created.
%
% * `SimulationRange` [ numeric ] - Intended simulation range; the zero
% database will be created on a range that also automatically includes all
% the necessary lags.
%
% * `~NumColumns` [ numeric | *`1`* ] - Number of columns created in the
% time series object for each variable; the input argument `NumColumns`
% can be only used on models with one parameterisation; may be omitted.
%
%
% ## Options ##
%
% * `ShockFunc=@zeros` [ `@lhsnorm` | `@randn` | `@zeros` ] - Function used
% to generate data for shocks. If `@zeros`, the shocks will simply be
% filled with zeros. Otherwise, the random numbers will be drawn using the
% specified function and adjusted by the respective covariance matrix
% implied by the current model parameterization.
%
%
% ## Output Arguments ##
%
% * `D` [ struct ] - Database with a tseries object filled with zeros for
% each linearised variable, a tseries object filled with ones for each
% log-linearised variables, and a scalar or vector of the currently
% assigned values for each model parameter.
%
% * `IsDev` [ `true` ] - The second output argument is always `true`, and
% can be used to set the option `Deviation=` in
% [`model/simulate`](model/simulate).
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [d, deviation] = zerodb(this, range, varargin)

deviation = true;
d = createSourceDb(this, range, varargin{:}, "deviation", deviation);

end%

