function [this, flag, nPath, eigen] = sstate(this, varargin)
% sstate  Compute steady state or balance-growth path of the model
%
% __Syntax__
%
%     [M, Flag] = sstate(M, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Parameterized model object.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with newly computed steady state assigned.
%
% * `Flag` [ `true` | `false` ] - True for parameter variants where steady
% state has been found successfully.
%
%
% __Options__
%
% * `'Warning='` [ *`true`* | `false` ] - Display IRIS warning produced by
% this function.
%
%
% __Options for Nonlinear Models__
%
% * `'Blocks='` [ *`true`* | `false` ] - Rearrange steady-state equations
% in sequential blocks before computing steady state.
%
% * `'Display='` [ *`'iter'`* | `'final'` | `'notify'` | `'off'` ] - Level
% of screen output, see Optim Tbx.
%
% * `'Endogenize='` [ `@auto` | cellstr | char | *empty* ] - List of
% parameters that will be endogenized when computing the steady state; the
% number of endogenized parameters must match the number of transtion
% variables exogenized in the `'Exogenized='` option. The use of the
% keyword `@auto` is explained in Description.
%
% * `'Exogenize='` [ `@auto` | cellstr | char | *empty* ] - List of
% transition variables that will be exogenized when computing the steady
% state; the number of exogenized variables must match the number of
% parameters exogenized in the `'Exogenize='` option. The use of the
% keyword `@auto` is explained in Description.
%
% * `'Fix='` [ cellstr | *empty* ] - List of variables whose steady state
% will not be computed and kept fixed to the currently assigned values.
%
% * `'FixAllBut='` [ cellstr | *empty* ] - Inverse list of variables whose
% steady state will not be computed and kept fixed to the currently
% assigned values.
%
% * `'FixGrowth='` [ cellstr | *empty* ] - List of variables whose
% steady-state growth will not be computed and kept fixed to the currently
% assigned values.
%
% * `'FixGrowthAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state growth will not be computed and kept fixed to the
% currently assigned values.
%
% * `'FixLevel='` [ cellstr | *empty* ] - List of variables whose
% steady-state levels will not be computed and kept fixed to the currently
% assigned values.
%
% * `'FixLevelAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state levels will not be computed and kept fixed to the
% currently assigned values.
%
% * `'Growth='` [ `true` | *`false`* ] - If `true`, both the steady-state levels
% and growth rates will be computed; if `false`, only the levels will be
% computed assuming that the model is either stationary or that the
% correct steady-state growth rates are already assigned in the model
% object.
%
% * `'LogMinus='` [ cell | char | *empty* ] - List of log variables whose
% steady state will be restricted to negative values in this run of
% `sstate`.
%
% * `'OptimSet='` [ cell | struct | *empty* ] - Name-value pairs in a cell
% array or struct to supply Optim Tbx settings; see `help optimset` for
% details on these settings.
%
% * `'Reuse='` [ `true` | *`false`* ] - Reuse the steady-state values
% calculated for a parameterisation to initialise the next
% parameterisation.
%
% * `'Solver='` [ `'fsolve'` | *`'lsqnonlin'`* ] - Numerical routine to
% solve for steady state of nonlinear models; it can be one of the two
% Optimization Tbx functions.
%
% * `'Sstate='` [ `true` | *`false`* | cell ] - If `true` or a cell array, the
% steady state is re-computed in each iteration; the cell array can be used
% to modify the default options with which the `sstate` function is called.
%
% * `'Unlog='` [ cell | char | *empty* ] - List of log variables that will
% be temporarily treated as non-log variables in this run of `sstate`, i.e.
% their steady-state levels will not be restricted to either positive or
% negative values.
%
% __Options for Linear Models__
%
% * `'Solve='` [ `true` | *`false`* ] - Solve model before computing steady
% state.
%
%
% __Description__
%
%
% _Non-Stationary Models_
%
% For backward compatibility, the option `'Growth='` is set to `false` by
% default so that either the model is assumed stationary or the
% steady-state growth rates have been already pre-assigned to the model
% object. To use the `sstate` function for computing both the steady-state
% levels and steady-state growth rates in a balanced-growth model, you need
% to set the option `'growth=' true`.
%
%
% _Lower and Upper Bounds_
%
% Use options `'LevelBounds='` and `'GrowthBounds='` to impose lower and/or
% upper bounds on steady-state levels and/or growth rates of selected
% variables. Create a struct with a 1-by-2 vector `[lowerBnd, upperBnd]` for
% each variable that is supposed to be bounded when the steady state is
% being calculated, and pass the struct into the respective option. User
% `-Inf` or `Inf` if only one of the bounds is specified. For instance, the
% following piece of code
%
%     bnd = struct( );
%     bnd.X = [0, 10];
%     bnd.Y = [-Inf, 20];
%     bnd.Z = [5, Inf];
%
% specifies lower bounds for variables `X` and `Z`, and upper bounds for
% variables `X` and `Y`. The variables that are not bounded do not need to
% be included in the struct.
%
%
% _Using @auto in Exogenizing/Endogenizing Variables/Parameters_
%
% Use the keyword `@auto` to refer to `!steady_autoexog` definitions when
% setting the options `'Exogenize='` and `'Exogenize=' in the following
% three possible combinations:
%
% * Setting both `'Exogenize='` and `'Endogenize='` to `@auto` will
% exogenize all variables from `!steady_autoexog` definitions and
% endogenize all corresponding parameters.
%
% * Assigning the option '`exogenize='` an explicit list of variables while
% setting `'Endogenize='` to `@auto` will exogenize only the listed
% variables while endogenizing the same number of the corresponding
% parameters from `!steady_autoexoge` definitions. The listed variables
% must each be found on the left-hand sides of a `!steady_autoexog`
% definition.
%
% * Setting '`exogenize='` to `@auto` while assigning the option
% `'endogenize=`' an explicit list of parameters will exogenize only the
% variables that occur on the left-hand sides of those `!steady_autoexog`
% definitions that have the listed parameters on their right-hand sides.
% The listed parameters must each be found on the right-hand side of a
% `!steady_autoexog` definition.
%
%
% __Example__
%
% This example illustrates the use of the keyword `@auto` in
% exogenizing/endogenizing variabes/parameters. Assume that the underlying
% model file included the following sections:
%
%     !variables
%         W, X, Y, Z
%     !parameters
%         alpha, beta, gamma, delta
%
%     !steady_autoexog
%         W := alpha;
%         Y := beta;
%         Z := delta;
%
% Running the following command
%
%     m = sstate(m, 'Exogenize=', @auto, 'Endogenize=', @auto)
%
% will calculate the steady state with all three variables from the
% `!steady_autoexog` defintions, `W`, `Y`, and `Z`, exogenized to their
% currently assigned values while endogenizing the three corresponding
% parameters, `alpha`, `beta`, and `delta`.
%
% Running the following command
%
%     m = sstate(m, 'Exogenize=', 'W, Z', 'Endogenize=', @auto)
%
% or 
%
%     m = sstate(m, 'Exogenize=', {'W', 'Z'}, 'Endogenize=', @auto)
%
% will calculate the steady state with the two listed variables, `W` and
% `Z`, exogenized and the corresponding parameters, `alpha` and `delta`, 
% endogenized.
%
% Finally, running the following command
%
%     m = sstate(m, 'Exogenize=', @auto, 'Endogenize=', 'delta, beta')
%
% or 
%
%     m = sstate(m, 'Exogenize=', @auto, 'Endogenize=', {'delta', 'beta'})
%
% will calculate the steady state with two variables, `Z` and `Y`, 
% (corresponding to the endogenized parameters listed) exogenized while
% endogenizing the listed parameters, `alpha` and `delta`.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

steady = prepareSteady(this, 'verbose', varargin{:});

%--------------------------------------------------------------------------

if this.IsLinear
    [this, flag, nPath, eigen] = steadyLinear(this, steady, Inf);
else
    [this, flag] = steadyNonlinear(this, steady, Inf);
end

end%

