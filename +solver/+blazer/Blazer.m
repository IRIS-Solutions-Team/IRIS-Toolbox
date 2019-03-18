% Blazer  Sequential block analysis object
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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
        InxCanBeEndogenous
        IsBlocks = true
        IsSingular = false
        NanInit % Values assigned to NaN initial conditions
        
        Block
        AppData = struct( )
    end
    
    
    properties (Constant)
        SAVEAS_FILE_HEADER = '% IRIS Blazer File $TimeStamp$';
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
        function this = Blazer(numOfEquationsInModel)
            this.Equation = cell(1, numOfEquationsInModel);
            this.Gradient = cell(2, numOfEquationsInModel);        
        end%
        
        
        
        
        function error = endogenize(this, vecEndg)
            testFunc = @(this, pos) this.InxCanBeEndogenous(pos);
            error = swap(this, vecEndg, true, testFunc);
        end%
        
        
        
        
        function error = exogenize(this, vecExg)
            testFunc = @(this, pos) this.InxEndogenous(pos);
            error = swap(this, vecExg, false, testFunc);
        end%
        
        
        
        
        function error = swap(this, vecSwap, setIxEndgTo, testFunc)
            error = struct( 'IxCannotSwap', [ ] );
            nSwap = length(vecSwap);
            ixValid = true(1, nSwap);
            for i = 1 : nSwap
                pos = vecSwap(i);
                if ~isfinite(pos) || ~testFunc(this, pos)
                    ixValid(i) = false;
                    continue
                end
                this.InxEndogenous(pos) = setIxEndgTo;
            end
            error.IxCannotSwap = ~ixValid;
        end%
        
        
        
        
        function run(this)
            PTR = @int16;
            numOfEquations = nnz(this.InxEquations);
            numOfEndogenous = sum(this.InxEndogenous);
            if numOfEquations~=numOfEndogenous
                throw( exception.Base('Blazer:NumberEquationsEndogenized', 'error'), ...
                       numOfEquations, numOfEndogenous ); %#ok<GTARG>
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
            numOfBlocks = numel(blkEqn);
            this.Block = cell(1, numOfBlocks);
            for i = 1 : numOfBlocks
                blk = this.BLOCK_CONSTRUCTOR( );
                blk.PosQty = blkQty{i};
                blk.PosEqn = blkEqn{i};
                blk.LhsQuantityFormat = this.LHS_QUANTITY_FORMAT;
                classify(blk, this.Assignment, this.Equation); % Classify block as SOLVE or ASSIGNMENT.
                setShift(blk, this); % Find max lag and lead within equations in this block.
                this.Block{i} = blk;
            end
        end%
        
        
        function prepareBlocks(this, opt, varargin)
            numOfBlocks = numel(this.Block);
            for i = 1 : numOfBlocks
                prepareBlock(this.Block{i}, this, opt, varargin{:});
                this.Block{i}.Id = i;
            end
        end%
        
        
        function saveAs(this, fileName)
            numOfBlocks = numel(this.Block);
            c = [ strrep(solver.blazer.Blazer.SAVEAS_FILE_HEADER, '$TimeStamp$', datestr(now( ))), ...
                  sprintf('\n%% Number of Blocks: %g', numOfBlocks), ...
                  sprintf('\n%% Number of Equations: %g', sum(this.InxEquations)) ];
            names = this.Model.Quantity.Name;
            equations = this.Model.Equation.Input;
            for i = 1 : numOfBlocks
                c = [c, print(this.Block{i}, i, names, equations) ]; %#ok<AGROW>
                if i<numOfBlocks
                    c = [c, sprintf('\n\n\n')]; %#ok<AGROW>
                end
            end
            char2file(c, fileName);
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
    end
end
