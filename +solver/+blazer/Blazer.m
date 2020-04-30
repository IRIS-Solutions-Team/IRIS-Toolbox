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

        % IsSingular  True if there is structural singularity in the system of equations
        IsSingular = false

        % SuspectEquations  Equations suspect for causing structural singularity
        SuspectEquations = double.empty(1, 0)

        % NanInit  Values assigned to NaN initial conditions
        NanInit = NaN
        
        Blocks
        AppData = struct( )

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
        
        
        
        
        function run(this, opt)
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
                blk.PtrEquations = setdiff(blkEqn{i}, this.EquationsToExclude, 'stable'); % [^1]
                blk.PtrQuantities = blkQty{i}; % [^1]
                blk.LhsQuantityFormat = this.LHS_QUANTITY_FORMAT;
                classify(blk, this.Assignment, this.Equation); % Classify block as SOLVE or ASSIGNMENT
                setShift(blk, this); % Find max lag and lead within equations in this block
                this.Blocks{i} = blk;
            end
            % [^1]: Exclude equations here, but exclude quantities in
            % inside block preparation -- this is block type specific.

            prepareBlocks(this, opt);
        end%
        


        
        function prepareBlocks(this, varargin)
            for i = 1 : numel(this.Blocks)
                prepareBlock(this.Blocks{i}, this, varargin{:});
                this.Blocks{i}.Id = i;
            end
        end%
        


        
        function prepareForSolver(this, varargin)
            for i = 1 : numel(this.Blocks)
                prepareForSolver(this.Blocks{i}, this, varargin{:});
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




        function processFixOptions(this, opt)
            % Process Fix, FixLevel, FixChange, possible with Except
            TYPE = @int8;
            PTR = @int16;

            quantities = this.Model.Quantity;
            numQuantities = numel(quantities.Name);
            inxP = quantities.Type==TYPE(4);
            inxCanBeFixed = this.InxEndogenous;
            namesCanBeFixed = quantities.Name(inxCanBeFixed);
            list = ["Fix", "FixLevel", "FixChange"];
            for fixOption = list
                temp = opt.(fixOption);

                if isempty(temp)
                    opt.(fixOption) = double.empty(1, 0);
                    continue
                end

                if isa(temp, 'Except')
                    temp = resolve(temp, namesCanBeFixed);
                end

                if ischar(temp) || (isstring(temp) && isscalar(string))
                    temp = regexp(temp, '\w+', 'match');
                    if isempty(temp)
                        opt.(fixOption) = double.empty(1, 0);
                        continue
                    end
                    temp = cellstr(temp);
                elseif isstring(temp)
                    temp = cellstr(temp);
                end
                
                if isempty(temp)
                    opt.(fixOption) = double.empty(1, 0);
                    continue
                end

                ell = lookup(quantities, temp, TYPE(1), TYPE(2), TYPE(4));
                posToFix = ell.PosName;
                inxValid = ~isnan(posToFix);
                if any(~inxValid)
                    throw( ...
                        exception.Base('Steady:CANNOT_FIX', 'error') ...
                        , temp{~inxValid} ...
                    );
                end
                opt.(fixOption) = posToFix;
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
                currBlkEqn(end+1) = idEqn(i); %#ok<AGROW>
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
            isSingular = sprank(ordInc)<min(size(ordInc));
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
