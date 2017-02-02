function [pStar, objStar, hess, lmb] = myoptimize(fnObj, x0, lb, ub, opt, varargin)
% myoptimize  Call optimizer.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

np = length(x0);
hess = {zeros(np),zeros(np),zeros(np)};
lmb = [ ];

if ischar(opt.solver)
    % Optimization toolbox
    %----------------------
    if strncmpi(opt.solver,'fmin',4)
        % Unconstrained minimization.
        if all(isinf(lb)) && all(isinf(ub))
            [pStar,objStar,~,~,~,hess{1}] = ...
                fminunc(fnObj,x0,opt.optimset, ...
                varargin{:});
            lmb = struct('lower',zeros(np,1),'upper',zeros(np,1));
        else
            % Constrained minimization.
            [pStar,objStar,~,~,lmb,~,hess{1}] = ...
                fmincon(fnObj,x0, ...
                [ ],[ ],[ ],[ ],lb,ub,[ ],opt.optimset,...
                varargin{:});
        end
    elseif strcmpi(opt.solver,'lsqnonlin')
        % Nonlinear least squares.
        [pStar,objStar,~,~,~,lmb] = ...
            lsqnonlin(fnObj,x0,lb,ub,opt.optimset, ...
            varargin{:});
    elseif strcmpi(opt.solver,'pso')
        % IRIS Optimization Toolbox
        %--------------------------
        [pStar,objStar,~,~,~,~,lmb] = ...
            irisoptim.pso(fnObj,x0,lb,ub,...
            opt.optimset{:},...
            varargin{:});
    elseif strcmpi(opt.solver,'irismin')
        % IRIS Optimization Toolbox
        %--------------------------
        [pStar,objStar,hess{1}] ...
            = irisoptim.irismin(fnObj,x0,...
            opt.optimset{:},varargin) ;
    elseif strcmpi(opt.solver,'alps')
        % ALPS
        %--------------------------
        [pStar,objStar,lmb] ...
            = irisoptim.alps(fnObj,x0,lb,ub,...
            opt.optimset{:}) ;
    end
else
    % User-supplied optimisation routine
    %------------------------------------
    if isa(opt.solver,'function_handle')
        % User supplied function handle.
        f = opt.solver;
        args = { };
    else
        % User supplied cell `{func,arg1,arg2,...}`.
        f = opt.solver{1};
        args = opt.solver(2:end);
    end
    [pStar,objStar,hess{1}] = ...
        f(fnObj, ...
        x0,lb,ub,opt.optimset,args{:});
end
