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

        Equation = cell.empty(1, 0)
        Gradient
        Assignment
        Incidence
        InxEquations
        InxEndogenous
        InxCanBeEndogenized
        InxCanBeExogenized
        IsBlocks = true
        IsGrowth = false
        IsSingular = false

        % NanInit  Values assigned to NaN initial conditions
        NanInit = NaN
        
        Block
        AppData = struct( )

        % QuantitiesToExclude  Pointers to levels and or changes in quantities to exclude
        QuantitiesToExclude = double.empty(1, 0)

        % EquationsToExclude  Equations to exclude
        EquationsToExclude = double.empty(1, 0)

        InxZero
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
                throw(exception.Base(thisError, 'error'), quantities.Name{pos});
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
                throw(exception.Base(thisError, 'error'), quantities.Name{pos});
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
                throw( ...
                    exception.Base('Blazer:NumberEquationsEndogenized', 'error'), ...
                    numEquations, numEndogenous ...
                ); %#ok<GTARG>
            end
            [inc, idEqn, idQty] = prepareIncidenceMatrix(this);
            if this.IsBlocks
                [ordInc, ordEquation, ordQuantity] = this.reorder(inc, idEqn, idQty);
                this.IsSingular = sprank(ordInc)<min(size(ordInc));
                [blkEqn, blkQty] = this.getBlocks(ordInc, ordEquation, ordQuantity);
            else
                blkEqn = { idEqn };
                blkQty = { idQty };
            end
            
            % Create solver.block.Block objects for each block
            numBlocks = numel(blkEqn);
            this.Block = cell(1, numBlocks);
            for i = 1 : numBlocks
                blk = this.BLOCK_CONSTRUCTOR( );
                blk.PtrEquations = setdiff(blkEqn{i}, this.EquationsToExclude, 'stable'); % [^1]
                blk.PtrQuantities = blkQty{i}; % [^1]
                blk.LhsQuantityFormat = this.LHS_QUANTITY_FORMAT;
                classify(blk, this.Assignment, this.Equation); % Classify block as SOLVE or ASSIGNMENT
                setShift(blk, this); % Find max lag and lead within equations in this block
                this.Block{i} = blk;
            end
            % [^1]: Exclude equations here, but exclude quantities in
            % inside block preparation -- this is block type specific.

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
            names = quantities.Name;
            equations = this.Model.Equation.Input;
        end%




        function processFixOptions(this, opt)
            % Process Fix, FixLevel, FixChange, possible with Except
            TYPE = @int8;
            PTR = @int16;

            quantities = this.Model.Quantity;
            numQuantities = numel(quantities.Name);
            inxP = quantities.Type==TYPE(4);
            inxCanBeFixed = this.InxEndogenous;
            namesCanBeFixed = quantities.Name(inxCanBeFixed);
            list = {'Fix', 'FixLevel', 'FixChange'};
            for i = 1 : numel(list)
                fix = list{i};
                temp = opt.(fix);

                if isempty(temp)
                    opt.(fix) = double.empty(1, 0);
                    continue
                end

                if isa(temp, 'Except')
                    temp = resolve(temp, namesCanBeFixed);
                end

                if (ischar(temp) && ~isempty(temp)) ...
                   || (isa(temp, 'string') && isscalar(string) && strlength(sting)>0)
                    temp = regexp(temp, '\w+', 'match');
                    temp = cellstr(temp);
                end
                
                if isempty(temp)
                    opt.(fix) = double.empty(1, 0);
                    continue
                end

                ell = lookup( quantities, temp, ...
                              TYPE(1), TYPE(2), TYPE(4) );
                posToFix = ell.PosName;
                inxValid = ~isnan(posToFix);
                if any(~inxValid)
                    throw( exception.Base('Steady:CANNOT_FIX', 'error'), ...
                           temp{~inxValid} );
                end
                opt.(fix) = posToFix;
            end

            fixLevel = false(1, numQuantities);
            fixLevel(opt.Fix) = true;
            fixLevel(opt.FixLevel) = true;

            fixChange = false(1, numQuantities);

            % Fix steady change of all endogenized parameters to zero
            fixChange(inxP) = true;
            if opt.Growth
                fixChange(opt.Fix) = true;
                fixChange(opt.FixChange) = true;
            else
                fixChange(:) = true;
            end

            % Fix optimal policy multipliers; the level and change of
            % multipliers will be set to zero in the main loop
            if isfield(opt, 'ZeroMultipliers') && opt.ZeroMultipliers
                fixLevel = fixLevel | quantities.IxLagrange;
                fixChange = fixChange | quantities.IxLagrange;
            end

            temp = [ ]; % this.Link.LhsPtrActive
            this.QuantitiesToExclude = [this.QuantitiesToExclude, find(fixLevel), 1i*find(fixChange), temp];
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
