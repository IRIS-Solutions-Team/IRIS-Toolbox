% Blazer  Sequential block analysis object
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef (Abstract) Blazer ...
    < handle

    properties
        % Model  Model components copied over to Blazer object
        Model = struct( ...
            'Quantity', model.component.Quantity.empty(0), ...
            'Equation', model.component.Equation.empty(0) ...
        )

        Equations (1, :) cell = cell.empty(1, 0)
        Gradients (3, :) cell = cell.empty(3, 0)
        Assignments

        Incidence
        InxEquations
        InxEndogenous
        InxCanBeEndogenized
        InxCanBeExogenized
        IsBlocks = true
        IsGrowth = false

        % IsSingular  True if there is structural singularity in the system of equations
        IsSingular = false

        % SuspectEquations  Equations suspect for causing structural singularity
        SuspectEquations = double.empty(1, 0)

        % NanInit  Values assigned to NaN initial conditions
        NanInit = NaN
        
        % Blocks  Cell of solution or assignment blocks
        Blocks (1, :) cell = cell.empty(1, 0)

        % QuantitiesToExclude  Pointers to levels and or changes in quantities to exclude
        QuantitiesToExclude = double.empty(1, 0)

        % EquationsToExclude  Equations to exclude
        EquationsToExclude = double.empty(1, 0)

        InxZero
        SuccessOnly = false
    end
    

    properties (Constant)
        SAVEAS_FILE_HEADER_FORMAT = '%%%% [IrisToolbox] Blazer File %s\n%% Number of Blocks: %g\n%% Number of Equations: %g';
    end
    

    properties (Abstract, Constant)
        BLOCK_CONSTRUCTOR 
        LHS_QUANTITY_FORMAT % Format to create string representing an LHS variable to verify the RHS of possible assignments.
        TYPES_ALLOWED_CHANGE_LOG_STATUS
    end
    

    methods (Abstract)
        varargout = prepareIncidenceMatrix(varargin)
    end


    methods % Constructor
        function this = Blazer(numEquationsInModel)
            this.Equations = cell(1, numEquationsInModel);
            this.Gradients = cell(3, numEquationsInModel);        
        end%
    end


    methods
        function endogenize(this, posToEndogenize)
            testFunc = @(this, pos) this.InxCanBeEndogenized(pos);
            inxValid = swap(this, posToEndogenize, true, testFunc);
            if any(~inxValid)
                thisError = [
                    "Blazer:CannotEndogenize"
                    "This name cannot be endogenized because it is endogenous already: %s"
                ];
                pos = posToEndogenize(~inxValid);
                throw(exception.Base(thisError, 'error'), this.Model.Quantity.Name{pos});
            end
        end%

        
        function exogenize(this, posToExogenize)
            testFunc = @(this, pos) this.InxCanBeExogenized(pos);
            inxValid = swap(this, posToExogenize, false, testFunc);
            if any(~inxValid)
                thisError = [
                    "Blazer:CannotExogenize"
                    "This name cannot be exogenized because it is exogenous already: %s"
                ];
                pos = posToExogenize(~inxValid);
                throw(exception.Base(thisError, 'error'), this.Model.Quantity.Name{pos});
            end
        end%
        

        function inxValid = swap(this, vecSwap, setIxEndgTo, testFunc) 
            numSwaps = numel(vecSwap);
            inxValid = true(1, numSwaps);
            for i = 1 : numSwaps
                pos = vecSwap(i);
                if isnan(pos) || isinf(pos) || ~testFunc(this, pos)
                    inxValid(i) = false;
                    continue
                end
                this.InxEndogenous(pos) = setIxEndgTo;
            end
        end%
        
        
        function run(this, varargin)
            [inc, idEqn, idQty] = prepareIncidenceMatrix(this, varargin{:});
            [numEquations, numEndogenous] = size(inc);
            if numEquations~=numEndogenous
                exception.error([
                    "Blazer:InvalidNumberEquationsOrUnknowns"
                    "The number of endogenized names (%g) does not match the number of equations (%g). "
                ], numEndogenous, numEquations);
            end
            if this.IsBlocks
                [ordInc, ordEquation, ordQuantity] = this.reorder(inc, idEqn, idQty);
                [blkEqn, blkQty, blkInc] = this.getBlocks(ordInc, ordEquation, ordQuantity);
                [this.IsSingular, this.SuspectEquations] = ...
                    this.investigateSingularity(ordInc, blkInc, blkEqn);
            else
                blkEqn = { idEqn };
                blkQty = { idQty };
            end
            
            
            % Create solver.block.Block objects for each block
            numBlocks = numel(blkEqn);
            this.Blocks = cell(1, numBlocks);
            for i = 1 : numBlocks
                blk = this.BLOCK_CONSTRUCTOR( );
                blk.Id = i;
                blk.PtrEquations = reshape(setdiff(blkEqn{i}, this.EquationsToExclude, 'stable'), 1, [ ]); % [^1]
                blk.PtrQuantities = reshape(blkQty{i}, 1, [ ]); % [^1]
                blk.LhsQuantityFormat = this.LHS_QUANTITY_FORMAT;

                prepareBlock(blk, this);

                this.Blocks{i} = blk;
            end
            % [^1]: Exclude equations here, but exclude quantities in
            % inside block preparation -- this is block type specific.
        end%

        
        function prepareForSolver(this, solverOptions, varargin)
            for i = 1 : numel(this.Blocks)
                prepareForSolver(this.Blocks{i}, solverOptions, varargin{:});
            end
        end%


        function saveAs(this, fileName)
            numBlocks = numel(this.Blocks);
            numEquations = nnz(this.InxEquations);
            s = "";
            [names, equations] = getNamesAndEquationsToPrint(this);
            for i = 1 : numBlocks
                s = s + sprintf("\n\n\n");
                s = s + print(this.Blocks{i}, i, names, equations); %#ok<AGROW>
            end
            solver.blazer.Blazer.wrapAndSave(s, fileName, numBlocks, numEquations);
        end%        


        function [names, equations] = getNamesAndEquationsToPrint(this)
            names = this.Model.Quantity.Name;
            equations = this.Model.Equation.Input;
        end%


        function this = processLogOptions(this, opt)
            if isfield(opt, "Log") && ~isempty(opt.Log)
                this.Model.Quantity = changeLogStatus( ...
                    this.Model.Quantity, true, opt.Log, this.TYPES_ALLOWED_CHANGE_LOG_STATUS{:} ...
                );
            end
            if isfield(opt, "Unlog") && ~isempty(opt.Unlog)
                this.Model.Quantity = changeLogStatus( ...
                    this.Model.Quantity, false, opt.Unlog, this.TYPES_ALLOWED_CHANGE_LOG_STATUS{:} ...
                );
            end
        end%
    end


    methods (Static)
        function [inc, idEqn, idQty] = reorder(inc, idEqn, idQty)
            if isempty(inc)
                return
            end
            if nargin<2 || isempty(idEqn)
                idEqn = 1 : size(inc, 1);
            end
            if nargin<3 || isempty(idQty)
                idQty = 1 : size(inc, 2);
            end
            
            c1 = colamd(inc);
            inc = inc(:, c1);
            idQty = idQty(c1);
            
            r1 = colamd(inc.');
            inc = inc(r1, :);
            idEqn = idEqn(r1);
            
            [r2, c2] = dmperm(inc);
            inc = inc(r2, c2);
            idQty = idQty(c2);
            idEqn = idEqn(r2);
        end%
        

        function [blkEqn, blkQty, blkInc] = getBlocks(ordInc, idEqn, idQty)
            PTR = @int16;
            n = size(ordInc, 1);
            blkEqn = cell(1, 0);
            blkQty = cell(1, 0);
            blkInc = cell(1, 0);
            currBlkEqn = repmat(PTR(0), 1, 0);
            currBlkQty = repmat(PTR(0), 1, 0);
            previous = n+1;
            for i = n : -1 : 1
                currBlkQty(end+1) = idQty(i); %#ok<AGROW>

                if real(idEqn(i))>0 % [^1]
                    currBlkEqn(end+1) = idEqn(i); %#ok<AGROW>
                end
                % [^1]: Equations with negative pointers are dummy
                % equations to be removed immediately

                if ~any( any( ordInc(i:end, 1:i-1) ) )
                    blkQty{end+1} = fliplr(currBlkQty); %#ok<AGROW>
                    blkEqn{end+1} = fliplr(currBlkEqn); %#ok<AGROW>
                    blkInc{end+1} = ordInc(i:previous-1, i:previous-1);
                    previous = i;
                    currBlkQty = repmat(PTR(0), 1, 0);
                    currBlkEqn = repmat(PTR(0), 1, 0);
                end
            end
        end%


        function [isSingular, suspectEquations] = investigateSingularity(ordInc, blkInc, blkEqn)
            isSingular = sprank(ordInc) < min(size(ordInc));
            suspectEquations = double.empty(1, 0);
            if isSingular
                for i = 1 : numel(blkInc)
                    if sprank(blkInc{i})<min(size(blkInc{i}))
                        suspectEquations = blkEqn{i};
                        break
                    end
                end
            end
        end%


        function c = wrapAndSave(s, fileName, numBlocks, numEquations)
            header = sprintf( ...
                solver.blazer.Blazer.SAVEAS_FILE_HEADER_FORMAT, ...
                datestr(now( )), numBlocks, numEquations ...
            );
            char2file([char(header), char(s), newline( ), newline( )], fileName);
        end%
    end
end

