function [d, isDev] = sstatedb(this, range, varargin)
% sstatedb  Create model-specific steady-state or balanced-growth-path database
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = sstatedb(Model, SimulationRange, ~NumOfColumns, ...)
%
%
% __Input Arguments__
%
% * `Model` [ model ] - Model object for which the sstate database will be
% created.
%
% * `SimulationRange` [ numeric ] - Intended simulation range; the
% steady-state or balanced-growth-path database will be created on a range
% that also automatically includes all the necessary lags.
%
% * `~NumOfColumns=1` [ numeric ] - Number of columns created in the time
% series object for each variable; the input argument `NumOfColumns` can be only
% used on models with one parameterisation.
%
%
% __Options__
%
% * `ShockFunc=@zeros` [ `@lhsnorm` | `@randn` | `@zeros` ] - Function used
% to generate data for shocks. If `@zeros`, the shocks will simply be
% filled with zeros. Otherwise, the random numbers will be drawn using the
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
% can be used to set the option `Deviation=` in
% [`model/simulate`](model/simulate).
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% zerodb, sstatedb

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.sstatedb');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
end
inputParser.parse(this, range);

%--------------------------------------------------------------------------

[flag, list] = isnan(this, 'sstate');
if flag
    utils.warning( 'model:sstatedb', ...
                   'Steady state for this variables is NaN: %s ', ...
                   list{:} );
end

d = createSourceDbase(this, range, varargin{:}, 'Deviation=', false);

end
