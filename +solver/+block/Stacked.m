classdef Stacked < solver.block.Block
    properties
        Rectangular
        MaxLag = double.empty(1, 0)    % Max lag of each quantity in this block
        MaxLead = double.empty(1, 0)   % Max lead of each quantity in this block
        FirstTime = double.empty(1, 0) % First time (1..numPeriods) to evaluate equations in for ith unknown (1..numQuantitiesInBlock*numPeriods)
        LastTime = double.empty(1, 0)  % Last time dtto
        NumActiveEquations
    end


    properties (Constant)
        VECTORIZE = true;
    end


    methods
        function this = Stacked(varargin)
            this = this@solver.block.Block(varargin{:});
        end
        
        
        function [exitStatus, error] = run(this, data, t, ixLog, rect)
            exitStatus = true;
            error = struct( ...
                'EvaluatesToNan', [ ] ...
                );
            
            if isempty(this.PosQty)
                return
            end
            numQuantitiesInBlock = numel(this.PosQty);
            numEquationsInBlock = numel(this.PosEqn);
            numColumnsSimulated = numel(t);
            firstColumn = t(1);
            lastColumn = t(end);
            numColumns = lastColumn - firstColumn + 1;

            % Create linear index of unkowns in data
            linx = sub2ind( ...
                size(data.YXEPG), ...
                repmat(this.PosQty(:), 1, numColumnsSimulated), ...
                repmat(firstColumn:lastColumn, numQuantitiesInBlock, 1) ...
            );
            linx = linx(:);

            % Create index of logs within linx
            linxLog = ixLog(this.PosQty);
            linxLog = repmat(linxLog(:), numColumnsSimulated, 1);

            maxMaxLead = max(this.MaxLead);
            runFotc = this.Type==solver.block.Type.SOLVE && maxMaxLead>0;

            if this.Type==solver.block.Type.SOLVE
                % __Solve__
                deviation = false;
                observed = false;
                % Initialize endogenous quantities.
                z0 = data.YXEPG(linx);
                %ixNan = isnan(z0);
                %if any(any(ixNan))
                %    z0(ixNan) = data.YXEPG(posx(ixNan), t-1);
                %end
                ixNan = isnan(z0);
                if any(ixNan)
                    z0(ixNan) = 1;
                end
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                anyLog = any(linxLog);
                if anyLog
                    z0(linxLog) = log( z0(linxLog) );
                end
                %* Make sure init conditions are within bounds.
                %* Empty bounds if all are Inf.
                %* Bounds are in logs for log variables.
                % checkBoundsOnInitCond( );
                % Test all equations in this block for NaNs and Infs.
                checkObjective = objective(z0);
                checkObjective = reshape(checkObjective, numEquationsInBlock, numColumnsSimulated);
                indexInvalidData = ~isfinite(checkObjective);
                if any(indexInvalidData(:))
                    indexInvalidEquationsInBlock = any(indexInvalidData, 2);
                    error.EvaluatesToNan = this.PosEqn(indexInvalidEquationsInBlock);
                    return
                end
                [z, exitStatus] = solve(this, @objective, z0);
                if anyLog
                    z(linxLog) = exp( z(linxLog) );
                end
                data.YXEPG(linx) = z;
            else
                % __Assign__
                [z, exitStatus] = assign( );
            end
            
            exitStatus = all(isfinite(z)) && double(exitStatus)>0;
            
            return
            
            
            function [z, exitStatus] = assign( )
                % __Assignment__
                isInvTransform = ~isempty(this.Type.InvTransform);
                for i = 1 : numColumnsSimulated
                    z = this.EquationsFunc(data.YXEPG, t(i), data.L);
                    if isInvTransform
                        z = this.Type.InvTransform(z);
                    end
                    data.YXEPG(linx(i)) = z;
                end
                exitStatus = all(isfinite(data.YXEPG(linx)));
            end
            
            
            function y = objective(z, ithJacob)
                if nargin<2
                    ithJacob = [ ];
                end
                z = real(z);
                if anyLog
                    z(linxLog) = exp( z(linxLog) );
                end
                data.YXEPG(linx) = z;
                
                if runFotc
                    % First-order terminal condition.
                    firstColumnFotc = t(end)+1;
                    lastColumnFotc = t(end)+maxMaxLead;
                    flat(rect, data, firstColumnFotc, lastColumnFotc, deviation, observed);
                end

                if isempty(ithJacob)
                    y = this.EquationsFunc(data.YXEPG, t, data.L);
                    y = y(:);
                else
                    firstColumnJacob = firstColumn + this.FirstTime(ithJacob) - 1;
                    lastColumnJacob = firstColumn + this.LastTime(ithJacob) - 1;
                    y = [ ];
                    for column = firstColumnJacob : lastColumnJacob
                        y = [y; this.NumericalJacobFunc{ithJacob}(data.YXEPG, column, data.L)];
                    end
                end
            end
        end
    end
    
    
    methods       
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
        end


        function createJacobPattern(this, blz)
            numQuantitiesInBlock = numel(this.PosQty);
            numEquationsInBlock = numel(this.PosEqn);
            numPeriods = blz.NumPeriods;
            numUnknowns = numQuantitiesInBlock * numPeriods;
            % Incidence matrix numQuantities-by-numShifts
            acrossEquations = across(blz.Incidence, 'Equations');
            acrossEquations = acrossEquations(this.PosQty, :);
            % Incidence matrix numEquations-by-numQuantities
            acrossShifts = across(blz.Incidence, 'Shifts');
            acrossShifts = acrossShifts(this.PosEqn, this.PosQty);
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

            this.JacobPattern = false(numEquationsInBlock*numPeriods, numQuantitiesInBlock*numPeriods);
            this.FirstTime = nan(1, numQuantitiesInBlock*numPeriods);
            this.LastTime = nan(1, numQuantitiesInBlock*numPeriods);
            this.NumericalJacobFunc = cell(1, numUnknowns);
            this.NumActiveEquations = nan(1, numUnknowns);
            for t = 1 : numPeriods
               for q = 1 : numQuantitiesInBlock
                    posUnknown = (t-1)*numQuantitiesInBlock + q;
                    pattern = false(numEquationsInBlock, numPeriods);
                    firstTime = t - this.MaxLead(q);
                    if t-this.MaxLag(q)<=numPeriods
                        % This value does not affect linear terminal
                        % condition.
                        lastTime = t - this.MaxLag(q);
                        if firstTime<1
                            firstTime = 1;
                        end
                        if lastTime>numPeriods
                            lastTime = numPeriods;
                        end
                        numTimes = lastTime - firstTime + 1;
                        indexActiveEquations = acrossShifts(:, q);
                        pattern(:, firstTime:lastTime) = repmat(indexActiveEquations, 1, numTimes);
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
                        firstTime = min(firstTime, numPeriods-maxMaxLead);
                        if firstTime<1
                            firstTime = 1;
                        end
                        lastTime = numPeriods;
                        pattern(:, firstTime:end) = true;
                        indexActiveEquations = true(numEquationsInBlock, 1);
                        this.NumericalJacobFunc{posUnknown} = getNumericalJacobFunc( );
                    end
                    this.NumActiveEquations(posUnknown) = sum(indexActiveEquations);
                    this.JacobPattern(:, posUnknown) = pattern(:);
                    this.FirstTime(posUnknown) = firstTime;
                    this.LastTime(posUnknown) = lastTime;
                    %check = this.NumActiveEquations(posUnknown) * (lastTime-firstTime+1);
                    %if sum(this.JacobPattern(:, posUnknown))~=check
                    %    keyboard
                    %end
                end
            end

            return


            function f = getNumericalJacobFunc( )
                activeEquationsString = ['[', this.Equations{indexActiveEquations}, ']'];
                if this.VECTORIZE
                    %activeEquationsString = vectorize(activeEquationsString);
                end
                f = str2func([blz.PREAMBLE, activeEquationsString]);
            end
        end
    end
end
