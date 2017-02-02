function [this, flag, nPath, eigen] = sstate(this, varargin)
% sstate  Compute steady state or balance-growth path of the model.
%
%
% Syntax
% =======
%
%     [M, Flag] = sstate(M,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Parameterised model object.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with newly computed steady state assigned.
%
% * `Flag` [ `true` | `false` ] - True for parameter variants where steady
% state has been found successfully.
%
%
% Options
% ========
%
% * `'linear='` [ *`@auto`* | `true` | `false` ] - Solve for steady state
% using a linear approach, i.e. based on the first-order solution matrices
% and the vector of constants.
% 
% * `'warning='` [ *`true`* | `false` ] - Display IRIS warning produced by
% this function.
%
% Options for nonlinear models
% -----------------------------
%
% * `'blocks='` [ *`true`* | `false` ] - Rearrange steady-state equations
% in sequential blocks before computing steady state.
%
% * `'display='` [ *`'iter'`* | `'final'` | `'notify'` | `'off'` ] - Level
% of screen output, see Optim Tbx.
%
% * `'endogenize='` [ `@auto` | cellstr | char | *empty* ] - List of
% parameters that will be endogenized when computing the steady state; the
% number of endogenized parameters must match the number of transtion
% variables exogenized in the `'exogenized='` option. The use of the
% keyword `@auto` is explained in Description.
%
% * `'exogenize='` [ `@auto` | cellstr | char | *empty* ] - List of
% transition variables that will be exogenized when computing the steady
% state; the number of exogenized variables must match the number of
% parameters exogenized in the `'exogenize='` option. The use of the
% keyword `@auto` is explained in Description.
%
% * `'fix='` [ cellstr | *empty* ] - List of variables whose steady state
% will not be computed and kept fixed to the currently assigned values.
%
% * `'fixAllBut='` [ cellstr | *empty* ] - Inverse list of variables whose
% steady state will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixGrowth='` [ cellstr | *empty* ] - List of variables whose
% steady-state growth will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixGrowthAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state growth will not be computed and kept fixed to the
% currently assigned values.
%
% * `'fixLevel='` [ cellstr | *empty* ] - List of variables whose
% steady-state levels will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixLevelAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state levels will not be computed and kept fixed to the
% currently assigned values.
%
% * `'growth='` [ `true` | *`false`* ] - If `true`, both the steady-state levels
% and growth rates will be computed; if `false`, only the levels will be
% computed assuming that the model is either stationary or that the
% correct steady-state growth rates are already assigned in the model
% object.
%
% * `'logMinus='` [ cell | char | *empty* ] - List of log variables whose
% steady state will be restricted to negative values in this run of
% `sstate`.
%
% * `'optimSet='` [ cell | struct | *empty* ] - Name-value pairs in a cell
% array or struct to supply Optim Tbx settings; see `help optimset` for
% details on these settings.
%
% * `'reuse='` [ `true` | *`false`* ] - Reuse the steady-state values
% calculated for a parameterisation to initialise the next
% parameterisation.
%
% * `'solver='` [ `'fsolve'` | *`'lsqnonlin'`* ] - Numerical routine to
% solve for steady state of nonlinear models; it can be one of the two
% Optimization Tbx functions.
%
% * `'sstate='` [ `true` | *`false`* | cell ] - If `true` or a cell array, the
% steady state is re-computed in each iteration; the cell array can be used
% to modify the default options with which the `sstate` function is called.
%
% * `'unlog='` [ cell | char | *empty* ] - List of log variables that will
% be temporarily treated as non-log variables in this run of `sstate`, i.e.
% their steady-state levels will not be restricted to either positive or
% negative values.
%
% Options for linear models
% --------------------------
%
% * `'solve='` [ `true` | *`false`* ] - Solve model before computing steady
% state.
%
%
% Description
% ============
%
% Non-stationary models
% ----------------------
%
% For backward compatibility, the option `'growth='` is set to `false` by
% default so that either the model is assumed stationary or the
% steady-state growth rates have been already pre-assigned to the model
% object. To use the `sstate` function for computing both the steady-state
% levels and steady-state growth rates in a balanced-growth model, you need
% to set the option `'growth=' true`.
%
% Lower and upper bounds
% -----------------------
%
% Use options `'levelBounds='` and `'growthBounds='` to impose lower and/or
% upper bounds on steady-state levels and/or growth rates of selected
% variables. Create a struct with a 1-by-2 vector `[lowerBnd,upperBnd]` for
% each variable that is supposed to be bounded when the steady state is
% being calculated, and pass the struct into the respective option. User
% `-Inf` or `Inf` if only one of the bounds is specified. For instance, the
% following piece of code
%
%     bnd = struct( );
%     bnd.X = [0,10];
%     bnd.Y = [-Inf,20];
%     bnd.Z = [5,Inf];
%
% specifies lower bounds for variables `X` and `Z`, and upper bounds for
% variables `X` and `Y`. The variables that are not bounded do not need to
% be included in the struct.
%
% Using @auto in exogenizing/endogenizing variabes/parameters
% ------------------------------------------------------------
%
% Use the keyword `@auto` to refer to `!steady_autoexog` definitions when
% setting the options `'exogenize='` and `'exogenize=' in the following
% three possible combinations:
%
% * Setting both `'exogenize='` and `'endogenize='` to `@auto` will
% exogenize all variables from `!steady_autoexog` definitions and
% endogenize all corresponding parameters.
%
% * Assigning the option '`exogenize='` an explicit list of variables while
% setting `'endogenize='` to `@auto` will exogenize only the listed
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
% Example
% ========
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
%     m = sstate(m, 'exogenize=', @auto, 'endogenize=', @auto)
%
% will calculate the steady state with all three variables from the
% `!steady_autoexog` defintions, `W`, `Y`, and `Z`, exogenized to their
% currently assigned values while endogenizing the three corresponding
% parameters, `alpha`, `beta`, and `delta`.
%
% Running the following command
%
%     m = sstate(m, 'exogenize=', 'W, Z', 'endogenize=', @auto)
%
% or 
%
%     m = sstate(m, 'exogenize=', {'W', 'Z'}, 'endogenize=', @auto)
%
% will calculate the steady state with the two listed variables, `W` and
% `Z`, exogenized and the corresponding parameters, `alpha` and `delta`,
% endogenized.
%
% Finally, running the following command
%
%     m = sstate(m, 'exogenize=', @auto, 'endogenize=', 'delta, beta')
%
% or 
%
%     m = sstate(m, 'exogenize=', @auto, 'endogenize=', {'delta', 'beta'})
%
% will calculate the steady state with two variables, `Z` and `Y`,
% (corresponding to the endogenized parameters listed) exogenized while
% endogenizing the listed parameters, `alpha` and `delta`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse options.
[opt, varargin] = passvalopt('model.Steady', varargin{:});

if isequal(opt.Linear, @auto)
    changeLinear = false;
else
    changeLinear = this.IsLinear~=opt.Linear;
    if changeLinear
        wasLinear = this.IsLinear;
        this.IsLinear = opt.Linear;
    end
end

%--------------------------------------------------------------------------

steady = prepareSteady(this, 'verbose', varargin{:});

vecAlt = 1 : length(this.Variant);
if ~this.IsLinear
    % Nonlinear models.
    [this, flag] = steadyNonlinear(this, steady, vecAlt);
else
    % Linear models
    [this, flag, nPath, eigen] = steadyLinear(this, steady, vecAlt);
end

if changeLinear
    this.IsLinear = wasLinear;
end

end
