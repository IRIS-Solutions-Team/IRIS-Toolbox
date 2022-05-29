% Block  Blazer block object
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef (Abstract) Block < handle
    properties
        % ParentBlazer  Pointer to the parent Blazer object
        ParentBlazer

        % Type  Type of block
        Type

        % Id  Id number of block
        Id

        % SolverOptions  Solver options
        SolverOptions = [ ]

        % IsAnalyticalJacob  Return analytical Jacobian from objective function
        IsAnalyticalJacob = false

        PtrQuantities = double.empty(1, 0)
        PtrEquations = double.empty(1, 0)
        QuantityTypes = double.empty(1, 0)

        EquationsFunc
        NumericalJacobFunc

        % LhsQuantityFormat  Format to create string representing an LHS
        % variable to verify the RHS of possible assignments
        LhsQuantityFormat

        Shift (1, :) double = zeros(1, 0)

        % JacobPattern  Logical index of pairs equation-quantity that has a
        % nonzero gradient, size numEquations-by-numQuantities in the block
        JacobPattern (:, :) logical = logical.empty(0)

        Gradients (3, :) cell = cell(3, 0)

        XX2L
        D

        Lower
        Upper

        RunTime = struct( )
    end


    properties (Dependent)
        NumberOfShifts
        PositionOfZeroShift
        NeedsAnalyticalJacob
    end


    properties (Constant)
        SAVEAS_SECTION = string(repmat(' ', 1, 75))
        SAVEAS_INDENT = "    "
    end


    properties (Abstract, Constant)
        VECTORIZE
        PREAMBLE
    end


    methods
        function this = Block(varargin)
            if nargin==0
                return
            end
            if isa(varargin{1}, 'solver.block.Block')
                this = varargin{1};
                return
            end
        end%


        function classify(this)
            asgn = this.ParentBlazer.Assignments;
            eqtn = this.ParentBlazer.Equations;
            if isempty(this.PtrQuantities) || isempty(this.PtrEquations)
                this.Type = solver.block.Type.EMPTY;
                return
            end
            this.Type = solver.block.Type.SOLVE;
            if numel(this.PtrQuantities)>1 || numel(this.PtrEquations)>1
                return
            end

            % this.PtrEquations is scalar from now on
            lhs = asgn.Lhs(this.PtrEquations);
            type = asgn.Type(this.PtrEquations);
            if this.PtrQuantities==lhs && checkRhsOfAssignment(this, eqtn)
                this.Type = type;
            end
        end%


        function flag = checkRhsOfAssignment(this, eqtn)
            % Verify that the LHS quantity does not occur on the RHS of an assignment.
            c = sprintf(this.LhsQuantityFormat, this.PtrQuantities);
            rhs = solver.block.Block.removeLhs( eqtn{this.PtrEquations} );
            flag = isempty( strfind(rhs, c) );
        end%


        function prepareBlock(this, blazer)
            this.ParentBlazer = blazer;
            classify(this); % Classify block as SOLVE or ASSIGNMENT
            setShift(this); % Find max lag and lead within equations in this block
            createEquationsFunc(this);
        end%


        function createEquationsFunc(this)
            if isempty(this.PtrEquations)
                return
            end
            equationsFunc = [ this.ParentBlazer.Equations{this.PtrEquations} ];
            if ~isempty(this.ParentBlazer.Gradients)
                this.Gradients = this.ParentBlazer.Gradients(:, this.PtrEquations);
            end
            if this.Type==solver.block.Type.SOLVE
                equationsFunc = [ '[', equationsFunc, ']' ];
            else
                equationsFunc = this.removeLhs(equationsFunc);
            end
            if this.VECTORIZE
                equationsFunc = vectorize(equationsFunc);
            end
            this.EquationsFunc = str2func(this.PREAMBLE + string(equationsFunc));
        end%


        function [z, f, exitFlag, lastJacob] = solve(this, fnObjective, z0, exitFlagHeader)
            if isa(this.SolverOptions, 'solver.Options')
                %
                % Iris solvers
                %

                % Iterate over different solver settings until
                % successfully solved
                for i = 1 : numel(this.SolverOptions)
                    this.SolverOptions(i).JacobPattern = this.JacobPattern;
                    [z, f, exitFlag, ~, lastJacob] = solver.algorithm.qnsd( ...
                        fnObjective, z0, this.SolverOptions(i), exitFlagHeader ...
                    );
                    if hasSucceeded(exitFlag)
                        break
                    end
                end

            elseif isa(this.SolverOptions, 'optim.options.SolverOptions')
                %
                % Optim Tbx
                %
                solverName = this.SolverOptions.SolverName;
                if strcmpi(solverName, 'lsqnonlin')
                    this.SolverOptions.JacobPattern = sparse(double(this.JacobPattern));
                    [z, ~, f, exitFlag, ~, ~, lastJacob] = ...
                        lsqnonlin(fnObjective, z0, this.Lower, this.Upper, this.SolverOptions);
                elseif strcmpi(solverName, 'fsolve')
                    %this.SolverOptions.JacobPattern = sparse(double(this.JacobPattern));
                    this.SolverOptions.Algorithm = 'levenberg-marquardt';
                    %this.SolverOptions.Algorithm = 'trust-region';
                    %this.SolverOptions.SubproblemAlgorithm = 'cg';
                    [z, f, exitFlag, ~, lastJacob] = fsolve(fnObjective, z0, this.SolverOptions);
                end
                exitFlag = solver.ExitFlag.fromOptimTbx(exitFlag);
                z = real(z);
                z( abs(z)<=this.SolverOptions.StepTolerance ) = 0;

            elseif isa(this.SolverOptions, 'function_handle')
                %
                % User-supplied solver
                %
                [z, f, exitFlag, lastJacob] = this.SolverOptions(fnObjective, z0);

            else
                exception.error([
                    "Block:UnknownSolver"
                    "Invalid, empty or unknown solver specified."
                ]);
            end
        end%


        function s = print(this, blockId, names, equations)
            numEquations = numel(this.PtrEquations);
            s = sprintf("\n") ...
                + sprintf("## Block %g  \n\n", blockId) ...
                + sprintf("Number of equations: %g\n\n", numEquations) ...
                + sprintf("%s\n", this.Type.SaveAsKeyword) ...
                + printListUnknowns(this, names) ...
                + sprintf("\n") ...
                + sprintf("Equations:\n") ...
                + printListEquations(this, equations);
        end%




        function s = printListUnknowns(this, names)
            ptrQuantities = this.PtrQuantities;
            if isempty(ptrQuantities) || isempty(names)
                s = "";
                return
            end
            s = "{" + join(names(ptrQuantities), ",") + "}" + sprintf("\n");
        end%




        function s = printListEquations(this, equations)
            ptrEquations = this.PtrEquations;
            if isempty(ptrEquations) || isempty(equations)
                s = "";
                return
            end
            equations = string(equations(ptrEquations));
            separator = sprintf("\n%s", solver.block.Block.SAVEAS_INDENT);
            s = separator + join(string(equations), separator) + sprintf("\n");
        end%




        function setShift(this)
            % Return max lag and max lead across all equations in this block.
            if isEmptyBlock(this.Type)
                return
            end
            incid = selectEquation(this.ParentBlazer.Incidence, this.PtrEquations);
            sh0 = this.ParentBlazer.Incidence.PosZeroShift;
            ixIncid = across(incid, 'Equation');
            ixIncid = any(ixIncid, 1);
            from = find(ixIncid, 1, 'first') - sh0;
            to = find(ixIncid, 1, 'last') - sh0;
            if from>-1 || isempty(from)
                from = -1;
            end
            if to<0 || isempty(to)
                to = 0;
            end
            this.Shift = from : to;
        end%


        function s = size(this)
            s = [1, numel(this.PtrEquations)];
        end%


        function n = get.NumberOfShifts(this)
            n = numel(this.Shift);
        end%


        function sh0 = get.PositionOfZeroShift(this)
            sh0 = find(this.Shift==0);
        end%


        function value = get.NeedsAnalyticalJacob(this)
            %
            % Prepare analytical Jacobian each time a non-Iris solver is
            % used
            %
            if ~isa(this.SolverOptions, 'solver.Options')
                value = true;
                return
            end
            %
            % If an Iris solver is used, check the option Jacobian
            %
            value = startsWith(this.SolverOptions.JacobCalculation, "Analytical", "ignoreCase", true);
        end%
    end


    methods (Abstract)
       prepareForSolver(varargin)
       prepareJacob(varargin)
    end


    methods (Static)
        function eqtn = removeLhs(eqtn)
            close = textfun.matchbrk(eqtn, 2);
            eqtn = eqtn(close+1:end);
            if eqtn(1)=='+'
                eqtn(1) = '';
            end
        end%


        function exitFlag = checkFiniteSolution(z, exitFlag)
            if ~hasSucceeded(exitFlag)
                return
            end
            if any(isnan(z(:)) | isinf(z(:)))
                exitFlag = solver.ExitFlag.NAN_INF_SOLUTION;
            end
        end%
    end
end
