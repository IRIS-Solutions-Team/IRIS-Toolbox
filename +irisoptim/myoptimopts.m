function [opt, OO] = myoptimopts(opt)
% myoptimoptions  Set up Optim Tbx options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

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
    case {'pso', 'alps'}
        if strcmpi(opt.NoSolution, 'error')
            utils.warning('irisoptim:myoptimopts', ...
                ['Global optimization algorithm, ', ...
                'switching from ''noSolution=error'' to ', ...
                '''noSolution=penalty''.']);
            opt.NoSolution = 'penalty';
        end
    case {'fmin', 'fmincon', 'fminunc', 'lsqnonlin', 'fsolve'}
        switch lower(solverName)
            case {'lsqnonlin', 'fsolve'}
                algorithm = 'levenberg-marquardt';
            otherwise
                algorithm = 'active-set';
        end
        OO = optimset( ...
            'Algorithm', algorithm, ...
            'GradObj', 'off', ...
            'Hessian', 'off', ...
            'LargeScale', 'off');
        try %#ok<TRYNC>
            x = opt.Display;
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
            OO = optimset(OO, 'Display', x);
        end
        try %#ok<TRYNC>
            OO = optimset(OO, 'MaxIter', opt.MaxIter);
        end
        try %#ok<TRYNC>
            OO = optimset(OO, 'MaxFunEvals', opt.MaxFunEvals);
        end
        try %#ok<TRYNC>
            OO = optimset(OO, 'TolFun', opt.TolFun);
        end
        try %#ok<TRYNC>
            OO = optimset(OO, 'TolX', opt.TolX);
        end
        if ~isempty(opt.OptimSet) && iscell(opt.OptimSet) ...
                && iscellstr(opt.OptimSet(1:2:end))
            temp = opt.OptimSet;
            temp(1:2:end) = strrep(temp(1:2:end), '=', '');
            OO = optimset(OO, temp{:});
        end
        opt.OptimSet = OO;
    otherwise
        OO = optimset( );
end

end
