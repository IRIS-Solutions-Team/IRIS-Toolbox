classdef Data ...
    < iris.mixin.DataBlock

    properties
        % ForceInit  Vector of initial conditions to replace YXEPG data
        ForceInit = double.empty(0)

        % InitYX  Sparse matrix of the original input data for YX
        InitYX = []

        % BarYX  NumYX-by-NumOfPeriods matrix of steady levels for [observed; endogenous]
        BarYX = []

        % MeasurementTrends  NumY-by-NumPeriods array of measurement trends; the trends are delogarithmized for log-variables
        MeasurementTrends = []

        % NonlinAddf  Add-factors in hash equations
        NonlinAddf = []

        % InxY  True for measurement variables within rows of YXEPG
        InxY = logical.empty(1, 0)

        % InxX  True for transition variables within rows of YXEPG
        InxX = logical.empty(1, 0)

        % InxE  True for shocks within rows of YXEPG
        InxE = logical.empty(1, 0)

        % InxLog  True for log variables within rows of YXEPG
        InxLog = logical.empty(1, 0)

        % InxAnticipatedE  True for shocks declared anticipated within rows
        % of YXEPG
        InxAnticipatedE

        % InxUnanticipatedE  True for shocks declared unanticipated within rows
        % of YXEPG
        InxUnanticipatedE

        % MixinUnanticipated  True if anticipated and unanticipated shocks are simulated in one run
        MixinUnanticipated = false

        % InxExogenizedYX  Sparse true for exogenized measurement or
        % transition variables within the YXEPG array
        InxExogenizedYX = [ ]

        % InxEndogenizedE  Sparse true for endogenized shocks within the YXEPG
        % array
        InxEndogenizedE = [ ]

        % SigmasE  Vector of sigmas (inverse weights) for individual shocks
        SigmasE = [ ]

        % Sigma  Inverse weighting matrix composed of squares of individual sigmas
        Sigma = [ ]

        % TargetYX  Sparse target values for exogenized variables
        TargetYX = [ ]

        % InxHashedYX  Incidence of measurement and transtion variables in hash equations
        InxHashedYX = logical.empty(0)

        % AnticipatedE  Values of anticipated shocks within the current simulation range
        AnticipatedE = [ ]

        % UnanticipatedE  Values of unanticipated shocks within the current simulation range
        UnanticipatedE = double.empty(0)

        Deviation 

        FirstColumnSimulation
        LastColumnSimulation

        % Window  Window for nonlinear addfactors
        Window = 0

        % FirstColumnFrame  First column of current frame to be simulated
        FirstColumnFrame

        % LastColumnFrame  Last column of current frame to be simulated
        LastColumnFrame

        % NeedsUpdateShocks  Shocks have been modified in simulation and need to be update in the output databan
        NeedsUpdateShocks = false

        % IgnoreShocks  True if shocks to be ignored in the simulation
        IgnoreShocks = false
    end


    methods
        function updateSwapsFromPlan(this, plan)
            %
            % Preallocate InxExogenizedYX and InxEndogenizedE as sparse
            % arrays the size of YXEPG
            %
            this.InxExogenizedYX = logical(this.EmptySparse);
            this.InxEndogenizedE = logical(this.EmptySparse);

            %
            % Retrieve indices of exogenized and endogenized data points
            % within the frame from the @Plan. The @Plan returns the
            % exogenized indices for the array of endogenous quantities
            % (YX) only, and the endogenzed indices for the array of
            % exogenous quantities (E) only.
            %
            [this.InxExogenizedYX(this.InxYX, :), this.InxEndogenizedE(this.InxE, :)] ...
                 = getSwapsWithinFrame(plan, this.FirstColumnFrame, this.LastColumnSimulation);

            %
            % Restore the exogenized YX values in YXEPG from their TargetYX
            % storage because they may have been overwritten in the
            % simulations of the preceding frames
            %
            if this.HasExogenizedYX
                this.YXEPG(this.InxExogenizedYX) = this.TargetYX(this.InxExogenizedYX);
            end

            %
            % Create an inverse weighting matrix for endogenized E
            %
            if this.HasEndogenizedE
                this.Sigma = diag(power(full(this.SigmasE(this.InxEndogenizedE)), 2));
            end
        end%


        function YXEPG = addMeasurementTrends(this, YXEPG)
            %(
            if ~any(this.InxY)
                return
            end
            inx = this.InxY & ~this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) + this.MeasurementTrends(~this.InxLog(this.InxY), :);
            inx = this.InxY & this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) .* this.MeasurementTrends(this.InxLog(this.InxY), :);
            %)
        end%


        function YXEPG = removeMeasurementTrends(this, YXEPG)
            %(
            if ~any(this.InxY)
                return
            end
            inx = this.InxY & ~this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) - this.MeasurementTrends(~this.InxLog(this.InxY), :);
            inx = this.InxY & this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) ./ this.MeasurementTrends(this.InxLog(this.InxY), :);
            %)
        end%


        function YXEPG = addSteadyTrends(this, YXEPG)
            %(
            inx = this.InxYX & ~this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) + this.BarYX(~this.InxLog(this.InxYX), :);
            inx = this.InxYX & this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) .* this.BarYX(this.InxLog(this.InxYX), :);
            %)
        end%


        function YXEPG = removeSteadyTrends(this, YXEPG)
            %(
            inx = this.InxYX & ~this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) - this.BarYX(~this.InxLog(this.InxYX), :);
            inx = this.InxYX & this.InxLog;
            YXEPG(inx, :) = YXEPG(inx, :) ./ this.BarYX(this.InxLog(this.InxYX), :);
            %)
        end%


        function writeXib0(this, rect, initials)
            linxXib = rect.LinxOfXib;
            offset = size(this.YXEPG, 1);
            linxXib0 = linxXib - offset;
            this.YXEPG(linxXib0) = reshape(initials, [], 1);
        end%


        function storeE(this)
            if ~any(this.InxE)
                % No shocks in model, return immediately
                return
            end
            columnRange = this.FirstColumnSimulation : this.LastColumnSimulation;
            inxAnticipatedE = this.InxAnticipatedE;
            inxUnanticipatedE = this.InxUnanticipatedE;
            if any(inxAnticipatedE)
                this.YXEPG(this.InxAnticipatedE, columnRange) ...
                    = this.AnticipatedE(this.InxAnticipatedE, columnRange) ...
                    + 1i * this.UnanticipatedE(this.InxAnticipatedE, columnRange);
            end
            if any(inxUnanticipatedE)
                this.YXEPG(this.InxUnanticipatedE, columnRange) ...
                    = this.UnanticipatedE(this.InxUnanticipatedE, columnRange) ...
                    + 1i * this.AnticipatedE(this.InxUnanticipatedE, columnRange);
            end
        end%


        function setFrame(this, timeFrame)
            if nargin<2
                this.FirstColumnFrame = this.FirstColumnSimulation;
                this.LastColumnFrame = this.LastColumnSimulation;
                return
            end
            this.FirstColumnFrame = timeFrame(1);
            this.LastColumnFrame = timeFrame(end);
        end%


        function E = combineShocksWithinFrame(this)
            columnsFrame = this.FirstColumnFrame : this.LastColumnFrame;
            E = this.EmptySparse;
            E(:, columnsFrame) = this.AnticipatedE(:, columnsFrame);
            E(:, columnsFrame(1)) = E(:, columnsFrame(1)) + this.UnanticipatedE(:, columnsFrame(1));
        end%


        function updateShocksWithinFrame(this)
            %(
            columnsFrame = this.FirstColumnFrame : this.LastColumnFrame;

            %
            % Combine anticipated and unanticipated shocks within this frame
            %
            E = combineShocksWithinFrame(this);

            %
            % Use endogenized shocks either from the input data
            %
            if this.HasEndogenizedE
                E(this.InxEndogenizedE) = this.YXEPG(this.InxEndogenizedE);
            end

            inxNaN = isnan(E);
            if any(inxNaN(:))
                E(inxNaN) = 0;
            end
            this.YXEPG(this.InxE, columnsFrame) = E(this.InxE, columnsFrame);
            %)
        end%


        function preserveTargetValues(this)
            this.TargetYX = this.YXEPG;
        end%



        function updateTargetsWithinFrame(this)
            %(
            if ~this.HasExogenizedYX
                return
            end
            this.YXEPG(this.InxExogenizedYX) = this.TargetYX(this.InxExogenizedYX);
            %)
        end%


        function inxEndogenous = getEndogenousPointsWithinFrame(this)
            columnsFrame = this.FirstColumnFrame : this.LastColumnFrame;
            columnsOutsideFrame = [1:columnsFrame(1)-1, columnsFrame(end)+1:size(this.YXEPG, 2)];

            %
            % First, set all measurement and transition variables within
            % the frame to true
            %
            inxEndogenous = false(size(this.YXEPG));
            inxEndogenous(this.InxYX, columnsFrame) = true;

            %
            % Then, set all exogenized measurement and transition variables
            % within the frame to false
            %
            inxExogenizedYX = this.InxExogenizedYX;
            inxExogenizedYX(:, columnsOutsideFrame) = false;
            inxEndogenous = inxEndogenous & ~inxExogenizedYX;

            %
            % Finally, set all endogenized shocks within the frame to true
            %
            inxEndogenizedE = this.InxEndogenizedE;
            inxEndogenizedE(:, columnsOutsideFrame) = false;
            inxEndogenous = inxEndogenous | inxEndogenizedE;
        end%
    end


    properties (Dependent)
        InxYX
        InxLogWithinYX
        NumExogenizedYX
        NumExogenizedY
        NumEndogenizedE
        LastAnticipatedE
        LastUnanticipatedE
        LastEndogenizedE
        LastExogenizedYX
        LastHashedYX
        HasExogenizedYX
        HasEndogenizedE
        EmptySparse
    end


    methods
        function value = get.InxYX(this)
            value = this.InxY | this.InxX;
        end%


        function value = get.InxLogWithinYX(this)
            value = this.InxLog(this.InxYX);
        end%


        function value = get.NumExogenizedYX(this)
            value = nnz(this.InxExogenizedYX);
        end%


        function value = get.NumExogenizedY(this)
            value = nnz(this.InxExogenizedYX(this.InxY, :));
        end%


        function value = get.NumEndogenizedE(this)
            value = nnz(this.InxEndogenizedE);
        end%


        function value = get.LastAnticipatedE(this)
            value = find(any(this.AnticipatedE~=0, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastUnanticipatedE(this)
            value = find(any(this.UnanticipatedE~=0, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastEndogenizedE(this)
            value = find(any(this.InxEndogenizedE, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastExogenizedYX(this)
            value = find(any(this.InxExogenizedYX, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.LastHashedYX(this)
            if isempty(this.InxHashedYX)
                value = 0;
                return
            end
            anyHashedYX = any(this.InxHashedYX, 1);
            value = find(anyHashedYX, 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.HasExogenizedYX(this)
            value = this.NumExogenizedYX>0;
        end%


        function value = get.HasEndogenizedE(this)
            value = this.NumEndogenizedE>0;
        end%


        function value = get.EmptySparse(this)
            value = sparse(size(this.YXEPG, 1), size(this.YXEPG, 2));
        end%
    end


    methods (Static)
        function this = fromModelAndPlan(model, run, plan, runningData)
            modelVariant = run;
            if countVariants(model)==1
                modelVariant = 1;
            end

            planVariant = run;
            if countVariants(plan)==1
                planVariant = 1;
            end

            this = simulate.Data( );
            this.FirstColumnSimulation = runningData.BaseRangeColumns(1);
            this.LastColumnSimulation = runningData.BaseRangeColumns(end);
            this.Window = runningData.Window;
            columnsSimulation = this.FirstColumnSimulation : this.LastColumnSimulation;
            numQuantities = size(this.YXEPG, 1);

            quantity = getp(model, 'Quantity');
            this.InxY = getIndexByType(quantity, 1);
            this.InxX = getIndexByType(quantity, 2);
            this.InxE = getIndexByType(quantity, 31, 32);
            this.InxLog = quantity.InxLog;

            [this.YXEPG, this.BarYX] = lp4lhsmrhs(model, runningData.YXEPG(:, :, run), modelVariant, [ ]);

            this.MeasurementTrends = evalTrendEquations(model, [], this.YXEPG, modelVariant);
            inxDelog = this.InxLog(this.InxY);
            this.MeasurementTrends(inxDelog, :, :) = exp(this.MeasurementTrends(inxDelog, :, :));

            this.InxExogenizedYX = logical(this.EmptySparse);
            this.InxEndogenizedE = logical(this.EmptySparse);

            this.TargetYX = [];

            this.SigmasE = this.EmptySparse;
            if isempty(plan.SigmasExogenous)
                this.SigmasE(this.InxE, columnsSimulation) = 1;
            else
                this.SigmasE(this.InxE, columnsSimulation) ...
                    = plan.SigmasExogenous(:, columnsSimulation, planVariant);
            end

            %
            % Index of anticipated and unanticipated shocks either from the
            % @Plan object or depending on the true/false plan.
            %
            this.InxAnticipatedE = false(1, numQuantities);
            this.InxUnanticipatedE = false(1, numQuantities);
            if isa(plan, 'Plan')
                this.InxAnticipatedE(this.InxE) = plan.AnticipationStatusExogenous;
                this.InxUnanticipatedE(this.InxE) = not(plan.AnticipationStatusExogenous);
            else
                this.InxAnticipatedE(this.InxE) = plan;
                this.InxUnanticipatedE(this.InxE) = not(plan);
            end

            this.Deviation = runningData.Deviation(run);
        end%


        function [anticipatedE, unanticipatedE] = splitE(YXEPG, inxAnticipatedE, inxUnanticipatedE, columns)
            %
            % Preallocate sparse arrays
            %
            anticipatedE = sparse(size(YXEPG, 1), size(YXEPG, 2));
            unanticipatedE = sparse(size(YXEPG, 1), size(YXEPG, 2));

            %
            % Return immediately if there are no shocks
            %
            if ~any(inxAnticipatedE(:)) && ~any(inxUnanticipatedE(:))
                return
            end

            %
            % Retrieve anticipated shocks
            %
            anticipatedE(inxAnticipatedE, columns) = real(YXEPG(inxAnticipatedE, columns));
            anticipatedE(inxUnanticipatedE, columns) = imag(YXEPG(inxUnanticipatedE, columns));

            %
            % Retrieve unanticipated shocks
            %
            unanticipatedE(inxUnanticipatedE, columns) = real(YXEPG(inxUnanticipatedE, columns));
            unanticipatedE(inxAnticipatedE, columns) = imag(YXEPG(inxAnticipatedE, columns));
        end%
    end
end


