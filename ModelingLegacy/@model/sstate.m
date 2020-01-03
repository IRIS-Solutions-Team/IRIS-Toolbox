function [this, flag, outputInfo] = sstate(this, varargin)
% sstate  Compute sstate state or balance-growth path of the model
%
% ## Syntax ##
%
%     [m, flag, outputInfo] = sstate(m, ...)
%
%
% ## Input Arguments ##
%
% * `m` [ model ] - Parameterized model object.
%
%
% ## Output Arguments ##
%
% * `m` [ model ] - Model object with newly computed steady state assigned.
%
% * `flag` [ `true` | `false` ] - True for parameter variants where steady
% state has been found successfully.
%
% * `outputInfo` [ struct ] - Additional information about steady state
% calculations.
%
%
% ## Options ##
%
% * `'Warning='` [ *`true`* | `false` ] - Display IRIS warning produced by
% this function.
%
%
% ## Options for Nonlinear Models ##
%
% * `Blocks=true` [ `true` | `false` ] - Rearrange steady-state equations
% in sequential blocks before computing steady state.
%
% * `Display='iter'` [ `'iter'` | `'final'` | `'notify'` | `'off'` ] -
% Level of screen output.
%
% * `Endogenize=[ ]` [ `@auto` | cellstr | char | *empty* ] - List of
% parameters that will be endogenized when computing the steady state; the
% number of endogenized parameters must match the number of transtion
% variables exogenized in the `Exogenize=` option; the use of the keyword
% `@auto` is explained in Description.
%
% * `Exogenize=` [ `@auto` | cellstr | char | *empty* ] - List of
% transition variables that will be exogenized when computing the steady
% state; the number of exogenized variables must match the number of
% parameters exogenized in the `'Exogenize='` option; the use of the
% keyword `@auto` is explained in Description.
%
% * `Fix=[ ]` [ cellstr | `Except` | *empty* ] - List of variables whose
% steady state (both level and change) will not be computed and kept fixed
% to the currently assigned values; alternatively an `Except` wrapper
% object can be used to specify that all variables are to be fixed except
% those listed.
%
% * `FixGrowth=[ ]` [ cellstr | *empty* ] - Same as `Fix=` except that this
% option fixes only the steady-state first difference (variables not declared as
% log) or the steady-state rates of change (variables declared as log) of
% each variables listed.
%
% * `FixLevel=[ ]` [ cellstr | *empty* ] - Same as `Fix=` except that this
% option fixes only the steady-state level of each variable listed.
%
% * `Growth=false` [ `true` | `false` ] - If `true`, both the steady-state
% levels and growth rates will be computed; if `false`, only the levels
% will be computed assuming that either all model variables are stationary,
% have stochastic trend without deterministic drift, or that the correct
% steady-state changes are already assigned in the model object.
%
% * `LogMinus=empty` [ cell | char | *empty* ] - List of log variables
% whose steady state will be restricted to negative values in this run of
% `sstate(~)`.
%
% * `Reuse=false` [ `true` | `false` ] - Reuse the steady-state values
% calculated for one parameter variant to initialize the steady-state
% calculation for the next parameter variant.
%
% * `Solver='IRIS-Qnsd'` [ `'IRIS-Qnsd'` | `'IRIS-Newton'` | `'fsolve'` |
% `'lsqnonlin'` | cell ] - Numerical routine to solve the steady state of
% nonlinear models complemented possibly with its options; see Description.
%
% * `Unlog=[ ]` [ cell | char | *empty* ] - List of log variables that will
% be temporarily treated as non-log variables in this run of `steady(~)`,
% i.e.  their steady-state levels will not be restricted to either positive
% or negative values.
%
%
% ## Options for Linear Models ##
%
% * `Solve=false` [ `true` | `false` ] - Calculate first-order solution
% before steady state.
%
%
% ## Description ##
%
%
% _Option Growth=_
%
% The option `Growth=` is `false` by default which is consistent with one
% of the following situations:
%
% * all model variables are either stationary or have stochastic trend but
% no deterministic trend (no deterministic trend: the simplest example is a
% plain vanilla random walk with no drift);
%
% * the steady-state first differences (for variables not declared as log)
% and steady-state rates of growth (for variables declared as log) have
% been assigned (as imaginary parts) in the model object for all variables
% before running `sstate(~)(~)`.
%
% If some variables have an unknown deterministic trend (drift) in steady
% state (for instance, a balanced growth path model), `sstate(~)(~)` needs to
% be run with `Growth=true`.
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
% _Using @auto in Options Exogenize= and Endogenize=_
%
% The keyword `@auto` refers to `!steady-autoswaps` definitions and can be
% used in the options `Exogenize=` and `Exogenize=` in the following three
% possible combinations:
%
% * Setting both `Exogenize=` and `Endogenize=` to `@auto` will
% exogenize all variables from `!steady-autoswaps` definitions and
% endogenize all corresponding parameters.
%
% * Assigning the option `Exogenize=` an explicit list of variables while
% setting `Endogenize=` to `@auto` will exogenize only the listed
% variables while endogenizing the same number of the corresponding
% parameters from `!steady-autoswaps` definitions. The listed variables
% must each be found on the left-hand sides of a `!steady-autoswaps`
% definition.
%
% * Setting `Exogenize=` to `@auto` while assigning the option
% `Endogenize=` an explicit list of parameters will exogenize only the
% variables that occur on the left-hand sides of those `!steady-autoswaps`
% definitions that have the listed parameters on their right-hand sides.
% The listed parameters must each be found on the right-hand side of a
% `!steady-autoswaps` definition.
%
%
% _Options Fix=, FixLevel= and FixGrowth=_
%
% Options `Fix=`, `FixLevel=` and `FixGrowth=` can be used for fixing the
% steady state of a subset of variables (their steady-state levels,
% changes, or both) to values supplied by the user before running
% `sstate(~)`. The fixed values need to be assigned to the respective
% variables directly in the model object, and obviously need to be the
% correct steady-state values. The variables are excluded from the list of
% unknowns when the steady-state equations are being solved.
%
% The list of variables assigned to the three options can be also defined
% inversely using a `Except` wrapper object, constructed by passing the
% list of variables that are _not_ to be fixed. For instance, in
%
%     sstate(m, 'FixGrowth=', Except('x', 'y'))
%
%  the steady-state growth of all variables except `x` and `y` will be
%  fixed (and needs to be supplied before calling this `sstate(~)`).
%
%
% ## Example ##
%
% This example illustrates the use of the keyword `@auto` in
% exogenizing/endogenizing variabes/parameters. Assume that the underlying
% model file included the following sections:
%
%     !variables
%         W, X, Y, Z
%
%     !parameters
%         alpha, beta, gamma, delta
%
%     !steady-autoswaps
%         W := alpha;
%         Y := beta;
%         Z := delta;
%
% Running the following command
%
%     m = sstate(m, 'Exogenize=', @auto, 'Endogenize=', @auto)
%
% will calculate the steady state with all three variables from the
% `!steady-autoswaps` defintions, `W`, `Y`, and `Z`, exogenized to their
% currently assigned values while endogenizing the three corresponding
% parameters, `alpha`, `beta`, and `delta`.
%
% Running the following command
%
%     m = sstate(m, 'Exogenize=', {'W', 'Z'}, 'Endogenize=', @auto)
%
% will calculate the steady state with the two listed variables, `W` and
% `Z`, exogenized and the corresponding parameters, `alpha` and `delta`, 
% endogenized.
%
% Finally, running the following command
%
%     m = sstate(m, 'Exogenize=', @auto, 'Endogenize=', {'delta', 'beta'})
%
% will calculate the steady state with two variables, `Z` and `Y`, 
% (corresponding to the endogenized parameters listed) exogenized while
% endogenizing the listed parameters, `alpha` and `delta`.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

steady = prepareSteady(this, 'verbose', varargin{:});

%--------------------------------------------------------------------------

if this.IsLinear
    [this, flag, outputInfo] = steadyLinear(this, steady, Inf);
else
    [this, flag, outputInfo] = steadyNonlinear(this, steady, Inf);
end

end%

