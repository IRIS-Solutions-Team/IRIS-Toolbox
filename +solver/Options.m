classdef Options
    properties
        Algorithm = 'lm'
        Display = 'iter'
        Lambda = [0.1, 1, 10, 100];
        SolverName = 'IRIS'
        JacobPattern = logical.empty(0)
        LargeScale = false
        MaxIterations = 1000
        MaxFunctionEvaluations = @(inp) 100*inp.NumberOfVariables
        StepTolerance = 1e-12
        FiniteDifferenceStepSize = eps( )^(1/3)
        FiniteDifferenceType = 'forward'
        FunctionTolerance = 1e-12
        FunctionNorm = 2
        SpecifyObjectiveGradient = true
        StepDown = 0.8
        StepUp = 1.2
    end


    methods
        function this = Options(varargin)
            if nargin==0
                return
            end
            user = passvalopt(varargin{:});
            this = copyFromStruct(this, user);
        end


        function this = copyFromStruct(this, user)
            list = fieldnames(user);
            for i = 1 : numel(list)
                name = list{i};
                if isequal(user.(name), @default)
                    continue
                end
                this.(name) = user.(name);
            end
        end
    end
    
    
    methods (Static)
        function [solverOpt, prepareGradient] = processOptions(solverOpt, caller,  prepareGradient, displayMode, varargin)
            FN_CHKOPTIMTBX = @(x) ...
                isequal(x, 'lsqnonlin') || isequal(x, 'fsolve') ...
                || isequal(x, @lsqnonlin) || isequal(x, @fsolve);
            
            if isa(solverOpt, 'optim.options.SolverOptions') ...
                    || isa(solverOpt, 'solver.Options')
                % 'Solver=' optimoptions( )
                % 'Solver=' solver.Options( )
                % Do nothing.
                

            elseif FN_CHKOPTIMTBX(solverOpt) ...
                    || ( iscell(solverOpt) && FN_CHKOPTIMTBX(solverOpt{1}) && iscellstr(solverOpt(2:2:end)) )
                if iscell(solverOpt)
                    % 'Solver=' { 'lsqnonlin', 'Name=', Value, ... }
                    user = solverOpt(2:end);
                    solverOpt = optimoptions(solverOpt{1});
                else
                    % 'Solver=' 'lsqnonlin' | 'fsolve'
                    user = varargin;
                    solverOpt = optimoptions(solverOpt);
                end
                user = passvalopt(['solver.Optim', caller], user{:});
                if isequal(user.Display, true)
                    user.Display = 'iter';
                elseif isequal(user.Display, false)
                    user.Display = 'off';
                end
                user.Display = silentDisplay(user.Display, displayMode);
                list = fieldnames(user);
                for i = 1 : numel(list)
                    name = list{i};
                    if isequal(user.(name), @default)
                        continue
                    end
                    solverOpt = optimoptions(solverOpt, name, user.(name));
                end
                
                
            elseif (ischar(solverOpt) && strcmpi(solverOpt, 'IRIS') ) ...
                    || ( iscell(solverOpt) && strcmpi(solverOpt{1}, 'IRIS') && iscellstr(solverOpt(2:2:end)) )
                if iscell(solverOpt)
                    % 'Solver=  { 'IRIS', 'Name=', Value, ... }
                    solverOpt = solverOpt(2:end);
                else
                    % 'Solver=' 'IRIS'
                    % Collect all obsolete options passed outside the
                    % suboption.
                    solverOpt = varargin;
                end
                spec = ['solver.Iris', caller];
                user = passvalopt(spec, solverOpt{:});
                user.Display = silentDisplay(user.Display, displayMode);
                solverOpt = solver.Options(spec);
                solverOpt = copyFromStruct(solverOpt, user);
                
            elseif isa(solverOpt, 'function_handle')
                % 'Solver=' @userFunction
                % Do nothing.
            end
            
            % High-level option PrepareGradient= is used to prepare gradients within the
            % solver.Block object.
            if isequal(prepareGradient, @auto)
                if isa(solverOpt, 'optim.options.SolverOptions') ...
                    || isa(solverOpt, 'solver.Options')
                    prepareGradient = solverOpt.SpecifyObjectiveGradient;
                else
                    prepareGradient = true;
                end
            end

            return
            
            
            function display = silentDisplay(display, mode)
                if strcmpi(display, 'iter*')
                    if strcmpi(mode, 'Silent')
                        display = 'off';
                    else
                        display = 'iter';
                    end
                end
            end
        end
        
    end
end
