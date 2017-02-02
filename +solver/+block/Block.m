% Block  Blazer block object.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Block < handle
    properties
        Type
        Solver
        RetGradient = false % Return gradient from objective function.
        
        PosQty
        PosEqn
        FnEval
        FnGradient
        QtyStrFormat % Format to create string representing an LHS variable to verify the RHS of possible assignments.
        
        Shift = zeros(1, 0)
        Gradient = cell(2, 0)
        
        XX2L
        D
        
        Lower
        Upper
        
        RunTime = struct( )
    end
    
    
    
    
    properties (Constant)
        SAVEAS_INDENT = '    ';
        SAVEAS_HEADER_FORMAT = '%% Block #%g // Number of Equations: %g // Number of Endogenous Quantities: %g\n';
        SAVEAS_INSIDE_ASSIGNMENT_PREFIX = '#'
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
        end
        
        
        
        
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
        end
        
        
        
        
        function flag = chkRhsOfAssignment(this, eqtn)
            % Verify that the LHS quantity does not occur on the RHS of an assignment.
            c = sprintf(this.QtyStrFormat, this.PosQty);
            rhs = solver.block.Block.removeLhs( eqtn{this.PosEqn} );
            flag = isempty( strfind(rhs, c) );
        end
        
        
        
        
        function prepareBlock(blk, blz, opt)
            % Prepare function handle to system of equations.
            createFnEval(blk, blz);
            
            % Create gradient functions in subclasses.
            
            % Set solver options.
            if blk.Type==solver.block.Type.SOLVE
                blk.Solver = opt.Solver;
                if isa(opt.Solver, 'optim.options.SolverOptions')
                    if opt.AlmostLinear
                        blk.Solver.InitDamping = 0;
                    end
                end
                if isa(opt.Solver, 'optim.options.SolverOptions') ...
                        || isa(opt.Solver, 'solver.Options')
                    blk.Solver.SpecifyObjectiveGradient = ...
                        opt.Gradient && opt.Solver.SpecifyObjectiveGradient;
                end
            end
        end
        
        
        
        
        function createFnEval(this, blz)
            preamble = blz.Preamble;
            eqtn = blz.Equation;
            pos = this.PosEqn;
            body = [ eqtn{pos} ];
            if this.Type==solver.block.Type.SOLVE
                % Solve-for blocks.
                if numel(pos)>1
                    body = [ '[', body, ']' ];
                end
            else
                % Assignment blocks.
                body = this.removeLhs(body);
            end
            this.FnEval = str2func([preamble, body]);
        end
        
        
        
        
        function [gr, XX2L, DLevel, DGrowth0, DGrowthK] = createFnGradient(this, blz, opt)
            [~, nQuan] = size(blz.Incidence);
            nEqtnHere = length(this.PosEqn);
            gr = blz.Gradient(:, this.PosEqn);
            sh = this.Shift;
            nsh = length(sh);
            t0 = find(this.Shift==0);
            aux = sub2ind([nQuan+1, nsh], nQuan+1, t0); % Linear index to 1 in last row.
            XX2L = cell(1, nEqtnHere);
            DLevel = cell(1, nEqtnHere);
            DGrowth0 = cell(1, nEqtnHere);
            DGrowthK = cell(1, nEqtnHere);
            for i = 1 : nEqtnHere
                posEqn = this.PosEqn(i);
                gr(:, i) = getGradient(this, blz, posEqn, opt);
                vecWrt = gr{2, i};
                nWrt = length(vecWrt);
                ixOutOfSh = imag(vecWrt)<sh(1) | imag(vecWrt)>sh(end);
                XX2L{i} = ones(1, nWrt)*aux;
                ixLog = blz.IxLog(real(vecWrt));
                vecWrt(ixOutOfSh) = NaN;
                ixLog(ixOutOfSh) = false;
                XX2L{i}(ixLog) = sub2ind( ...
                    [nQuan+1, nsh], ...
                    real( vecWrt(ixLog) ), ...
                    t0+imag( vecWrt(ixLog) ) ...
                    );
                DLevel{i} = double( bsxfun( ...
                    @eq, ...
                    this.PosQty, ...
                    real(vecWrt).' ...
                    ) );
                if nargout>3
                    DGrowth0{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).');
                    DGrowthK{i} = bsxfun(@times, DLevel{i}, imag(vecWrt).' + this.STEADY_SHIFT);
                end
            end
        end
        
        
        
        
        
        function gr = getGradient(this, blz, posEqn, opt)
            % Fetch gradient of posEqn-th equation from Blazer object or differentiate
            % again if needed.
            vecWrtNeeded = find(blz.Incidence, posEqn, this.PosQty);
            vecWrtMissing = setdiff(vecWrtNeeded, blz.Gradient{2, posEqn});
            if ~opt.ForceRediff ...
                    && isa(blz.Gradient{1, posEqn}, 'function_handle') ...
                    && isempty(vecWrtMissing)
                % vecWrtNeeded is a subset of vecWrt currently available.
                gr = blz.Gradient(:, posEqn);
                return
            end
            % Redifferentiate this equation wrt quantities needed only.
            d = model.Gradient.diff(blz.Equation{posEqn}, vecWrtNeeded);
            d = str2func([blz.Preamble, d]);
            gr = {d; vecWrtNeeded};
        end
        
        
        
        
        function [z, exitFlag] = solve(this, fnObjective, z0)
            if isa(this.Solver, 'optim.options.SolverOptions') ...
                    || isa(this.Solver, 'solver.Options')
                
                % this.Solver = optimoptions(this.Solver, 'CheckGradients', true);
                % this.Solver = optimoptions(this.Solver, 'FiniteDifferenceType', 'central');
                if strcmpi(this.Solver.SolverName, 'IRIS')
                    [z, exitFlag] = solver.algorithm.lm(fnObjective, z0, this.Solver);
                    
                elseif strcmpi(this.Solver.SolverName, 'lsqnonlin')
                    [z, ~, ~, exitFlag] = ...
                        lsqnonlin(fnObjective, z0, this.Lower, this.Upper, this.Solver);
                    if exitFlag==-3
                        exitFlag = 1;
                    end
                    
                elseif strcmpi(this.Solver.SolverName, 'fsolve')
                    [z, ~, exitFlag] = fsolve(fnObjective, z0, this.Solver);
                    if exitFlag==-3
                        exitFlag = 1;
                    end
                end
                
                z = real(z);
                z( abs(z)<=this.Solver.StepTolerance ) = 0;
            elseif isa(this.Solver, 'function_handle')
                [z, exitFlag] = this.Solver(@objective, z0);
            end
        end
        
        
        
        
        function c = print(this, iBlk, name, input)
            INDENT = solver.block.Block.SAVEAS_INDENT;
            % START_INSIDE_ASSIGN = solver.block.Block.SAVEAS_START_INSIDE_ASSIGN;
            % END_INSIDE_ASSIGN = solver.block.Block.SAVEAS_END_INSIDE_ASSIGN;
            HEADER_FORMAT = solver.block.Block.SAVEAS_HEADER_FORMAT;
            key = this.Type.SaveAsKeyword;
            if this.Type==solver.block.Type.SOLVE
                % Solve-for blocks.
                strEqtn = '';
                strSolveFor = '';
                strSolveFor = [ strSolveFor, sprintf('%s, ', name{ this.PosQty }) ];
                strSolveFor = strSolveFor(1:end-2);
                strSolveFor = [key, '(', strSolveFor, ')'];
                eqtn = input(this.PosEqn);
                strEqtn = [strEqtn, sprintf(['\n', INDENT, '%s'], eqtn{:})];
                c = [strSolveFor, strEqtn];
            else
                % Assignment blocks.
                lhsName = name{ this.PosQty };
                eqtn = input{ this.PosEqn };
                c = sprintf('%s(%s)\n%s%s', key, lhsName, INDENT, eqtn);
            end
            header = sprintf(HEADER_FORMAT, iBlk, numel(this.PosEqn), numel(this.PosQty));
            c = [header, c];
        end
        
        
        
        
        function setShift(this, blz)
            % Return max lag and max lead across all equations in this block.
            incid = selectEquation(blz.Incidence, this.PosEqn);
            t0 = zero(blz.Incidence);
            ixIncid = across(incid, 'Equation');
            ixIncid = any(ixIncid, 1);
            from = find(ixIncid, 1, 'first') - t0;
            to = find(ixIncid, 1, 'last') - t0;
            if from>=this.MAX_FROM_SHIFT
                from = this.MAX_FROM_SHIFT;
            end
            if to<=this.MIN_TO_SHIFT
                to = this.MIN_TO_SHIFT;
            end
            this.Shift = from : to;
        end
        
        
        
        
        function s = size(this)
            s = [1, numel(this.PosEqn)];
        end
    end
    
    
    
    
    methods (Static)
        function eqtn = removeLhs(eqtn)
            close = textfun.matchbrk(eqtn, 2);
            eqtn = eqtn(close+1:end);
            if eqtn(1)=='+'
                eqtn(1) = '';
            end
        end
    end
end
