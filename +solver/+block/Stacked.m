classdef Stacked < solver.block.Block
    properties
        % InxOfEndogenousPoints  Index of endogenous points to be solved
        InxOfEndogenousPoints = logical.empty(0)

        % Terminal  Rectangular simulation object for first-order terminal condition
        Terminal = simulate.Rectangular.empty(0)

        % MaxLab  Max lag of each quantity in this block
        MaxLag = double.empty(1, 0)    

        % MaxLead  Max lead of each quantity in this block
        MaxLead = double.empty(1, 0)   

        % FirstTime  First time (1..numColumnsToRun) to evaluate equations in for ith unknown (1..numQuantitiesInBlock*numColumnsToRun)
        FirstTime = double.empty(1, 0) 

        % LastTime  Last time (1..numColumnsToRun) to evaluate equations in for ith unknown (1..numQuantitiesInBlock*numColumnsToRun)
        LastTime = double.empty(1, 0)  

        % NumOfActiveEquations  Number of active equations
        NumOfActiveEquations
    end


    properties (Constant)
        VECTORIZE = true
    end


    methods
        function this = Stacked(varargin)
            this = this@solver.block.Block(varargin{:});
        end%
        
        


        function [exitFlag, error] = run(this, data, exitFlagHeader)

            exitFlag = solver.ExitFlag.IN_PROGRESS;
            error = struct( );
            error.EvaluatesToNan = [ ];
            
            if isempty(this.PtrQuantities)
                exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
                return
            end
            numQuantitiesInBlock = numel(this.PtrQuantities);
            numEquationsInBlock = numel(this.PtrEquations);
            firstColumnToRun = data.FirstColumnOfFrame;
            lastColumnToRun = data.LastColumnOfFrame;
            columnsToRun = firstColumnToRun : lastColumnToRun;
            numColumnsToRun = numel(columnsToRun);

            if this.Type==solver.block.Type.SOLVE
                % __Solve__
                % Index of endogenous points in data
                inxZ = this.InxOfEndogenousPoints;
                %{
                linx = sub2ind( size(data.YXEPG), ...
                                repmat(this.PtrQuantities(:), 1, numColumnsToRun), ...
                                repmat(columnsToRun, numQuantitiesInBlock, 1) );
                linx = linx(:);
                %}

                % Create index of logs within the z vector
                temp = repmat(this.InxLog(:), 1, size(data.YXEPG, 2));
                inxLogZ = temp(inxZ);
                %{
                linxLog = this.InxLog(this.PtrQuantities);
                linxLog = repmat(linxLog(:), numColumnsToRun, 1);
                %}

                maxMaxLead = max(this.MaxLead);
                needsRunFotc = this.Type==solver.block.Type.SOLVE ...
                            && ~isempty(maxMaxLead) ...
                            && maxMaxLead>0 ...
                            && ~isempty(this.Terminal);

                % Initialize endogenous quantities
                z0 = data.YXEPG(inxZ);
                inxNaN = ~isfinite(z0);
                if any(inxNaN)
                    % Try to replace NaNs with previous period data
                    % TODO streamline this
                    numRows = size(data.YXEPG, 1);
                    inxNaNZ = ~isfinite(data.YXEPG) & inxZ;
                    shift = 1;
                    while any(inxNaNZ(:))
                        inxPrevious = [inxNaNZ(:, 1+shift:end), false(numRows, shift)];
                        if nnz(inxNaNZ)~=nnz(inxPrevious)
                            break
                        end
                        data.YXEPG(inxNaNZ) = data.YXEPG(inxPrevious);
                        inxNaNZ = ~isfinite(data.YXEPG) & inxZ;
                        shift = shift + 1;
                    end
                    z0 = data.YXEPG(inxZ);
                    inxNaN = ~isfinite(z0);
                    z0(inxNaN) = 1;
                end
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                anyLog = any(inxLogZ);
                if anyLog
                    z0(inxLogZ) = log( z0(inxLogZ) );
                end
                %* Make sure init conditions are within bounds.
                %* Empty bounds if all are Inf.
                %* Bounds are in logs for log variables.
                % checkBoundsOnInitCond( );
                % Test all equations in this block for NaNs and Infs.
                hereCheckEquationsForCorrupt( );
                if exitFlag~=solver.ExitFlag.IN_PROGRESS
                    return
                end
                [z, exitFlag] = solve(this, @objective, z0, exitFlagHeader);
                hereWriteEndogenousToData(z);
            else
                % __Assign__
                [z, exitFlag] = assign(this, data, exitFlagHeader);
            end

            exitFlag = this.checkFiniteSolution(z, exitFlag);

            return
            
                
                function y = objective(z, ithJacob)
                    if nargin<2
                        ithJacob = [ ];
                    end
                    hereWriteEndogenousToData(z);
                    
                    if needsRunFotc
                        % First-order terminal condition
                        flat(this.Terminal, data);
                    end

                    if isempty(ithJacob)
                        y = this.EquationsFunc(data.YXEPG, columnsToRun, data.BarYX);
                        y = y(:);
                    else
                        firstColumnJacob = firstColumnToRun + this.FirstTime(ithJacob) - 1;
                        lastColumnJacob = firstColumnToRun + this.LastTime(ithJacob) - 1;
                        y = [ ];
                        for column = firstColumnJacob : lastColumnJacob
                            y = [y; this.NumericalJacobFunc{ithJacob}(data.YXEPG, column, data.BarYX)];
                        end
                    end
                end%


                function hereWriteEndogenousToData(z)
                    z = real(z);
                    if anyLog
                        z(inxLogZ) = exp(z(inxLogZ));
                    end
                    data.YXEPG(inxZ) = z;
                end%


                function hereCheckEquationsForCorrupt( )
                    checkObjective = objective(z0);
                    checkObjective = reshape(checkObjective, numEquationsInBlock, numColumnsToRun);
                    inxValidData = isfinite(checkObjective);
                    if all(inxValidData(:))
                        return
                    end
                    inxInvalidEquationsInBlock = any(~inxValidData, 2);
                    error.EvaluatesToNan = this.PtrEquations(inxInvalidEquationsInBlock);
                    exitFlag = solver.ExitFlag.NAN_INF_PREEVAL;
                end%
        end%


        

        function [z, exitFlag] = assign(this, data, exitFlagHeader)
            columnsToRun = data.FirstColumnOfFrame : data.LastColumnOfFrame;
            numColumnsToRun = numel(columnsToRun);
            
            posOfZ = find(this.InxOfEndogenousPoints);
            %{
            linx = sub2ind( size(data.YXEPG), ...
                            repmat(this.PtrQuantities, 1, numColumnsToRun), ...
                            columnsToRun );
            linx = linx(:);
            %}

            isInvTransform = ~isempty(this.Type.InvTransform);
            z = nan(1, numColumnsToRun);
            for i = 1 : numColumnsToRun
                z(i) = this.EquationsFunc(data.YXEPG, columnsToRun(i), data.BarYX);
                if isInvTransform
                    z(i) = this.Type.InvTransform(z(i));
                end
                data.YXEPG(posOfZ(i)) = z(i);
            end
            exitFlag = solver.ExitFlag.ASSIGNED;
            % print(exitFlag, exitFlagHeader, this.Solver.DisplayLevel);
        end%




        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            % Remove auxiliary equations added to construct
            % exogenize/endogenize
            %{
            lastEquation = find(blz.InxEquations, 1, 'last');
            inxToRemove = this.PtrEquations>lastEquation;
            this.PtrEquations(inxToRemove) = [ ];
            % Create linear index to endogenous quantities
            numColumnsToRun = numel(blz.ColumnsToRun);
            numQuantitiesInBlock = numel(this.PtrQuantities);
            linx = sub2ind( size(data.YXEPG), ...
                            repmat(this.PtrQuantities(:), 1, numColumnsToRun), ...
                            repmat(blz.ColumnsToRun, numQuantitiesInBlock, 1) );
            this.LinearIndex = linx(:);

            % Create index of logs within linx
            linxLog = this.InxLog(this.PtrQuantities);
            linxLog = repmat(linxLog(:), numColumnsToRun, 1);
            %}
        end%


        function createJacobPattern(this, blz)
            numQuantitiesInBlock = numel(this.PtrQuantities);
            numEquationsInBlock = numel(this.PtrEquations);
            numColumnsToRun = numel(blz.ColumnsToRun);
            numUnknownsInBlock = numQuantitiesInBlock * numColumnsToRun;
            % Incidence matrix numQuantities-by-numShifts
            acrossEquations = across(blz.Incidence, 'Equations');
            acrossEquations = acrossEquations(this.PtrQuantities, :);
            % Incidence matrix numEquations-by-numQuantities
            acrossShifts = across(blz.Incidence, 'Shifts');
            acrossShifts = acrossShifts(this.PtrEquations, this.PtrQuantities);
            this.MaxLag = nan(1, numQuantitiesInBlock);
            this.MaxLead = nan(1, numQuantitiesInBlock);
            for i = 1 : numQuantitiesInBlock
                this.MaxLag(i) = find(acrossEquations(i, :), 1, 'first');
                this.MaxLead(i) = find(acrossEquations(i, :), 1, 'last');
            end
            sh0 = blz.Incidence.PosOfZeroShift;
            this.MaxLag = this.MaxLag - sh0;
            this.MaxLead = this.MaxLead - sh0;
            maxMaxLead = max(this.MaxLead);

            this.JacobPattern = false(numEquationsInBlock*numColumnsToRun, numQuantitiesInBlock*numColumnsToRun);
            this.FirstTime = nan(1, numQuantitiesInBlock*numColumnsToRun);
            this.LastTime = nan(1, numQuantitiesInBlock*numColumnsToRun);
            this.NumericalJacobFunc = cell(1, numUnknownsInBlock);
            this.NumOfActiveEquations = nan(1, numUnknownsInBlock);
            for t = 1 : numColumnsToRun
               for q = 1 : numQuantitiesInBlock
                    posUnknown = (t-1)*numQuantitiesInBlock + q;
                    pattern = false(numEquationsInBlock, numColumnsToRun);
                    firstTime = t - this.MaxLead(q);
                    if t-this.MaxLag(q)<=numColumnsToRun
                        % This value does not affect linear terminal
                        % condition.
                        lastTime = t - this.MaxLag(q);
                        if firstTime<1
                            firstTime = 1;
                        end
                        if lastTime>numColumnsToRun
                            lastTime = numColumnsToRun;
                        end
                        numTimes = lastTime - firstTime + 1;
                        inxActiveEquations = acrossShifts(:, q);
                        pattern(:, firstTime:lastTime) = repmat(inxActiveEquations, 1, numTimes);
                        if t==1
                            this.NumericalJacobFunc{posUnknown} = getNumericalJacobFunc( );
                        else
                            this.NumericalJacobFunc{posUnknown} = ...
                                this.NumericalJacobFunc{posUnknown-numQuantitiesInBlock};
                        end
                    else
                        % This value may affect linear terminal condition,
                        % so we have to differentiate all periods back to
                        % the max lead that can see the terminal condition.
                        firstTime = min(firstTime, numColumnsToRun-maxMaxLead);
                        if firstTime<1
                            firstTime = 1;
                        end
                        lastTime = numColumnsToRun;
                        pattern(:, firstTime:end) = true;
                        inxActiveEquations = true(numEquationsInBlock, 1);
                        this.NumericalJacobFunc{posUnknown} = getNumericalJacobFunc( );
                    end
                    this.NumOfActiveEquations(posUnknown) = sum(inxActiveEquations);
                    this.JacobPattern(:, posUnknown) = pattern(:);
                    this.FirstTime(posUnknown) = firstTime;
                    this.LastTime(posUnknown) = lastTime;
                end
            end

            return


            function f = getNumericalJacobFunc( )
                activeEquationsString = ['[', this.Equations{inxActiveEquations}, ']'];
                if this.VECTORIZE
                    %activeEquationsString = vectorize(activeEquationsString);
                end
                f = str2func([blz.PREAMBLE, activeEquationsString]);
            end%
        end%
    end
end

