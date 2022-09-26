%{
% 
% # `solve` ^^(Model)^^
% 
% {== Calculate first-order solution matrices ==}
% 
% 
% ## Syntax 
% 
%     m = solve(model, ...)
% 
% 
% ## Input arguments 
% 
% __`model`__ [ Model ]
% > 
% > Model object with all active parameters assigned; nonlinear models
% > must also have the steady state values assigned for all variables.
% > 
% 
% ## Output arguments 
% 
% __`model`__ [ Model ]
% > 
% > Model with a newly computed solution for each parameter variant.
% > 
% 
% ## Options 
% 
% __`Expand=0`__ [ numeric | `NaN` ]
% > 
% > Number of periods ahead up to which the model solution will be
% > expanded; if `NaN` the matrices needed to support solution expansion
% > are not calculated and stored at all and the model cannot be used
% > later in simulations or forecasts with anticipated shocks or plans.
% > 
% 
% __`Eqtn=@all`__ [ `@all` | `"measurement"` | `"transition"` ]
% > 
% > Update existing solution in the measurement block, or the transition
% > block, or both.
% > 
% 
% __`Error=false`__ [ `true` | `false` ]
% > 
% > Throw an error if no unique stable solution exists; if `false`, a
% > warning message only will be displayed.
% > 
% 
% __`PreferredSchur="schur"`__ [ `"schur"` | `"qz"` ]
% > 
% > The preferred form of Schur decomposition for purely backward looking
% > models; `PreferredSchur="schur"` means plain Schur decomposition
% > (faster), `PreferredSchur="qz"` means generalized Schur decomposition
% > (unnecessary for backward looking models but consistent with forward
% > looking model solutions). 
% > 
% 
% __`Progress=false`__ [ `true` | `false` ]
% > 
% > Display progress bar in the command window.
% > 
% 
% __`Select=true`__ [ `true` | `false` ]
% > 
% > Automatically detect which equations need to be re-differentiated
% > based on parameter changes from the last time the system matrices
% > were calculated.
% > 
% 
% __`Warning=true`__ [ `true` | `false` ]
% > 
% > Display warnings produced by this function.
% > 
% 
% ## Description 
% 
% The IrisT solver uses an ordered QZ (or generalised Schur) decomposition
% to integrate out future expectations. The QZ may (very rarely) fail for
% numerical reasons. IrisT  includes two patches to handle the some of the
% QZ failures: a SEVN2 patch (Sum-of-EigenValues-Near-Two), and an E2C2S
% patch (Eigenvalues-Too-Close-To-Swap).
% 
% 
% * The SEVN2 patch: The model contains two or more unit roots, and the QZ
% algorithm interprets some of them incorrectly as pairs of eigenvalues
% that sum up accurately to 2, but with one of them significantly below 1
% and the other significantly above 1. IrisT replaces the entries on the
% diagonal of one of the QZ factor matrices with numbers that evaluate to
% two unit roots.
% 
% 
% * The E2C2S patch: The re-ordering of thq QZ matrices fails with a
% warning `"Reordering failed because some eigenvalues are too close to
% swap."` IrisT attempts to re-order the equations until QZ works. The
% number of attempts is limited to `N-1` at most where `N` is the total
% number of equations.
% 
% 
% ## Example 
% 
% 
%}
% --8<--


% solve  Calculate first-order accurate solution of the model


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, exitFlag, info] = solve(this, varargin)

opt = prepareSolve(this, varargin{:});

if any(this.Link)
    this = refresh(this);
end

if opt.Warning
    % Warning if some parameters are NaN, or some log-lin variables have
    % non-positive steady state
    chkList = { 'parameters.dynamic', 'log' };
    if ~this.LinearStatus
        chkList = [ chkList, {'sstate'} ];
    end
    chkQty(this, Inf, chkList{:});
end

% Calculate solutions for all parameterisations, and store expansion
% matrices.
[this, info] = solveFirstOrder(this, Inf, opt);
exitFlag = info.ExitFlag;

if (opt.Warning || opt.Error) && ~all(hasSucceeded(info.ExitFlag))
    here_reportFailure( );
end

return

    function here_reportFailure()
        %(
        if opt.Error
            msgFunc = @(varargin) utils.error(varargin{:});
        else
            msgFunc = @(varargin) utils.warning(varargin{:});
        end
        [body, args] = solveFail(this, info);
        msgFunc('model:solve', body, args{:});
        %)
    end%
end%

