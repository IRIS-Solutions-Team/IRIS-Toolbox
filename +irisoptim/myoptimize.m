function [pStar, objStar, hess, lmb] = myoptimize(fnObj, x0, lb, ub, opt, varargin)
% myoptimize  Call optimizer.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

np = length(x0);
hess = {zeros(np), zeros(np), zeros(np)};
lmb = [ ];

if ischar(opt.Solver)
    % __Optimization toolbox__
    if strncmpi(opt.Solver, 'fmin', 4)
        % Unconstrained minimization.
        if all(isinf(lb)) && all(isinf(ub))
            [pStar, objStar, ~, ~, ~, hess{1}] = ...
                fminunc(fnObj, x0, opt.OptimSet, ...
                varargin{:});
            lmb = struct('lower', zeros(np, 1), 'upper', zeros(np, 1));
        else
            % Constrained minimization.
            [pStar, objStar, ~, ~, lmb, ~, hess{1}] = ...
                fmincon(fnObj, x0, ...
                [ ], [ ], [ ], [ ], lb, ub, [ ], opt.OptimSet, ...
                varargin{:});
        end
    elseif strcmpi(opt.Solver, 'lsqnonlin')
        % Nonlinear least squares.
        [pStar, objStar, ~, ~, ~, lmb] = ...
            lsqnonlin(fnObj, x0, lb, ub, opt.OptimSet, ...
            varargin{:});
    elseif strcmpi(opt.Solver, 'pso')
        % IRIS Optimization Toolbox
        %--------------------------
        [pStar, objStar, ~, ~, ~, ~, lmb] = ...
            irisoptim.pso(fnObj, x0, lb, ub, ...
            opt.OptimSet{:}, ...
            varargin{:});
    elseif strcmpi(opt.Solver, 'irismin')
        % IRIS Optimization Toolbox
        %--------------------------
        [pStar, objStar, hess{1}] ...
            = irisoptim.irismin(fnObj, x0, ...
            opt.OptimSet{:}, varargin) ;
    elseif strcmpi(opt.Solver, 'alps')
        % ALPS
        %--------------------------
        [pStar, objStar, lmb] ...
            = irisoptim.alps(fnObj, x0, lb, ub, ...
            opt.OptimSet{:}) ;
    end
else

    % __User-Supplied Optimization Routine__
    if isa(opt.Solver, 'function_handle')
        % User supplied function handle.
        f = opt.Solver;
        args = { };
    else
        % User supplied cell `{func, arg1, arg2, ...}`.
        f = opt.Solver{1};
        args = opt.Solver(2:end);
    end
    [pStar, objStar, hess{1}] = ...
        f(fnObj, ...
        x0, lb, ub, opt.OptimSet, args{:});

end
