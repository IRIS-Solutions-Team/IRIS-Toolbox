function [d, deviation] = zerodb(this, range, varargin)
% zerodb  Create model-specific zero-deviation database
%
%
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = zerodb(Model, SimulationRange, ~NumOfColumns, ...)
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
% * `~NumOfColumns` [ numeric | *`1`* ] - Number of columns created in the
% time series object for each variable; the input argument `NumOfColumns`
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

% zerodb, sstatedb

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.zerodb');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
end
parser.parse(this, range);

%--------------------------------------------------------------------------

d = createSourceDbase(this, range, varargin{:}, 'Deviation=', true);
deviation = true;

end%
