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

        SolutionVector
        
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




        function [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this)
            ny = numel(this.SolutionVector{1});
            [nxi, nb] = size(this.FirstOrderSolution{1});
            nf = nxi - nb;
            ne = numel(this.SolutionVector{3});
            ng = numel(this.SolutionVector{5});
        end%




        function currentForward = get.CurrentForward(this)
            R = this.FirstOrderSolution{2};
            if size(R, 2)==0
                % No shocks in the model, return immediately
                currentForward = 0;
                return
            end
            ne = numel(this.SolutionVector{3});
            currentForward = size(R, 2)/ne - 1;
        end%




        function value = get.NumOfHashEquations(this)
            value = numel(this.HashEquationsIndividually);
        end%




        function setFrame(this, timeFrame)
            VEC = @(x) x(:);
            this.FirstColumn = timeFrame(1);
            this.LastColumn = timeFrame(2);
            [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
            idXif = VEC(this.SolutionVector{2}(1:nf));
            idXib = VEC(this.SolutionVector{2}(nf+1:end));
            T = this.FirstOrderSolution{1};
            idCurrentXi = VEC(this.SolutionVector{2}(this.InxOfCurrentWithinXi));
            numQuants = numel(this.Quantity.Name);
            pretendSizeData = [numQuants, this.FirstColumn+max([0; imag(idXif)])];
            this.LinxOfXib = sub2ind( pretendSizeData, ...
                                      real(idXib), ...
                                      this.FirstColumn + imag(idXib) );
            this.LinxOfXif = sub2ind( pretendSizeData, ...
                                      real(idXif), ...
                                      this.FirstColumn + imag(idXif) );
            this.LinxOfCurrentXi = sub2ind( pretendSizeData, ...
                                            real(idCurrentXi), ...
                                            this.FirstColumn + imag(idCurrentXi) );
        end%
    end



    methods (Static)
        function this = fromModel(model, variantRequested, useFirstOrder)
            if nargin<2
                variantRequested = 1;
            elseif variantRequested>1 && length(model)==1 
                variantRequested = 1;
            end

            this = simulate.Rectangular( );
            this.Quantity = getp(model, 'Quantity');

            % Get first-order solution matrices and expansion matrices
            if useFirstOrder
                update(this, model, variantRequested);
            end

            this.SolutionVector = getp(model, 'Vector', 'Solution');
            this.InxOfCurrentWithinXi = imag(this.SolutionVector{2})==0;
        end%
    end
end

