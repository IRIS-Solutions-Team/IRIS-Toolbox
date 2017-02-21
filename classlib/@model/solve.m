function [this, nPath, eig_] = solve(this, varargin)
% solve  Calculate first-order accurate solution of the model.
%
%
% Syntax
% =======
%
%     M = solve(M,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Paramterised model object. Nonlinear models must also
% have a steady state values assigned.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model with newly computed solution.
%
%
% Options
% ========
%
% * `'Expand='` [ numeric | *`0`* | `NaN` ] - Number of periods ahead up to
% which the model solution will be expanded; if `NaN` the matrices needed
% to support solution expansion are not calculated and stored at all and
% the model cannot be used later in simulations or forecasts with
% anticipated shocks or plans.
%
% * `'Eqtn='` [ *`all`* | `'measurement'` | `'transition'` ] - Update
% existing solution in the measurement block, or the transition block, or
% both.
%
% * `'Error='` [ `true` | *`false`* ] - Throw an error if no unique stable
% solution exists; if `false`, a warning message only will be displayed.
%
% * `'Progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'Select='` [ *`true`* | `false` ] - Automatically detect which
% equations need to be re-differentiated based on parameter changes from
% the last time the system matrices were calculated.
%
% * `'Warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
%
% Description
% ============
%
% The IRIS solver uses an ordered QZ (or generalised Schur) decomposition
% to integrate out future expectations. The QZ may (very rarely) fail for
% numerical reasons. IRIS  includes two patches to handle the some of the
% QZ failures: a SEVN2 patch (Sum-of-EigenValues-Near-Two), and an E2C2S
% patch (Eigenvalues-Too-Close-To-Swap).
%
% * The SEVN2 patch: The model contains two or more unit roots, and the QZ
% algorithm interprets some of them incorrectly as pairs of eigenvalues
% that sum up accurately to 2, but with one of them significantly below 1
% and the other significantly above 1. IRIS replaces the entries on the
% diagonal of one of the QZ factor matrices with numbers that evaluate to
% two unit roots.
%
% * The E2C2S patch: The re-ordering of thq QZ matrices fails with a
% warning `'Reordering failed because some eigenvalues are too close to
% swap.'` IRIS attempts to re-order the equations until QZ works. The
% number of attempts is limited to `N-1` at most where `N` is the total
% number of equations.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox. 2008/10/20.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

opt = passvalopt('model.solve', varargin{:});
opt = prepareSolve(this, 'verbose', opt);

%--------------------------------------------------------------------------

% Refresh dynamic links.
if any( this.Equation.Type==TYPE(4) )
    this = refresh(this);
end

if opt.warning
    % Warning if some parameters are NaN, or some log-lin variables have
    % non-positive steady state.
    chkList = { 'parameters.dynamic', 'log' };
    if ~this.IsLinear
        chkList = [ chkList, {'sstate'} ];
    end
    chkQty(this, Inf, chkList{:});
end

% Calculate solutions for all parameterisations, and store expansion
% matrices.
[this, nPath, nanDeriv, sing2, bk] = solveFirstOrder(this, Inf, opt);

if (opt.warning || opt.error) && any(nPath~=1)
    throwErrWarn( );
end

if nargout>2
    eig_ = model.Variant.get(this.Variant, 'Eigen', ':');
end

return



    function throwErrWarn( )
        if opt.error
            msgFunc = @(varargin) utils.error(varargin{:});
        else
            msgFunc = @(varargin) utils.warning(varargin{:});
        end
        [body, args] = solveFail(this, nPath, nanDeriv, sing2, bk);
        msgFunc('model:solve', body, args{:});
    end
end
