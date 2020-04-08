% Blazer  Sequential block analysis object
%
% Backend IRIS class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef (Abstract) Blazer < handle
    properties
        Model = struct( 'Quantity', model.component.Quantity.empty(0), ...
                        'Equation', model.component.Equation.empty(0) )

        Equation = cell.empty(1, 0)
        Gradient
        Assignment
        Incidence
        InxEquations
        InxEndogenous
        InxCanBeEndogenized
        InxCanBeExogenized
        IsBlocks = true
        IsSingular = false

        % NanInit  Values assigned to NaN initial conditions
        NanInit = NaN
        
        Block
        AppData = struct( )
    end
    
    
    properties (Constant)
        SAVEAS_FILE_HEADER = '%%%% [IrisToolbox] Blazer File %s\n%% Number of Blocks: %g\n%% Number of Equations: %g';
    end
    

    properties (Abstract, Constant)
        BLOCK_CONSTRUCTOR 
        LHS_QUANTITY_FORMAT % Format to create string representing an LHS variable to verify the RHS of possible assignments.
        PREAMBLE
    end
    

    methods (Abstract)
        varargout = prepareIncidenceMatrix(varargin)
    end


    methods
        function this = Blazer(numEquationsInModel)
            this.Equation = cell(1, numEquationsInModel);
            this.Gradient = cell(2, numEquationsInModel);        
        end%
        
        
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
                if ~isfinite(pos) || ~testFunc(this, pos)
                    inxValid(i) = false;
                    continue
                end
                this.InxEndogenous(pos) = setIxEndgTo;
            end
        end%
        
        
        
        
        function run(this, varargin)
            PTR = @int16;
            numEquations = nnz(this.InxEquations);
            numEndogenous = nnz(this.InxEndogenous);
            if numEquations~=numEndogenous
                throw( exception.Base('Blazer:NumberEquationsEndogenized', 'error'), ...
                       numEquations, numEndogenous ); %#ok<GTARG>
            end
            [inc, idEqn, idQty] = prepareIncidenceMatrix(this);
            if this.IsBlocks
                [ordInc, ordPosEqn, ordPosQty] = this.reorder(inc, idEqn, idQty);
                this.IsSingular = sprank(ordInc)<min(size(ordInc));
                [blkEqn, blkQty] = this.getBlocks(ordInc, ordPosEqn, ordPosQty);
            else
                blkEqn = { idEqn };
                blkQty = { idQty };
            end
            
            % Create solver.block.Block objects for each block
            numBlocks = numel(blkEqn);
            this.Block = cell(1, numBlocks);
            for i = 1 : numBlocks
                blk = this.BLOCK_CONSTRUCTOR( );
                blk.PosQty = blkQty{i};
                blk.PosEqn = blkEqn{i};
                blk.LhsQuantityFormat = this.LHS_QUANTITY_FORMAT;
                classify(blk, this.Assignment, this.Equation); % Classify block as SOLVE or ASSIGNMENT.
                setShift(blk, this); % Find max lag and lead within equations in this block.
                this.Block{i} = blk;
            end

            if isempty(varargin)
                return
            end
            prepareBlocks(this, varargin{:});
        end%
        


        
        function prepareBlocks(this, varargin)
            numBlocks = numel(this.Block);
            for i = 1 : numBlocks
                prepareBlock(this.Block{i}, this, varargin{:});
                this.Block{i}.Id = i;
            end
        end%
        
        


        function saveAs(this, fileName)
            numBlocks = numel(this.Block);
            numEquations = nnz(this.InxEquations);
            c = '';
            [names, equations] = getNamesAndEquationsToPrint(this);
            for i = 1 : numBlocks
                c = [c, newline( ), newline( ), newline( )]; %#ok<AGROW>
                c = [c, char(print(this.Block{i}, i, names, equations)) ]; %#ok<AGROW>
            end
            solver.blazer.Blazer.wrapAndSave(c, fileName, numBlocks, numEquations);
        end%        


        function [names, equations] = getNamesAndEquationsToPrint(this)
            names = this.Model.Quantity.Name;
            equations = this.Model.Equation.Input;
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
        
        
        function [blkEqn, blkQty] = getBlocks(ordInc, idEqn, idQty)
            PTR = @int16;
            n = size(ordInc, 1);
            blkEqn = cell(1, 0);
            blkQty = cell(1, 0);
            currBlkEqn = repmat(PTR(0), 1, 0);
            currBlkQty = repmat(PTR(0), 1, 0);
            for i = n : -1 : 1
                currBlkQty(end+1) = idQty(i); %#ok<AGROW>
                currBlkEqn(end+1) = idEqn(i); %#ok<AGROW>
                if ~any( any( ordInc(i:end, 1:i-1) ) )
                    blkQty{end+1} = fliplr(currBlkQty); %#ok<AGROW>
                    blkEqn{end+1} = fliplr(currBlkEqn); %#ok<AGROW>
                    currBlkQty = repmat(PTR(0), 1, 0);
                    currBlkEqn = repmat(PTR(0), 1, 0);
                end
            end
        end%


        function c = wrapAndSave(c, fileName, numBlocks, numEquations)
            header = sprintf( ...
                solver.blazer.Blazer.SAVEAS_FILE_HEADER, ...
                datestr(now( )), numBlocks, numEquations ...
            );
            char2file([char(header), char(c), newline( ), newline( )], fileName);
        end%
    end
end
