% Block  Blazer block object
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef (Abstract) Block < handle
    properties
        % Type  Type of block
        Type

        % Id  Id number of block
        Id

        % Solver  Solver options
        Solver

        % RetGradient  Return gradient from objective function
        RetGradient = false 
        
        % NamesInBlock  Names of unknowns to be solved for in this block
        NamesInBlock

        % InxLog  Log status of all model variables
        InxLog

        PtrQuantities = double.empty(1, 0)
        PtrEquations = double.empty(1, 0)

        Equations
        EquationsFunc
        NumericalJacobFunc
        LhsQuantityFormat % Format to create string representing an LHS variable to verify the RHS of possible assignments.
        
        Shift = zeros(1, 0)
        JacobPattern = logical.empty(0)
        Gradient = cell(2, 0)
        
        XX2L
        D
        
        Lower
        Upper
        
        RunTime = struct( )
    end


    properties (Dependent)
        NumberOfShifts
        PositionOfZeroShift
    end
    
    
    properties (Constant)
        SAVEAS_SECTION = string(repmat(' ', 1, 75))
        SAVEAS_INDENT = "    "
    end


    properties (Abstract, Constant)
        VECTORIZE
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


        
        
        function classify(this, asgn, eqtn)
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
            if this.PtrQuantities==lhs && chkRhsOfAssignment(this, eqtn)
                this.Type = type;
            end
        end%


        
        
        function flag = chkRhsOfAssignment(this, eqtn)
            % Verify that the LHS quantity does not occur on the RHS of an assignment.
            c = sprintf(this.LhsQuantityFormat, this.PtrQuantities);
            rhs = solver.block.Block.removeLhs( eqtn{this.PtrEquations} );
            flag = isempty( strfind(rhs, c) );
        end%
        


        
        function prepareBlock(this, blazer, opt)
            if isEmptyBlock(this.Type)
                return
            end
            createEquationsFunc(this, blazer);
            this.NamesInBlock = blazer.Model.Quantity.Name(this.PtrQuantities);
            this.InxLog = blazer.Model.Quantity.InxLog;
        end%




        function prepareForSolver(this, blazer, opt)
            this.Solver = opt.Solver;
            if this.Type==solver.block.Type.SOLVE
                createJacobPattern(this, blazer);
                try
                    if isa(opt.Solver, 'optim.options.SolverOptions') ...
                            || isa(opt.Solver, 'solver.Options')
                        this.Solver.SpecifyObjectiveGradient = ...
                            opt.PrepareGradient && opt.Solver.SpecifyObjectiveGradient;
                    end
                end
            end
        end%




        function createEquationsFunc(this, blazer)
            funcToInclude = [ blazer.Equation{this.PtrEquations} ];
            this.Equations = blazer.Equation(this.PtrEquations);
            if this.Type==solver.block.Type.SOLVE
                funcToInclude = [ '[', funcToInclude, ']' ];
            else
                funcToInclude = this.removeLhs(funcToInclude);
            end
            if this.VECTORIZE
                funcToInclude = vectorize(funcToInclude);
            end
            this.EquationsFunc = str2func([blazer.PREAMBLE, funcToInclude]);
        end%




        function [gr, XX2L, DLevel, DChange0, DChangeK] = createAnalyticalJacob(this, blazer, opt)
            [~, numQuantities] = size(blazer.Incidence);
            numEquationsHere = numel(this.PtrEquations);
            gr = blazer.Gradient(:, this.PtrEquations);
            sh = this.Shift;
            numSh = numel(sh);
            sh0 = find(this.Shift==0);
            aux = sub2ind([numQuantities+1, numSh], numQuantities+1, sh0); % Linear index to 1 in last row.
            XX2L = cell(1, numEquationsHere);
            DLevel = cell(1, numEquationsHere);
            DChange0 = cell(1, numEquationsHere);
            DChangeK = cell(1, numEquationsHere);
            for i = 1 : numEquationsHere
                ptrQuantities = iris.utils.unionRealImag(this.PtrQuantities);
                gr(:, i) = getGradient(this, blazer, this.PtrEquations(i), opt);
                vecWrt = gr{2, i};
                numWrt = length(vecWrt);
                inxOutOfSh = imag(vecWrt)<sh(1) | imag(vecWrt)>sh(end);
                XX2L{i} = ones(1, numWrt)*aux;
                ixLog = blazer.Model.Quantity.IxLog(real(vecWrt));
                vecWrt(inxOutOfSh) = NaN;
                ixLog(inxOutOfSh) = false;
                XX2L{i}(ixLog) = sub2ind( ...
                    [numQuantities+1, numSh], ...
                    real( vecWrt(ixLog) ), ...
                    sh0 + imag(vecWrt(ixLog)) ...
                );
                DLevel{i} = double(bsxfun(@eq, ptrQuantities, real(vecWrt).'));
                if nargout>3
                    DChange0{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).');
                    DChangeK{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).' + this.SteadyShift);
                end
            end
        end%
        


        
        function gr = getGradient(this, blazer, posEqn, opt)
            %
            % Create the gradient for the union of levels and changes
            %
            ptrQuantities = iris.utils.unionRealImag(this.PtrQuantities);

            %
            % Fetch gradient of posEqn-th equation from Blazer object or differentiate
            % again if needed
            %
            vecWrtNeeded = find(blazer.Incidence, posEqn, ptrQuantities);
            vecWrtMissing = setdiff(vecWrtNeeded, blazer.Gradient{2, posEqn});
            if ~opt.ForceRediff ...
                    && isa(blazer.Gradient{1, posEqn}, 'function_handle') ...
                    && isempty(vecWrtMissing)
                % vecWrtNeeded is a subset of vecWrt currently available.
                gr = blazer.Gradient(:, posEqn);
                return
            end

            %
            % Redifferentiate this equation wrt the quantities needed only
            %
            d = model.component.Gradient.diff(blazer.Equation{posEqn}, vecWrtNeeded);
            d = str2func([blazer.PREAMBLE, d]);
            gr = {d; vecWrtNeeded};
        end%
        


        
        function [z, exitFlag] = solve(this, fnObjective, z0, exitFlagHeader)
            if isa(this.Solver, 'solver.Options')
                % __IRIS Solver__
                this.Solver.JacobPattern = this.JacobPattern;
                [z, ~, exitFlag] = solver.algorithm.qnsd(fnObjective, z0, this.Solver, exitFlagHeader);

            elseif isa(this.Solver, 'optim.options.SolverOptions')
                % Optim Tbx
                solverName = this.Solver.SolverName;
                if strcmpi(solverName, 'lsqnonlin')
                    this.Solver.JacobPattern = sparse(double(this.JacobPattern));
                    [z, ~, ~, exitFlag] = ...
                        lsqnonlin(fnObjective, z0, this.Lower, this.Upper, this.Solver);
                elseif strcmpi(solverName, 'fsolve')
                    %this.Solver.JacobPattern = sparse(double(this.JacobPattern));
                    this.Solver.Algorithm = 'levenberg-marquardt';
                    %this.Solver.Algorithm = 'trust-region';
                    %this.Solver.SubproblemAlgorithm = 'cg';
                    [z, ~, exitFlag] = fsolve(fnObjective, z0, this.Solver);
                end
                exitFlag = solver.ExitFlag.fromOptimTbx(exitFlag);
                z = real(z);
                z( abs(z)<=this.Solver.StepTolerance ) = 0;

            elseif isa(this.Solver, 'function_handle')
                % User-Supplied Solver
                [z, ~, exitFlag] = this.Solver(fnObjective, z0);

            else
                thisError = [
                    "Block:UnknownSolver"
                    "Invalid or unknown solution method"
                ];
                throw(exception.Base(thisError, 'error'));
            end
        end%


        

        function s = print(this, blockId, names, equations)
            numEquations = numel(this.PtrEquations);
            s = sprintf("%s\n", solver.block.Block.SAVEAS_SECTION) ...
                + sprintf("%%%% Block #%g\n", blockId) ...
                + sprintf("%% Number of Equations: %g\n", numEquations) ...
                + sprintf("%% %s\n", this.Type.SaveAsKeyword) ...
                + printListUknowns(this, names) ...
                + printListEquations(this, equations);
        end%




        function s = printListUknowns(this, names)
            ptrQuantities = this.PtrQuantities;
            if isempty(ptrQuantities) || isempty(names)
                s = "";
                return
            end
            s = "% " + solver.block.Block.SAVEAS_INDENT ...
                + "(" + join(names(ptrQuantities), ",") + ")" ...
                + sprintf("\n");
        end%




        function s = printListEquations(this, equations)
            ptrEquations = this.PtrEquations;
            if isempty(ptrEquations) || isempty(equations)
                s = "";
                return
            end
            separator = sprintf("\n%s", solver.block.Block.SAVEAS_INDENT);
            s = separator + join(equations(ptrEquations), separator);
        end%


        
        
        function setShift(this, blazer)
            % Return max lag and max lead across all equations in this block.
            if isEmptyBlock(this.Type)
                return
            end
            incid = selectEquation(blazer.Incidence, this.PtrEquations);
            sh0 = blazer.Incidence.PosOfZeroShift;
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
    end




    methods (Abstract)
       varargout = createJacobPattern(varargin) 
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
            if ~all(isfinite(z(:)))
                exitFlag = solver.ExitFlag.NAN_INF_SOLUTION;
            end
        end%
    end
end
