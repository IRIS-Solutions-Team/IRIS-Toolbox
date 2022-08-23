classdef EstimationWrapper < handle
    properties
        SolverFunction
        SolverOptions
        IsConstrained
        Optimum = double.empty(0)
        ObjectiveAtOptimum = NaN
        Hessian = double.empty(0)
        ExitFlag = NaN
        IndexLowerBoundsHit = logical.empty(1, 0)
        IndexUpperBoundsHit = logical.empty(1, 0)
    end


    properties (Constant)
        IS_OPTIM_TBX = ~isempty(ver('optim'))
    end


    methods
        function chooseSolver(this, solver, outsideOptimOpt)
            if iscell(solver)
                solverName = char(solver{1});
                solverOptions = solver(2:end);
                solverOptions(1:2:end) = regexp(solverOptions(1:2:end), '\w+', 'Match', 'Once');
            elseif isa(solver, 'optim.options.SolverOptions')
                solverName = solver.SolverName;
                solverOptions = solver;
            else
                solverName = char(solver);
                solverOptions = cell.empty(1, 0);
            end
            if strcmpi(solverName, 'fmin')
                if this.IS_OPTIM_TBX
                    if this.IsConstrained
                        solverName = 'fmincon';
                    else
                        solverName = 'fminunc';
                    end
                else
                    solverName = 'fminsearch';
                end
            end

            if strcmpi(solverName, 'fminunc')
                optionsFunction = @optimoptions;
                this.SolverOptions = optimoptions( ...
                    'fminunc', 'Algorithm', 'quasi-newton' ...
                );
            elseif strcmpi(solverName, 'fmincon')
                optionsFunction = @optimoptions;
                this.SolverOptions = optimoptions( ...
                    solverName, 'Algorithm', 'active-set' ...
                );
            else
                optionsFunction = @optimset;
                this.SolverOptions = optimset( );
            end
            fields = fieldnames(outsideOptimOpt);
            for i = 1 : numel(fields)
                value = outsideOptimOpt.(fields{i});
                if ~isequal(value, @auto)
                    this.SolverOptions = optionsFunction( ...
                        this.SolverOptions, fields{i}, value ...
                    );
                end
            end
                
            if any(strcmpi(solverName, {'fmincon', 'fminunc'}))
                this.SolverFunction = str2func(solverName);
                if iscell(solverOptions)
                    this.SolverOptions = optimoptions(this.SolverOptions, solverOptions{:});
                else
                    this.SolverOptions = optimoptions(this.SolverOptions, solverOptions);
                end
            else
                if isa(solver, 'function_handle')
                    this.SolverFunction = solver;
                else
                    this.SolverFunction = str2func(solverName);
                end
                if iscell(solverOptions)
                    this.SolverOptions = optimset(this.SolverOptions, solverOptions{:});
                else
                    this.SolverOptions = optimset(this.SolverOptions, solverOptions);
                end
            end
        end%


        function run(this, objectiveFunction, initial, lowerBounds, upperBounds)
            numInitial = numel(initial);
            this.Optimum = nan(1, numInitial);
            this.Hessian = nan(numInitial);
            this.IndexLowerBoundsHit = false(1, numInitial);
            this.IndexUpperBoundsHit = false(1, numInitial);
            if isequal(this.SolverFunction, @fminunc)
                % __FMINUNC__
                [this.Optimum(:), this.ObjectiveAtOptimum, this.ExitFlag, ~, ~, this.Hessian(:, :)] = ...
                    fminunc(objectiveFunction, initial, this.SolverOptions);
                this.IndexLowerBoundsHit(:) = this.Optimum<=lowerBounds;
                this.IndexUpperBoundsHit(:) = this.Optimum>=upperBounds;
            elseif isequal(this.SolverFunction, @fmincon)
                % __FMINCON__
                [this.Optimum(:), this.ObjectiveAtOptimum, this.ExitFlag, ~, lambda, grad, this.Hessian(:, :)] = ...
                    fmincon( ...
                        objectiveFunction, initial, ...
                        [ ], [ ], [ ], [ ], lowerBounds, upperBounds, [ ], ...
                        this.SolverOptions ...
                    );
                this.IndexLowerBoundsHit(:) = double(lambda.lower)~=0;
                this.IndexUpperBoundsHit(:) = double(lambda.upper)~=0;
            elseif isequal(this.SolverFunction, @fminsearch)
                % __FMINSEARCH__
                [this.Optimum(:), this.ObjectiveAtOptimum, this.ExitFlag] = ...
                    fminsearch(objectiveFunction, initial, this.SolverOptions);
                this.IndexLowerBoundsHit(:) = this.Optimum<=lowerBounds;
                this.IndexUpperBoundsHit(:) = this.Optimum>=upperBounds;
            else
                % __User-Supplied Solver__
                % [this.Optimum(:), this.ObjectiveAtOptimum, userHessian] = ...
                this.Optimum(:) = ...
                    this.SolverFunction( ...
                        objectiveFunction, initial, ...
                        lowerBounds, upperBounds, ...
                        this.SolverOptions ...
                    );
                this.ObjectiveAtOptimum = objectiveFunction(this.Optimum);
                %if isnumeric(userHessian) &&  isequal(size(this.Hessian), size(userHessian))
                %    this.Hessian(:, :) = userHessian;
                %end
                this.IndexLowerBoundsHit(:) = this.Optimum<=lowerBounds;
                this.IndexUpperBoundsHit(:) = this.Optimum>=upperBounds;
            end
        end%
    end
end
