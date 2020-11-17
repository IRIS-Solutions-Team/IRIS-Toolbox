classdef Stacked ...
    < solver.block.Block

    properties
        % IdQuantities  Complex-valued name-column identifiers of
        % quantities in this block
        IdQuantities (1, :) double = double.empty(1, 0)

        % IdEquations  Complex-valued equation-column identifiers of
        % equations in this block
        IdEquations (1, :) double = double.empty(1, 0)

        % TerminalSimulator  Rectangular simulation object for first-order terminal condition
        TerminalSimulator = simulate.Rectangular.empty(0)

        % FirstTime  First time between (1..numColumnsToRun) to evaluate equations
        % in for ith unknown (1..numQuantitiesInBlock*numColumnsToRun)
        FirstTime = double.empty(1, 0) 

        % LastTime  Last time between (1..numColumnsToRun) to evaluate equations in
        % for ith unknown (1..numQuantitiesInBlock*numColumnsToRun)
        LastTime = double.empty(1, 0)  

        % InxEquationsUsingTerminal  True for equations that
        % have leads reaching into the terminal condition
        InxEquationsUsingTerminal

        % InxTerminalDataPoints  Logical index of data points
        % within the simulate.Data object that are used by equations
        % reaching into the terminal condition; this array is used when
        % setting up the stacked time simulation in the @Rectangular object
        % in @Model/simulateStacked
        InxTerminalDataPoints
    end


    properties
        % StackedJacob_GradientsFunc  Anonymous function with gradients of individual
        % equations stacked
        StackedJacob_GradientsFunc
        StackedJacob_GradientsFunc_Update

        % StackedJacob_GradientsMap  Mapping from linear index in GradientsFunc to
        % linear index in the Jacobian
        StackedJacob_GradientsMap
        StackedJacob_GradientsMap_Update

        % StackedJacob_InxQuantitiesDeterminingTerminal  True for
        % quantitites that are used as initial condition by the terminal
        % condition simulator
        StackedJacob_InxQuantitiesDeterminingTerminal

        % StackedJacob_EquationsFuncUsingTerminal  Anonymous function to
        % evaluate equations that reach into terminal condition
        StackedJacob_EquationsFuncUsingTerminal

        % StackedJacob_InxLogWithinMap  1-by-numQuantities vector with log status of
        % quantities (Jacobian columns)
        StackedJacob_InxLogWithinMap (1, :) logical = logical.empty(1, 0)
        StackedJacob_InxLogWithinMap_Update (1, :) logical = logical.empty(1, 0)

        % StackedJacob_InxNeedsUpdate  Index of equation pointers to @Model
        % (not equations in the block) that do truly need an update of its
        % gradient in each iteration (because the gradient involves at
        % least one quantity solved for in this block)
        StackedJacob_InxNeedsUpdate

        % StackedJacob_IdQuantitiesWhenMapped  IdQuantities at the moment
        % when the StackedJacob_GradientsMap and StackedJacob_GradientsFunc
        % were create; these are used to check if an update of these
        % properties is needed for the next block
        StackedJacob_IdQuantitiesWhenMapped

        % StackedJacob_IdEquationsWhenMapped  IdEquations at the moment
        % when the StackedJacob_GradientsMap and StackedJacob_GradientsFunc
        % were create; these are used to check if an update of these
        % properties is needed for the next block
        StackedJacob_IdEquationsWhenMapped
    end


    properties (Dependent)
        % NeedsTerminal  True if some equations in this block have leads
        NeedsTerminal (1, 1) logical = false

        % LastTerminalColumn  Last column in which some
        % terminal data points need to be still calculated
        LastTerminalColumn
    end


    properties (Constant)
        VECTORIZE = true
        PREAMBLE = "@(x,t,L)"
    end


    methods
        function this = Stacked(varargin)
            this = this@solver.block.Block(varargin{:});
        end%
        

        varargout = getTerminalDataPoints(varargin)
        varargout = run(varargin)
        prepareJacob(varargin)
        prepareBounds(varargin)
        createGradientsFunc(varargin)
        createGradientsMap(varargin)


        function [z, exitFlag] = assign(this, data, exitFlagHeader)
            runTerminal = ~isempty(this.TerminalSimulator);
            if runTerminal
                simulateStackedNoShocks(this.TerminalSimulator, data);
            end
            columnsToRun = this.ParentBlazer.ColumnsToRun;
            linxZ = sub2ind(size(data.YXEPG), real(this.IdQuantities), imag(this.IdQuantities));
            isInvTransform = ~isempty(this.Type.InvTransform);
            %
            % Run assignments sequentially in time for recursive equations 
            %
            numColumnsToRun = numel(this.ParentBlazer.ColumnsToRun);
            z = nan(1, numColumnsToRun);
            for i = 1 : numColumnsToRun
                z(i) = this.EquationsFunc(data.YXEPG, columnsToRun(i), data.BarYX);
                if isInvTransform
                    z(i) = this.Type.InvTransform(z(i));
                end
                data.YXEPG(linxZ(i)) = z(i);
            end
            exitFlag = solver.ExitFlag.ASSIGNED;
        end%


        function prepareForSolver(this, solverOptions, data)
            columnsFrame = this.ParentBlazer.ColumnsToRun;
            if ~data.HasExogenizedYX
                this.IdQuantities = reshape( ...
                    reshape(double(this.PtrQuantities), [ ], 1) ...
                    + reshape(1i*columnsFrame, 1, [ ]), ...
                    1, [ ] ...
                );
            else
                if ~this.ParentBlazer.IsBlocks
                    %
                    % No blocks created, take all endogenous or endogenized
                    % points from the current data in the current frame
                    %
                    inxEndogenousInData = getEndogenousPointsWithinFrame(data);
                else
                    %
                    % This is one of many blocks in the simulation of this
                    % frame; find the endogenous or endogenized data points
                    % in the data that are at the same time endogenous
                    % quantities in this block
                    %

                    %
                    % If there are exogenized/endogenized data points, the
                    % blazer is guaranteed to be Blocks=false, and all
                    % quantities are included; inxEndogenousInData is
                    % numQuantities-by-numPeriods
                    %
                    inxEndogenousInData = getEndogenousPointsWithinFrame(data);

                    % 
                    % Only select quantities that are endogenous in this block;
                    % inxEndogenousInBlock is 1-by-numQuantities, corresponding
                    % to the rows of inxEndogenousInData
                    %
                    inxEndogenousInBlock = false(1, size(data.YXEPG, 1));
                    inxEndogenousInBlock(this.PtrQuantities) = true;

                    inxEndogenousInData(~inxEndogenousInBlock, :) = false;
                end

                [ptr, column] = find(inxEndogenousInData);
                this.IdQuantities = reshape(ptr + 1i*column, 1, [ ]);
            end

            this.IdEquations = reshape( ...
                reshape(double(this.PtrEquations), [ ], 1) ...
                + reshape(1i*columnsFrame, 1, [ ]), ...
                1, [ ] ...
            );

            %
            % Get the index of equations reaching into the terminal
            % condition and the index of terminal data points that needed
            % to be evaluated in this block; this is needed for both SOLVE
            % and ASSIGN blocks
            %
            getTerminalDataPoints(this, size(data.YXEPG));

            if this.Type==solver.block.Type.SOLVE
                this.SolverOptions = solverOptions;
                prepareJacob(this);
                prepareBounds(this);
            end
        end%
    end


    methods % Dependent properties
        %(
        function value = get.LastTerminalColumn(this)
            value = find(any(this.InxTerminalDataPoints, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.NeedsTerminal(this)
            value = any(this.InxEquationsUsingTerminal);
        end%
        %)
    end
end

