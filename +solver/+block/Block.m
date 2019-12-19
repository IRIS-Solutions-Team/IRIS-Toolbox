% Block  Blazer block object
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

        % InxOfLog  Log status of all model variables
        InxOfLog

        PosQty
        PosEqn
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
        SAVEAS_INDENT = '    ';
        SAVEAS_HEADER_FORMAT = '%% Block #%g // Number of Equations: %g\n';
        SAVEAS_INSIDE_ASSIGNMENT_PREFIX = '#'
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
            this.Type = solver.block.Type.SOLVE;
            if numel(this.PosQty)>1 || numel(this.PosEqn)>1
                return
            end
            % this.PosEqn is scalar from now on.
            lhs = asgn.Lhs(this.PosEqn);
            type = asgn.Type(this.PosEqn);
            if this.PosQty==lhs && chkRhsOfAssignment(this, eqtn)
                this.Type = type;
            end
        end%
        
        
        function flag = chkRhsOfAssignment(this, eqtn)
            % Verify that the LHS quantity does not occur on the RHS of an assignment.
            c = sprintf(this.LhsQuantityFormat, this.PosQty);
            rhs = solver.block.Block.removeLhs( eqtn{this.PosEqn} );
            flag = isempty( strfind(rhs, c) );
        end%
        
        
        function prepareBlock(this, blazer, opt)
            createEquationsFunc(this, blazer);
            this.NamesInBlock = blazer.Model.Quantity.Name(this.PosQty);
            this.InxOfLog = blazer.Model.Quantity.InxOfLog;

            if this.Type==solver.block.Type.SOLVE
                createJacobPattern(this, blazer);
                try
                    this.Solver = opt.Solver;
                    if isa(opt.Solver, 'optim.options.SolverOptions') ...
                            || isa(opt.Solver, 'solver.Options')
                        this.Solver.SpecifyObjectiveGradient = ...
                            opt.PrepareGradient && opt.Solver.SpecifyObjectiveGradient;
                    end
                end
            end
        end%
        
        
        function createEquationsFunc(this, blazer)
            funcToInclude = [ blazer.Equation{this.PosEqn} ];
            this.Equations = blazer.Equation(this.PosEqn);
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


        function [gr, XX2L, DLevel, DGrowth0, DGrowthK] = createAnalyticalJacob(this, blazer, opt)
            [~, numOfQuants] = size(blazer.Incidence);
            numOfEqtnsHere = length(this.PosEqn);
            gr = blazer.Gradient(:, this.PosEqn);
            sh = this.Shift;
            nsh = length(sh);
            sh0 = find(this.Shift==0);
            aux = sub2ind([numOfQuants+1, nsh], numOfQuants+1, sh0); % Linear index to 1 in last row.
            XX2L = cell(1, numOfEqtnsHere);
            DLevel = cell(1, numOfEqtnsHere);
            DGrowth0 = cell(1, numOfEqtnsHere);
            DGrowthK = cell(1, numOfEqtnsHere);
            for i = 1 : numOfEqtnsHere
                posEqn = this.PosEqn(i);
                gr(:, i) = getGradient(this, blazer, posEqn, opt);
                vecWrt = gr{2, i};
                nWrt = length(vecWrt);
                ixOutOfSh = imag(vecWrt)<sh(1) | imag(vecWrt)>sh(end);
                XX2L{i} = ones(1, nWrt)*aux;
                ixLog = blazer.Model.Quantity.IxLog(real(vecWrt));
                vecWrt(ixOutOfSh) = NaN;
                ixLog(ixOutOfSh) = false;
                XX2L{i}(ixLog) = sub2ind( [numOfQuants+1, nsh], ...
                                          real( vecWrt(ixLog) ), ...
                                          sh0 + imag( vecWrt(ixLog) ) );
                DLevel{i} = double( bsxfun( @eq, ...
                                            this.PosQty, ...
                                            real(vecWrt).' ) );
                if nargout>3
                    DGrowth0{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).');
                    DGrowthK{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).' + this.SteadyShift);
                end
            end
        end%
        
        
        function gr = getGradient(this, blazer, posEqn, opt)
            % Fetch gradient of posEqn-th equation from Blazer object or differentiate
            % again if needed.
            vecWrtNeeded = find(blazer.Incidence, posEqn, this.PosQty);
            vecWrtMissing = setdiff(vecWrtNeeded, blazer.Gradient{2, posEqn});
            if ~opt.ForceRediff ...
                    && isa(blazer.Gradient{1, posEqn}, 'function_handle') ...
                    && isempty(vecWrtMissing)
                % vecWrtNeeded is a subset of vecWrt currently available.
                gr = blazer.Gradient(:, posEqn);
                return
            end
            % Redifferentiate this equation wrt quantities needed only.
            d = model.component.Gradient.diff(blazer.Equation{posEqn}, vecWrtNeeded);
            d = str2func([blazer.PREAMBLE, d]);
            gr = {d; vecWrtNeeded};
        end%
        
        
        function [z, exitFlag] = solve(this, fnObjective, z0, header)
            if isa(this.Solver, 'solver.Options')
                % __IRIS Solver__
                this.Solver.JacobPattern = this.JacobPattern;
                [z, ~, exitFlag] = solver.algorithm.qnsd(fnObjective, z0, this.Solver, header);

            elseif isa(this.Solver, 'optim.options.SolverOptions')
                % __Optim Tbx__
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
                % __User-Supplied Solver__
                [z, ~, exitFlag] = this.Solver(fnObjective, z0);

            else
                THIS_ERROR = { 'Block:UnknownSolver'
                               'Invalid or unknown solution method' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
        end%


        

        function c = print(this, iBlk, names, input)
            separator = string([newline( ), this.SAVEAS_INDENT]);
            if this.Type==solver.block.Type.SOLVE
                % Print SOLVE block
                keyword = "!solveFor";
                keyword = keyword + printListOfUknowns(this, names);
            else
                % Print ASSIGN block
                keyword = "!assign";
            end
            eqtn = string(input(this.PosEqn));
            c = keyword + separator + join(eqtn, separator);
            header = string(sprintf( ...
                this.SAVEAS_HEADER_FORMAT, ...
                iBlk, numel(this.PosEqn) ...
            ));
            c = char(header + c);
        end%




        function c = printListOfUknowns(this, names)
            c = "(" + join(names(this.PosQty), ",") + ")"; 
        end%


        
        
        function setShift(this, blazer)
            % Return max lag and max lead across all equations in this block.
            incid = selectEquation(blazer.Incidence, this.PosEqn);
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
            s = [1, numel(this.PosEqn)];
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
