classdef Data < matlab.mixin.Copyable
    properties
        % YXEPG  NumOfQuants-by-NumOfPeriods matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        YXEPG = double.empty(0) 

        % InitYX  NumOfYX-by-NumOfPeriods matrix of original input data for YX
        InitYX = double.empty(0)

        % BarYX  NumOfYX-by-NumOfPeriods matrix of steady levels for [observed; endogenous]
        BarYX = double.empty(0) 

        % NonlinAddf  Add-factors in hash equations
        NonlinAddf = double.empty(0)

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

        InxOfExogenizedYX = logical.empty(0)
        InxOfEndogenizedE = logical.empty(0)
        Target = double.empty(0)

        % InxOfHashedYX  Incidence of measurement and transtion variables in hash equations
        InxOfHashedYX = logical.empty(0)

        % AnticipatedE  Values of anticipated shocks within the current simulation range
        AnticipatedE = double.empty(0)

        % UnanticipatedE  Values of unanticipated shocks within the current simulation range
        UnanticipatedE = double.empty(0)

        % Trends  Measurement trend equations evaluated
        Trends = double.empty(0)

        Deviation = false
        NeedsEvalTrends = true

        FirstColumnOfSimulation
        LastColumnOfSimulation
        
        % Window  Window for nonlinear addfactors
        Window = 0

        % FirstColumnOfTimeFrame  First column of current time frame to be simulated
        FirstColumnOfTimeFrame

        % LastColumnOfTimeFrame  Last column of current time frame to be simulated
        LastColumnOfTimeFrame
    end


    methods
        function updateSwapsFromPlan(this, plan)
            [ this.InxOfExogenizedYX, ... 
              this.InxOfEndogenizedE ] = getSwapsWithinTimeFrame( plan, ...
                                                                  this.FirstColumnOfTimeFrame, ...
                                                                  this.LastColumnOfSimulation );
            this.Target = nan(this.NumOfYX, this.NumOfExtendedPeriods);
            if this.NumOfExogenizedPoints>0
                this.Target(this.InxOfExogenizedYX) = this.InitYX(this.InxOfExogenizedYX);
            end
        end%


        function YXEPG = addSteadyTrends(this, YXEPG)
            inx = this.InxOfYX & this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) .* this.BarYX(this.InxOfLog(this.InxOfYX), :);
            
            inx = this.InxOfYX & ~this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) + this.BarYX(~this.InxOfLog(this.InxOfYX), :);
        end%


        function YXEPG = removeSteadyTrends(this, YXEPG)
            inx = this.InxOfYX & this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) ./ this.BarYX(this.InxOfLog(this.InxOfYX), :);
            
            inx = this.InxOfYX & ~this.InxOfLog;
            YXEPG(inx, :) = YXEPG(inx, :) - this.BarYX(~this.InxOfLog(this.InxOfYX), :);
        end%


        %{
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
            if nargout==0
                this.AnticipatedE = anticipatedE;
                this.UnanticipatedE = unanticipatedE;
            end
        end%
        %}


        function storeE(this)
            [numOfQuants, numOfPeriods] = size(this.YXEPG);
            numOfE = nnz(this.InxOfE);
            columnRange = this.FirstColumnOfSimulation : this.LastColumnOfSimulation;
            if numOfE==0
                % No shocks in model, return immediately
                return
            end
            if all(this.AnticipationStatusOfE)
                % All shocks anticipated
                if any(this.UnanticipatedE(:)~=0)
                    this.YXEPG(this.InxOfE, columnRange) = complex( this.AnticipatedE(:, columnRange), ...
                                                                    this.UnanticipatedE(:, columnRange) );
                else
                    this.YXEPG(this.InxOfE, columnRange) = this.AnticipatedE(:, columnRange);
                end
            elseif all(~this.AnticipationStatusOfE)
                % All shocks unanticipated
                if any(this.AnticipatedE(:)~=0)
                    this.YXEPG(this.InxOfE, columnRange) = complex( this.UnanticipatedE(:, columnRange), ...
                                                                    this.AnticipatedE(:, columnRange) );
                else
                    this.YXEPG(this.InxOfE, columnRange) = this.UnanticipatedE(:, columnRange);
                end
            else
                % Mixed anticipation status 
                % Store anticipated shocks
                tempInx = false(1, numOfQuants);
                tempInx(this.InxOfE) = this.AnticipationStatusOfE;
                tempReal = this.AnticipatedE(this.AnticipationStatusOfE, columnRange);
                tempImag = this.UnanticipatedE(this.AnticipationStatusOfE, columnRange);
                if any(tempImag(:)~=0)
                    this.YXEPG(tempInx, columnRange) = complex(tempReal, tempImag);
                else
                    this.YXEPG(tempInx, columnRange) = tempReal;
                end
                % Store unanticipated shocks
                tempInx = false(1, numOfQuants);
                tempInx(this.InxOfE) = ~this.AnticipationStatusOfE;
                tempReal = this.UnanticipatedE(~this.AnticipationStatusOfE, columnRange);
                tempImag = this.AnticipatedE(~this.AnticipationStatusOfE, columnRange);
                if any(tempImag(:)~=0)
                    this.YXEPG(tempInx, columnRange) = complex(tempReal, tempImag);
                else
                    this.YXEPG(tempInx, columnRange) = tempReal;
                end
            end
        end%


        function setTimeFrame(this, timeFrame)
            if nargin<2
                this.FirstColumnOfTimeFrame = this.FirstColumnOfSimulation;
                this.LastColumnOfTimeFrame = this.LastColumnOfSimulation;
                return
            end
            this.FirstColumnOfTimeFrame = timeFrame(1);
            this.LastColumnOfTimeFrame = timeFrame(2);
        end%
    end


    properties (Dependent)
        E
        NumOfQuantities
        NumOfYX
        NumOfE
        NumOfExtendedPeriods
        NumOfExogenizedPoints
        NumOfExogenizedPointsY
        NumOfEndogenizedPoints
        LastAnticipatedE
        LastUnanticipatedE
        LastEndogenizedE
        LastExogenizedYX
        LastHashedYX
        HasExogenizedPoints
    end


    methods
        function value = get.E(this)
            value = this.YXEPG(this.InxOfE, :);
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


        function value = get.NumOfExogenizedPoints(this)
            value = nnz(this.InxOfExogenizedYX);
        end%


        function value = get.NumOfExogenizedPointsY(this)
            inxOfYX = this.InxOfYX;
            inxOfY = this.InxOfY;
            inx = inxOfY(inxOfYX);
            value = nnz(this.InxOfExogenizedYX(inx, :));
        end%


        function value = get.NumOfEndogenizedPoints(this)
            value = nnz(this.InxOfEndogenizedE);
        end%


        function value = get.LastAnticipatedE(this)
            temp = any(this.AnticipatedE~=0, 1);
            value = find(temp, 1, 'Last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastUnanticipatedE(this)
            temp = any(this.UnanticipatedE~=0, 1);
            value = find(temp, 1, 'Last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastEndogenizedE(this)
            temp = any(this.InxOfEndogenizedE, 1);
            value = find(temp, 1, 'Last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastExogenizedYX(this)
            temp = any(this.InxOfExogenizedYX, 1);
            value = find(temp, 1, 'Last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastHashedYX(this)
            if isempty(this.InxOfHashedYX)
                value = 0;
                return
            end
            anyHashedYX = any(this.InxOfHashedYX, 1);
            value = find(anyHashedYX, 1, 'Last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.HasExogenizedPoints(this)
            value = this.NumOfExogenizedPoints>0;
        end%
    end


    methods (Static)
        function this = fromModelAndPlan(model, run, plan, YXEPG, needsEvalTrends)
            TYPE = @int8;

            modelVariant = run;
            if length(model)==1
                modelVariant = 1;
            end

            dataPage = run;
            if size(YXEPG, 3)==1
                dataPage = 1;
            end

            this = simulate.Data( );
            [this.YXEPG, this.BarYX] = lp4lhsmrhs(model, YXEPG(:, :, dataPage), modelVariant, [ ]);
            quantity = getp(model, 'Quantity');
            this.InxOfY = getIndexByType(quantity, TYPE(1));
            this.InxOfYX = getIndexByType(quantity, TYPE(1), TYPE(2));
            this.InxOfE = getIndexByType(quantity, TYPE(31), TYPE(32));
            this.InxOfLog = quantity.IxLog;

            this.InxOfExogenizedYX = false(this.NumOfYX, this.NumOfExtendedPeriods);
            this.InxOfEndogenizedE = false(this.NumOfE, this.NumOfExtendedPeriods);
            this.InitYX = this.YXEPG(this.InxOfYX, :);

            if isa(plan, 'Plan')
                this.AnticipationStatusOfE = plan.AnticipationStatusOfExogenous;
            else
                ne = nnz(this.InxOfE);
                this.AnticipationStatusOfE = repmat(plan, ne, 1);
            end
                
            % Prepare data for measurement trend equations
            this.NeedsEvalTrends = needsEvalTrends;
            if this.NeedsEvalTrends
                this.Trends = evalTrendEquations(model, [ ], this.YXEPG);
                this.NeedsEvalTrends = any(this.Trends(:)~=0);
            end
        end%




        function [anticipatedE, unanticipatedE] = splitE(E, anticipationStatus, simulationColumns)
            [numOfE, numOfPeriods] = size(E);
            if numOfE==0
                % No shocks in model, return immediately
                anticipatedE = zeros(0, numOfPeriods);
                unanticipatedE = zeros(0, numOfPeriods);
                return
            end
            % Mixed anticipation status 
            anticipatedE = zeros(numOfE, numOfPeriods);
            unanticipatedE = zeros(numOfE, numOfPeriods);
            % Retrieve anticipated shocks
            anticipatedE(anticipationStatus, :) = real(E(anticipationStatus, :));
            anticipatedE(~anticipationStatus, :) = imag(E(~anticipationStatus, :));
            % Retrieve unanticipated shocks
            unanticipatedE(anticipationStatus, :) = imag(E(anticipationStatus, :));
            unanticipatedE(~anticipationStatus, :) = real(E(~anticipationStatus, :));
            % Reset shocks outside the current simulation range to zero
            firstColumnOfSimulation = simulationColumns(1);
            lastColumnOfSimulation = simulationColumns(end);
            anticipatedE(:, [1:firstColumnOfSimulation-1, lastColumnOfSimulation+1:end]) = 0;
            unanticipatedE(:, [1:firstColumnOfSimulation-1, lastColumnOfSimulation+1:end]) = 0;
        end%
    end
end


%
% Local Functions
%


function inx = correctInxForDummies(inx, n)
    if n==0
        return
    end
    inx(:, end-n+1:end) = false;
end%

