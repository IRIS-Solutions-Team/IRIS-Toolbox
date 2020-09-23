% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight yxepg matrix
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef Rectangular < handle
    properties
        Method
        PlanMethod

        FirstOrderSolution = cell(1, 7)   % First-order solution matrices {T, R, K, Z, H, D, Y}, discard U, Zb
        FirstOrderExpansion = cell(1, 5)  % First-order expansion matrices {Xa, Xf, Ru, J, Yu}

        % FirstOrderMultipliers  First-order multipliers for endogenized shocks
        FirstOrderMultipliers = double.empty(0) 

        KalmanGain = double.empty(0)
        MultipliersExogenizedYX = logical.empty(0)
        MultipliersEndogenizedE = logical.empty(0)

        % Vector  System and solution vectors derived from @Model
        Vector 
        
        % Quantity  Information about model quantities derived from @Modelk
        Quantity 

        HashEquationsAll
        HashEquationsIndividually
        HashEquationsInput

        % HashIncidence  Incidence object for hash equations
        HashIncidence = model.component.Incidence.empty(0)

        HashMultipliers = double.empty(0)
        MultipliersHashedYX = logical.empty(0)

        InxOfCurrentWithinXi
        LinxOfXib
        LinxOfXif
        LinxOfCurrentXi

        Deviation = false
        SimulateY = true
        NeedsEvalTrends = true
        UpdateEntireXib = false

        SparseShocks = false

        % Header  Header to display with the final convergence report
        Header (1, 1) string = ""

        % StackedNoShocks_   Solution matrices and data point indices for
        % stacked time simulation of selected data points with no shocks
        StackedNoShocks_Transition 
        StackedNoShocks_Constant
        StackedNoShocks_InxDataPoints
    end


    properties (SetAccess=protected)
        FirstColumn = NaN
        LastColumn = NaN
    end


    properties (Dependent)
        CurrentForward
        NumOfHashEquations
    end


    methods
        flat(varargin)
        calculateHashMultipliers(varargin)
        multipliers(varargin)
        prepareStackedNoShocks(varargin)
        resetStackedNoShocks(varargin)


        function update(this, model, variantRequested)
        % update  Update first-order solution matrices and available expansion
            if nargin<3
                variantRequested = 1;
            end
            keepExpansion = true;
            triangular = false;

            [this.FirstOrderSolution{1:6}, ~, ~, ~, this.FirstOrderSolution{7}] ...
                = sspaceMatrices(model, variantRequested, keepExpansion, triangular);

            [this.FirstOrderExpansion{:}] ...
                = expansionMatrices(model, variantRequested, triangular);

        end%


        function varargout = sizeSolution(this)
            [varargout{1:nargout}] = sizeSolution(this.Vector);
        end%


        function ensureExpansionGivenData(this, data)
            lastAnticipatedE = data.LastAnticipatedE;
            lastEndogenizedE = data.LastEndogenizedE;
            requiredForward = max([ ...
                lastAnticipatedE-this.FirstColumn, ...
                lastEndogenizedE-this.FirstColumn, ...
                data.Window ...
            ]);
            if isempty(requiredForward) || requiredForward==0
                return
            end
            ensureExpansion(this, requiredForward);
        end%


        function ensureExpansion(this, requiredForward)
            R = this.FirstOrderSolution{2};
            Y = this.FirstOrderSolution{7};
            if size(R, 2)==0  && size(Y, 2)==0
                % No shocks or hash equations in the model, return immediately
                return
            end
            if requiredForward<=this.CurrentForward
                % Current expansion sufficient, return immediately
                return
            end
            [R, Y] = model.expandFirstOrder(R, Y, this.FirstOrderExpansion, requiredForward);
            this.FirstOrderSolution{2} = R;
            this.FirstOrderSolution{7} = Y;
        end%


        function currentForward = get.CurrentForward(this)
            R = this.FirstOrderSolution{2};
            if size(R, 2)==0
                % No shocks in the model, return immediately
                currentForward = 0;
                return
            end
            ne = numel(this.Vector.Solution{3});
            currentForward = size(R, 2)/ne - 1;
        end%


        function value = get.NumOfHashEquations(this)
            value = numel(this.HashEquationsIndividually);
        end%


        function setFrame(this, timeFrame)
            this.FirstColumn = timeFrame(1);
            this.LastColumn = timeFrame(2);
            [ny, nxi, nb, nf, ne, ng] = sizeSolution(this);
            idXiF = reshape(this.Vector.Solution{2}(1:nf), [ ], 1);
            idXiB = reshape(this.Vector.Solution{2}(nf+1:end), [ ], 1);
            T = this.FirstOrderSolution{1};
            idCurrentXi = reshape(this.Vector.Solution{2}(this.InxOfCurrentWithinXi), [ ], 1);
            numQuants = numel(this.Quantity.Name);
            maxLead = max([0; imag(idXiF)]);
            pretendSizeData = [numQuants, this.FirstColumn + maxLead];
            this.LinxOfXib = sub2ind( ...
                pretendSizeData, ...
                real(idXiB), ...
                this.FirstColumn + imag(idXiB) ...
            );
            this.LinxOfXif = sub2ind( ...
                pretendSizeData, ...
                real(idXiF), ...
                this.FirstColumn + imag(idXiF) ...
            );
            this.LinxOfCurrentXi = sub2ind( ...
                pretendSizeData, ...
                real(idCurrentXi), ...
                this.FirstColumn + imag(idCurrentXi) ...
            );
        end%
    end


    methods (Static)
        function this = fromModel(model, variantRequested, useFirstOrder)
            %(
            if nargin<2
                variantRequested = 1;
            elseif variantRequested>1 && countVariants(model)==1 
                variantRequested = 1;
            end

            this = simulate.Rectangular( );
            
            %
            % Populate Quantity and Vector
            %
            this = prepareRectangular(model, this);

            %
            % Get first-order solution matrices and expansion matrices
            % 
            if useFirstOrder
                update(this, model, variantRequested);
            end

            %
            % Index of current dated transition variables in the solution vector
            %
            this.InxOfCurrentWithinXi = imag(this.Vector.Solution{2})==0;
            %)
        end%
    end
end

