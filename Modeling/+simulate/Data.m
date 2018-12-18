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

        InxOfExogenized = logical.empty(0)
        InxOfEndogenized = logical.empty(0)
        Target = double.empty(0)

        % AnticipatedE  Values of anticipated shocks within the current simulation range
        AnticipatedE = double.empty(0)

        % UnanticipatedE  Values of unanticipated shocks within the current simulation range
        UnanticipatedE = double.empty(0)

        FirstColumnOfSimulation
        LastColumnOfSimulation
    end


    properties (SetAccess=protected)
        FirstColumn
        LastColumn
    end


    methods
        function updateSwap(this, plan)
            firstColumn = this.FirstColumn;
            lastColumnOfSimulation = this.LastColumnOfSimulation;
            this.InxOfExogenized = false(size(this.YXEPG));
            this.InxOfEndogenized = false(size(this.YXEPG));
            this.Target = nan(size(this.YXEPG));
            if plan.NumOfExogenizedPoints>0
                this.InxOfExogenized(this.InxOfYX, firstColumn) = plan.InxOfAnticipatedExogenized(:, firstColumn) ...
                                                                | plan.InxOfUnanticipatedExogenized(:, firstColumn);
                this.InxOfExogenized(this.InxOfYX, firstColumn+1:lastColumnOfSimulation) = plan.InxOfAnticipatedExogenized(:, firstColumn+1:lastColumnOfSimulation);
            end
            if plan.NumOfEndogenizedPoints>0
                this.InxOfEndogenized(this.InxOfE, firstColumn) = plan.InxOfAnticipatedEndogenized(:, firstColumn) ...
                                                                | plan.InxOfUnanticipatedEndogenized(:, firstColumn);
                this.InxOfEndogenized(this.InxOfE, firstColumn+1:lastColumnOfSimulation) = plan.InxOfAnticipatedEndogenized(:, firstColumn+1:lastColumnOfSimulation);
            end
            if this.NumOfExogenizedPoints>0
                this.Target(this.InxOfExogenized) = this.YXEPG(this.InxOfExogenized);
            end
        end%


        function resetOutsideBaseRange(this, model)
            numOfDataSets = size(this.YXEPG, 3);
            inxOfInitInPresample = getInxOfInitInPresample(model, this.FirstColumnOfSimulation);
            for i = 1 : numOfDataSets
                temp = this.YXEPG(:, 1:this.FirstColumnOfSimulation-1, i);
                temp(~inxOfInitInPresample) = NaN;
                this.YXEPG(:, 1:this.FirstColumnOfSimulation-1, i) = temp;
            end
            this.YXEPG(:, this.LastColumnOfSimulation+1:end, :) = NaN;
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


        function [anticipatedE, unanticipatedE] = retrieveE(this)
            [numOfQuants, numOfPeriods] = size(this.YXEPG);
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
            anticipatedE(:, [1:this.FirstColumnOfSimulation-1, this.LastColumnOfSimulation+1:end]) = 0;
            unanticipatedE(:, [1:this.FirstColumnOfSimulation-1, this.LastColumnOfSimulation+1:end]) = 0;
        end%


        function updateE(this)
            [anticipatedE, unanticipatedE] = retrieveE(this);
            this.AnticipatedE = anticipatedE;
            this.UnanticipatedE = unanticipatedE;
        end%


        function setTimeFrame(this, timeFrame)
            if nargin<2
                this.FirstColumn = this.FirstColumnOfSimulation;
                this.LastColumn = this.LastColumnOfSimulation;
                return
            end
            this.FirstColumn = timeFrame(1);
            this.LastColumn = timeFrame(end);
        end%
    end


    properties (Dependent)
        NumOfQuantities
        NumOfYX
        NumOfE
        NumOfExtendedPeriods
        NumOfExogenizedPoints
        NumOfEndogenizedPoints
        LastAnticipatedE
        LastEndogenizedE
        LastExogenizedYX
    end


    methods
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


        function value = get.NumOfExogenizedPoints(this)
            value = nnz(this.InxOfExogenized);
        end%


        function value = get.NumOfEndogenizedPoints(this)
            value = nnz(this.InxOfEndogenized);
        end%


        function value = get.LastAnticipatedE(this)
            value = find(any(this.AnticipatedE~=0, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastEndogenizedE(this)
            value = find(any(this.InxOfEndogenized(this.InxOfE, :), 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastExogenizedYX(this)
            value = find(any(this.InxOfExogenized(this.InxOfYX, :), 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%
    end


    methods (Static)
        function this = fromModelAndPlan(model, variantRequested, plan, YXEPG)
            TYPE = @int8;

            this = simulate.Data( );
            [this.YXEPG, this.BarYX] = lp4lhsmrhs(model, YXEPG, variantRequested, [ ]);
            quantity = getp(model, 'Quantity');
            this.InxOfY = getIndexByType(quantity, TYPE(1));
            this.InxOfYX = getIndexByType(quantity, TYPE(1), TYPE(2));
            this.InxOfE = getIndexByType(quantity, TYPE(31), TYPE(32));
            this.InxOfLog = quantity.IxLog;

            this.InxOfExogenized = false(size(YXEPG));
            this.InxOfEndogenized = false(size(YXEPG));

            if isa(plan, 'Plan')
                this.AnticipationStatusOfE = plan.AnticipationStatusOfExogenous;
            else
                ne = nnz(this.InxOfE);
                this.AnticipationStatusOfE = repmat(plan, ne, 1);
            end
        end%
    end
end
