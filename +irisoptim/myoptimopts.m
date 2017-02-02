function [Opt,OO] = myoptimopts(Opt)
% myoptimoptions  [Not a public function] Set up Optim Tbx options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

solverName = Opt.solver;
if iscell(solverName)
    solverName = solverName{1};
end
if isfunc(solverName)
    solverName = func2str(solverName);
end

switch lower(solverName)
    case {'pso','alps'}
        if strcmpi(Opt.nosolution,'error')
            utils.warning('irisoptim:myoptimopts', ...
                ['Global optimization algorithm, ', ...
                'switching from ''noSolution=error'' to ', ...
                '''noSolution=penalty''.']);
            Opt.nosolution = 'penalty';
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
            x = Opt.display;
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
            OO = optimset(OO,'MaxIter',Opt.maxiter);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'MaxFunEvals',Opt.maxfunevals);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'TolFun',Opt.tolfun);
        end
        try %#ok<TRYNC>
            OO = optimset(OO,'TolX',Opt.tolx);
        end
        if ~isempty(Opt.optimset) && iscell(Opt.optimset) ...
                && iscellstr(Opt.optimset(1:2:end))
            temp = Opt.optimset;
            temp(1:2:end) = strrep(temp(1:2:end),'=','');
            OO = optimset(OO,temp{:});
        end
        Opt.optimset = OO;
    otherwise
        OO = optimset( );
end

end
