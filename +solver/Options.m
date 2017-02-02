classdef Options
    properties
        Algorithm = 'lm'
        Display = 'iter'
        InitDamping = @auto
        SolverName = 'IRIS'
        MaxIterations = 1000
        MaxFunctionEvaluations = @(inp) 100*inp.NumberOfVariables
        StepTolerance = 1e-12
        FunctionTolerance = 1e-12
        FunctionNorm = @(x) norm(x, 2)
        SpecifyObjectiveGradient = true
        StepDown = 0.8
        StepUp = 1.2
    end
    
    
    
    
    methods (Static)
        function solverOpt = processOptions(solverOpt, displayMode, obsoleteSolverOpt)
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
                    temp = passvalopt('solver.SteadyOptimTbx', solverOpt{2:end});
                    solverOpt = optimoptions(solverOpt{1});
                else
                    % 'Solver=' 'lsqnonlin' | 'fsolve'
                    temp = passvalopt('solver.SteadyOptimTbx', obsoleteSolverOpt{:});
                    solverOpt = optimoptions(solverOpt);
                end
                if isequal(temp.Display, true)
                    temp.Display = 'iter';
                elseif isequal(temp.Display, false)
                    temp.Display = 'off';
                end
                temp.Display = silentDisplay(temp.Display, displayMode);
                list = fieldnames(temp);
                for i = 1 : numel(list)
                    name = list{i};
                    if isequal(temp.(name), @default)
                        continue
                    end
                    solverOpt = optimoptions(solverOpt, name, temp.(name));
                end
                
                
            elseif (ischar(solverOpt) && strcmpi(solverOpt, 'IRIS') ) ...
                    || ( iscell(solverOpt) && strcmpi(solverOpt{1}, 'IRIS') && iscellstr(solverOpt(2:2:end)) )
                if iscell(solverOpt)
                    % 'Solver=  { 'IRIS', 'Name=', Value, ... }
                    temp = passvalopt('solver.SteadyIris', solverOpt{2:end});
                else
                    % 'Solver=' 'IRIS'
                    temp = passvalopt('solver.SteadyIris', obsoleteSolverOpt{:});
                end
                temp.Display = silentDisplay(temp.Display, displayMode);
                solverOpt = solver.Options( );
                list = fieldnames(temp);
                for i = 1 : numel(list)
                    name = list{i};
                    if isequal(temp.(name), @default)
                        continue
                    end
                    solverOpt.(name) = temp.(name);
                end
                
            elseif isa(solverOpt, 'function_handle')
                % 'Solver=' @userFunction
                % Do nothing.
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
