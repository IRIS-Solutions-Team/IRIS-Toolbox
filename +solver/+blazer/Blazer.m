% Blazer  Sequential block analysis object.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Blazer < handle
    properties
        BlockConstructor
        
        Equation
        Gradient
        Assignment
        Preamble
        Incidence
        IxLog
        IxEqn
        IxEndg
        IxCanBeEndg
        IsBlocks = true
        IsSingular = false
        IsReduction = false
        QtyStrFormat % Format to create string representing an LHS variable to verify the RHS of possible assignments.
        NanInit % Values assigned to NaN initial conditions.
        
        Block
        AppData = struct( )
    end
    
    
    
    
    properties (Constant)
        SAVEAS_FILE_HEADER = '% IRIS Blazer File $TimeStamp$';
    end
    
    
    
    
    methods
        function this = Blazer(nEqn)
            this.Equation = cell(1, nEqn);
            this.Gradient = cell(2, nEqn);        
        end
        
        
        
        
        function error = endogenize(this, vecEndg)
            testFunc = @(this, pos) this.IxCanBeEndg(pos);
            error = swap(this, vecEndg, true, testFunc);
        end
        
        
        
        
        function error = exogenize(this, vecExg)
            testFunc = @(this, pos) this.IxEndg(pos);
            error = swap(this, vecExg, false, testFunc);
        end
        
        
        
        
        function error = swap(this, vecSwap, setIxEndgTo, testFunc)
            error = struct( ...
                'IxCannotSwap', [ ] ...
                );
            nSwap = length(vecSwap);
            ixValid = true(1, nSwap);
            for i = 1 : nSwap
                pos = vecSwap(i);
                if ~isfinite(pos) || ~testFunc(this, pos)
                    ixValid(i) = false;
                    continue
                end
                this.IxEndg(pos) = setIxEndgTo;
            end
            error.IxCannotSwap = ~ixValid;
        end
        
        
        
        
        function run(this)
            PTR = @int16;
            nEqn = sum(this.IxEqn);
            nEndg = sum(this.IxEndg);
            if nEqn~=nEndg
                throw( exception.Base('Blazer:NumberEquationsEndogenized', 'error'), ...
                    nEqn, nEndg ); %#ok<GTARG>
            end
            posEqn = PTR(find(this.IxEqn)); %#ok<FNDSB>
            posQty = PTR(find(this.IxEndg)); %#ok<FNDSB>
            ixIncid = across(this.Incidence, 'Shift');
            if this.IsBlocks
                [ordInc, ordPosEqn, ordPosQty] = ...
                    solver.blazer.Blazer.reorder( ...
                    ixIncid(this.IxEqn, this.IxEndg), ...
                    posEqn, posQty ...
                    );
                this.IsSingular = sprank(ordInc)<min(size(ordInc));
                [blkEqn, blkQty] = ...
                    solver.blazer.Blazer.getBlocks(ordInc, ordPosEqn, ordPosQty);
            else
                blkEqn = { posEqn };
                blkQty = { posQty };
            end
            
            % Create solver.block.Block objects for each block.
            nBlk = numel(blkEqn);
            this.Block = cell(1, nBlk);
            for i = 1 : nBlk
                blk = this.BlockConstructor( );
                blk.PosQty = blkQty{i};
                blk.PosEqn = blkEqn{i};
                blk.QtyStrFormat = this.QtyStrFormat;
                classify(blk, this.Assignment, this.Equation); % Classify block as SOLVE or ASSIGNMENT.
                setShift(blk, this); % Find max lag and lead within equations in this block.
                this.Block{i} = blk;
            end
        end
        
        
        
        function prepareBlocks(this, opt)
            nBlk = numel(this.Block);
            for i = 1 : nBlk
                prepareBlock(this.Block{i}, this, opt);
            end
        end
        
        
        
        
        function exclude(this, posExclude)
            nBlk = numel(this.Block);
            for i = 1 : nBlk
                exclude(this.Block{i}, posExclude);
            end
        end
        
        
        
        
       function saveAs(this, m, fileName)
            BR = sprintf('\n');
            nBlk = numel(this.Block);
            c = [ ...
                strrep(solver.blazer.Blazer.SAVEAS_FILE_HEADER, '$TimeStamp$', datestr(now( ))), ...
                sprintf('\n%% Number of Blocks: %g', nBlk), ...
                sprintf('\n%% Number of Equations: %g', sum(this.IxEqn)), ...
                sprintf('\n%% Number of Endogenous Quantities: %g\n\n\n', sum(this.IxEndg)), ...
                ];
            for i = 1 : nBlk
                c = [c, print(this.Block{i}, i, m.Quantity.Name, m.Equation.Input) ]; %#ok<AGROW>
                if i<nBlk
                    c = [c, BR, BR, BR]; %#ok<AGROW>
                end
            end
            char2file(c, fileName);
        end        
    end
    
    
    
    
    methods (Static)
        function [inc, posEqn, posQty] = reorder(inc, posEqn, posQty)
            if isempty(inc)
                return
            end
            
            c1 = colamd(inc);
            inc = inc(:, c1);
            posQty = posQty(c1);
            
            r1 = colamd(inc.');
            inc = inc(r1, :);
            posEqn = posEqn(r1);
            
            [r2, c2] = dmperm(inc);
            inc = inc(r2, c2);
            posQty = posQty(c2);
            posEqn = posEqn(r2);
        end
        
        
        
        
        function [blkEqn, blkQty] = getBlocks(incid, posEqn, posQty)
            PTR = @int16;
            n = size(incid, 1);
            blkEqn = cell(1, 0);
            blkQty = cell(1, 0);
            currBlkEqn = repmat(PTR(0), 1, 0);
            currBlkQty = repmat(PTR(0), 1, 0);
            for i = n : -1 : 1
                currBlkQty(end+1) = posQty(i); %#ok<AGROW>
                currBlkEqn(end+1) = posEqn(i); %#ok<AGROW>
                if ~any( any( incid(i:end, 1:i-1) ) )
                    blkQty{end+1} = fliplr(currBlkQty); %#ok<AGROW>
                    blkEqn{end+1} = fliplr(currBlkEqn); %#ok<AGROW>
                    currBlkQty = repmat(PTR(0), 1, 0);
                    currBlkEqn = repmat(PTR(0), 1, 0);
                end
            end
        end
    end
end
