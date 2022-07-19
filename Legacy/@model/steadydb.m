% steadydb  Create model-specific steady-state or balanced-growth-path database
%{
%
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [d, isDeviation] = steadydb(model, simulationRange, ~numColumns, ...)
%
%
% ## Input Arguments ##
%
% __`Model`__ [ model ] -
% Model object for which the sstate database will be created.
%
% __`SimulationRange`__ [ numeric ] -
% Intended simulation range; the steady-state or balanced-growth-path
% database will be created on a range that also automatically includes all
% the necessary lags.
%
% __`~numColumns=1`__ [ numeric ] -
% Number of columns created in the time series object for each variable;
% the input argument `numColumns` can be only used on models with one
% parameterisation.
%
%
% ## Options ##
%
% __`ShockFunc=@zeros`__ [ `@lhsnorm` | `@randn` | `@zeros` ] -
% Function used to generate data for shocks. If `@zeros`, the shocks will
% simply be filled with zeros. Otherwise, the random numbers will be drawn
% using the specified function and adjusted by the respective covariance
% matrix implied by the current model parameterization.
%
%
% ## Output Arguments ##
%
% __`d`__ [ struct ] -
% Database with a steady-state or balanced-growth path
% tseries object for each model variable, and a scalar or vector of the
% currently assigned values for each model parameter.
%
% __`isDeviation`__ [ `false` ] -
% The second output argument is always `false`, and can be used to set the
% option `Deviation=` in [`model/simulate`](model/simulate).
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [d, deviation] = steadydb(this, range, varargin)

    [flag, list] = isnan(this, 'steady');

    if flag
        exception.warning([
            "Model"
            "Steady state for this variables is NaN: %s "
        ], textual.stringify(list));
    end

    deviation = false;
    d = createSourceDb(this, range, varargin{:}, 'deviation', deviation);

end%

