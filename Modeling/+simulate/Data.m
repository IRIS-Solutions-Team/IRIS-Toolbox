classdef Data < handle
    properties
        % YXEPG  NumOfQuants-by-NumOfPeriods matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        YXEPG = double.empty(0) 

        % BarYX  NumOfYX-by-NumOfPeriods matrix of steady levels for [observed; endogenous]
        BarYX = double.empty(0) 

        % NonlinAddfactors  Add-factors to hash equations
        NonlinAddfactors = double.empty(0)

        % InxOfY  True for measurement variables
        InxOfY = logical.empty(1, 0)

        % InxOfYX  True for measurement or transition variables
        InxOfYX = logical.empty(1, 0)

        % InxOfE  True for shocks
        InxOfE = logical.empty(1, 0)

        % InxOfLog  True for log variables
        InxOfLog = logical.empty(1, 0)

        % AnticipationStatusOfE  True for expected shocks
        AnticipationStatusOfE = logical.empty(0, 1)

        % MixinUnanticipated  True if anticipated and unanticipated shocks are simulated in one run
        MixinUnanticipated = false

        % InxOfInitInPresample  True for initial conditions in presample array
        InxOfInitInPresample = logical.empty(0)

        Exogenized = logical.empty(0)
        Endogenized = logical.empty(0)
        Target = double.empty(0)

        % AnticipatedE  Values of anticipated shocks within the current simulation range
        AnticipatedE = double.empty(0)

        % UnanticipatedE  Values of unanticipated shocks within the current simulation range
        UnanticipatedE = double.empty(0)

        FirstColumn
        LastColumn
        TimeFrame
    end


    properties (Dependent)
        NumOfQuantities
        NumOfYX
        NumOfE
        NumOfExtendedPeriods
    end


    methods
        function updateExogenizedEndogenizedTarget(this, plan)
            firstColumn = this.FirstColumn;
            lastColumn = this.LastColumn;
            timeFrame = this.TimeFrame;
            this.Exogenized = false(size(this.YXEPG));
            this.Endogenized = false(size(this.YXEPG));
            this.Target = nan(size(this.YXEPG));
            if ~isempty(plan.Exogenized)
                this.Exogenized(this.InxOfYX, firstColumn:lastColumn) = plan.Exogenized(:, firstColumn:lastColumn, timeFrame);
            end
            if ~isempty(plan.Endogenized)
                this.Endogenized(this.InxOfE, firstColumn:lastColumn) = plan.Endogenized(:, firstColumn:lastColumn, timeFrame);
            end
            if nnz(this.Exogenized)>0
                this.Target(this.Exogenized) = this.YXEPG(this.Exogenized);
            end
        end%


        function resetOutsideBaseRange(this, firstColumnToRun, lastColumnToRun)
            numOfDataSets = size(this.YXEPG, 3);
            for i = 1 : numOfDataSets
                temp = this.YXEPG(:, 1:firstColumnToRun-1, i);
                temp(~this.InxOfInitInPresample) = NaN;
                this.YXEPG(:, 1:firstColumnToRun-1, i) = temp;
            end
            this.YXEPG(:, lastColumnToRun+1:end, :) = NaN;
        end%

            
        function YXEPG = addSteadyTrends(this, YXEPG)
            inx = this.InxOfYx & this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) .* this.BarYX(this.InxOfLog(this.InxOfYX), :);
            
            inx = this.InxOfYx & ~this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) + this.BarYX(~this.InxOfLog(this.InxOfYX), :);
        end%


        function YXEPG = removeSteadyTrends(this, YXEPG)
            inx = this.InxOfYx & this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) ./ this.BarYX(this.InxOfLog(this.InxOfYX), :);
            
            inx = this.InxOfYx & ~this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) - this.BarYX(~this.InxOfLog(this.InxOfYX), :);
        end%


        function lastAnticipatedE = getLastAnticipatedE(this)
            lastAnticipatedE = find(any(this.AnticipatedE~=0, 1), 1, 'last');
            if isempty(lastAnticipatedE)
                lastAnticipatedE = 0;
            end
        end%


        function lastEndogenizedE = getLastEndogenizedE(this)
            lastEndogenizedE = find(any(this.Endogenized(this.InxOfE, :), 1), 1, 'last');
            if isempty(lastEndogenizedE)
                lastEndogenizedE = 0;
            end
        end%


        function retrieveE(this)
            [numOfQuants, numOfPeriods] = size(this.YXEPG);
            firstColumn = this.FirstColumn;
            lastColumn = this.LastColumn;
            numOfE = nnz(this.InxOfE);
            if numOfE==0
                % No shocks in model, return immediately
                this.AnticipatedE = zeros(0, numOfPeriods);
                this.UnanticipatedE = zeros(0, numOfPeriods);
                return
            end
            if all(this.AnticipationStatusOfE)
                % All shocks anticipated
                anticipatedE = real( this.YXEPG(this.InxOfE, :) );
                unanticipatedE = imag( this.YXEPG(this.InxOfE, :) );
            elseif all(~this.AnticipationStatusOfE)
                % All shocks unanticipated
                anticipatedE = imag( this.YXEPG(this.InxOfE, :) );
                unanticipatedE = real( this.YXEPG(this.InxOfE, :) );
            else
                % Mixed anticipation status 
                anticipatedE = zeros(numOfE, numOfPeriods);
                unanticipatedE = zeros(numOfE, numOfPeriods);
                % Retrieve anticipated shocks
                inxOfExpE = false(1, numOfQuants);
                inxOfExpE(this.InxOfE) = this.AnticipationStatusOfE;
                anticipatedE(this.AnticipationStatusOfE, :) = real( this.YXEPG(inxOfExpE, :) );
                unanticipatedE(this.AnticipationStatusOfE, :) = imag( this.YXEPG(inxOfExpE, :) );
                % Retrieve unanticipated shocks
                inxOfUnxE = false(1, numOfQuants);
                inxOfUnxE(this.InxOfE) = ~this.AnticipationStatusOfE;
                anticipatedE(~this.AnticipationStatusOfE, :) = imag( this.YXEPG(inxOfUnxE, :) );
                unanticipatedE(~this.AnticipationStatusOfE, :) = real( this.YXEPG(inxOfUnxE, :) );
            end
            % Reset shocks outside the current simulation range to zero
            anticipatedE(:, [1:firstColumn-1, lastColumn+1:end]) = 0;
            unanticipatedE(:, [1:firstColumn-1, lastColumn+1:end]) = 0;
            this.AnticipatedE = anticipatedE;
            this.UnanticipatedE = unanticipatedE;
        end%


        function value = get.NumOfQuantities(this)
            value = size(this.YXEPG, 1);
        end%


        function value = get.NumOfYX(this)
            value = nnz(this.InxOfYX);
        end%


        function value = get.NumOfE(this)
            value = nnz(this.InxOfE);
        end%


        function value = get.NumOfExtendedPeriods(this)
            value = size(this.YXEPG, 2);
        end%
    end


    methods (Static)
        function this = fromModelAndPlan(model, variantRequested, plan, YXEPG, firstColumnToRun)
            TYPE = @int8;

            this = simulate.Data( );
            [this.YXEPG, this.BarYX] = lp4lhsmrhs(model, YXEPG, variantRequested, [ ]);
            quantity = getp(model, 'Quantity');
            this.InxOfY = getIndexByType(quantity, TYPE(1));
            this.InxOfYX = getIndexByType(quantity, TYPE(1), TYPE(2));
            this.InxOfE = getIndexByType(quantity, TYPE(31), TYPE(32));
            this.InxOfLog = quantity.IxLog;
            this.InxOfInitInPresample = getInxOfInitInPresample(model, firstColumnToRun);

            this.Exogenized = false(size(YXEPG));
            this.Endogenized = false(size(YXEPG));

            if isa(plan, 'Plan')
                this.AnticipationStatusOfE = plan.AnticipationStatusOfExogenous;
            else
                ne = nnz(this.InxOfE);
                this.AnticipationStatusOfE = repmat(plan, ne, 1);
            end
        end%
    end
end
