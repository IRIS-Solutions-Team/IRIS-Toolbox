%{
% 
% # `steady` ^^(Model)^^
% 
% {== Compute steady state or balance-growth path of the model ==}
% 
% ## Syntax
% 
%     [model, success, info] = steady(model, ...)
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ]
% > 
% > Model for which the steady state values of its variables will be
% > calculated.
% > 
% 
% ## Output arguments
% 
% __`model`__ [ Model ]
% > 
% > Model with its newly calculated steady state values assigned.
% > 
% 
% __`success`__ [ logical ]
% > 
% > A 1-by-n array of `true` or `false` where n is the number of parameter
% > variants in the `model`; each `true` indicates a successeful completion
% > (convergence) of steady state calculations.
% > 
% 
% __`info`__ [ struct ]
% > 
% > Output info structure with the following fields:
% > 
% > * `.ExitFlags` - a 1-by-n cell array of arrays of solver.ExitFlag objects; the {i}(j)
% >   element indicates the exit flag for the i-th parameter variant and j-th
% >   block of steady equations.
% > 
% > * `.Blazer` - contains a solver.blazer.Steady object used when
% >   calculating the steady state values for each parameter variant.
% > 
% 
% ## Options
% 
% * `Warning=true` [ `true` | `false` ] 
% > 
% > Display IrisT warning messages produced by this function.
% > 
% 
% ## Options for nonlinear models
% 
% * `Blocks=true` [ `true` | `false` ] - Rearrange steady-state equations
% in sequential blocks before computing steady state.
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
% __`FixLevel=[ ]`__ [ cellstr | *empty* ] - Same as `Fix=` except that this
% option fixes only the steady-state level of each variable listed.
% 
% __`Growth=[]`__ [ `true` | `false` | empty ] 
% > 
% > 
% > If `true`, both the steady-state levels and steady-state changes
% > (differences or growth rates, depending on the log status of the respective
% > variable) will be computed; if `false`, only the levels will be computed
% > assuming that either all model variables are stationary, have stochastic
% > trend without deterministic drift, or that the correct steady-state changes
% > are already assigned in the model object.
% > 
% 
% * `LogMinus=empty` [ cell | char | *empty* ] - List of log variables
% whose steady state will be restricted to negative values in this run of
% `sstate(~)`.
% 
% * `Reuse=false` [ `true` | `false` ] - Reuse the steady-state values
% calculated for one parameter variant to initialize the steady-state
% calculation for the next parameter variant.
% 
% * `Solver="qnsd"` [ `"qnsd"` | `"newton"` | `"fsolve"` | `"lsqnonlin"` | cell ] 
% > 
% > Numerical nonlinear solver (optionally also specified including
% > non-default settings) used in steady state calculations; see Description;
% > the default solver, "qnsd", is an IrisT quasi-Newton steepest-descent
% > based algorithm.
% > 
% 
% * `Unlog=[ ]` [ cell | char | *empty* ] - List of log variables that will
% be temporarily treated as non-log variables in this run of `steady(~)`,
% i.e.  their steady-state levels will not be restricted to either positive
% or negative values.
% 
% 
% ## Options for linear models
% 
% * `Solve=false` [ `true` | `false` ] 
% > 
% > Calculate first-order solution before steady state.
% > 
% 
% ## Description
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
% Use options `'LevelWithin='` and `'ChangeWithin='` to impose lower and/or
% upper bounds on steady-state levels and/or growth rates of selected
% variables. Create a struct with a 1-by-2 vector `[lower, upper]` for
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
% %
% 
% 
%}
% --8<--


% Type `web Model/steady.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [this, flag, outputInfo] = steady(this, varargin)

    steadyRunner = prepareSteady(this, varargin{:});
    if steadyRunner.Run
        [this, flag, outputInfo] = steadyRunner.Func(this, Inf, steadyRunner.Arguments{:});
    end

end%

