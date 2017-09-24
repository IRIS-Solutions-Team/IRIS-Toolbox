function [d, isDev] = sstatedb(this, range, varargin)
% sstatedb  Create model-specific steady-state or balanced-growth-path database
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = sstatedb(M, Range, ~NCol, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object for which the sstate database will be
% created.
%
% * `Range` [ numeric ] - Intended simulation range; the steady-state or
% balanced-growth-path database will be created on a range that also
% automatically includes all the necessary lags.
%
% * `~NCol` [ numeric | *`1`* ] - Number of columns created in the time
% series object for each variable; the input argument `NCol` can be only
% used on models with one parameterisation; if omitted `NCol=1`.
%
%
% __Options__
%
% * `'ShockFunc='` [ `@lhsnorm` | `@randn` | *`@zeros`* ] - Function used
% to generate data for shocks. If `@zeros`, the shocks will simply be filled
% with zeros. Otherwise, the random numbers will be drawn using the
% specified function and adjusted by the respective covariance matrix
% implied by the current model parameterization.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Database with a steady-state or balanced-growth path
% tseries object for each model variable, and a scalar or vector of the
% currently assigned values for each model parameter.
%
% * `IsDev` [ `false` ] - The second output argument is always `false`, and
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

[flag, list] = isnan(this, 'sstate');
if flag
    utils.warning('model:sstatedb', ...
        'Steady state for this variables is NaN: %s ', ...
        list{:});
end

isDev = false;
d = createSourceDbase(this, range, varargin{:}, 'deviation=', isDev);

end
