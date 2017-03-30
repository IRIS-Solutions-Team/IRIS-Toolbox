function [opt,OO] = myoptimopts(opt)
% myoptimoptions  Set up Optim Tbx options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    solverName = opt.solver;
catch
    solverName = opt.Solver;
end

if iscell(solverName)
    solverName = solverName{1};
end
if isfunc(solverName)
    solverName = func2str(solverName);
end

switch lower(solverName)
    case {'pso','alps'}
        if strcmpi(opt.nosolution,'error')
            utils.warning('irisoptim:myoptimopts', ...
                ['Global optimization algorithm, ', ...
                'switching from ''noSolution=error'' to ', ...
                '''noSolution=penalty''.']);
            opt.nosolution = 'penalty';
        end
    case {'fmin','fmincon','fminunc','lsqnonlin','fsolve'}
        switch lower(solverName)
            case {'lsqnonlin','fsolve'}
                algorithm = 'levenberg-marquardt';
            otherwise
                algorithm = 'active-set';
        end
        OO = optimset( ...
            'Algorithm',algorithm, ...
            'GradObj','off', ...
            'Hessian','off', ...
            'LargeScale','off');
        try %#ok<TRYNC>
            x = opt.display;
            if isintscalar(x)
                if x == 0
                    x = 'none';
                elseif x > 0
                    x = 'iter';
                end
            elseif islogicalscalar(x)
                if x
                    x = 'iter';
                else
                    x = 'none';
                end
            end
            OO = optimset(OO,'Display',x);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'MaxIter',opt.maxiter);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'MaxFunEvals',opt.maxfunevals);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'TolFun',opt.tolfun);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'TolX',opt.tolx);
        end
        if ~isempty(opt.optimset) && iscell(opt.optimset) ...
                && iscellstr(opt.optimset(1:2:end))
            temp = opt.optimset;
            temp(1:2:end) = strrep(temp(1:2:end),'=','');
            OO = optimset(OO,temp{:});
        end
        opt.optimset = OO;
    otherwise
        OO = optimset( );
end

end
