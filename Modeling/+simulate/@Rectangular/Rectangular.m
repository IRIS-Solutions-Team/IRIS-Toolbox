% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight yxepg matrix.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

classdef Rectangular < handle
    properties
        FirstOrderSolution = cell(1, 7)   % First-order solution matrices {T, R, K, Z, H, D, Y}, discard U, Zb
        FirstOrderExpansion = cell(1, 5)  % First-order expansion matrices {Xa, Xf, Ru, J, Yu}

        % FirstOrderMultipliers  First-order multipliers for endogenized shocks
        FirstOrderMultipliers = double(0) 
        MultipliersExogenizedYX = logical.empty(0)
        MultipliersEndogenizedE = logical.empty(0)

        SolutionVector
        
        Quantity
        NumOfHashEquations

        InxOfCurrentWithinXi
        LinxOfXib
        LinxOfCurrentXi

        Deviation = false
        SimulateY = true
        FirstColumn = NaN
        LastColumn = NaN
        TimeFrame = NaN
    end


    properties (Dependent)
        CurrentForward
    end


    methods
        flat(varargin)

        
        function update(this, model, variantRequested)
        % update  Update first-order solution matrices and available expansion
            if nargin<3
                variantRequested = 1;
            end
            keepExpansion = true;
            triangular = false;
            [ this.FirstOrderSolution{1:6}, ...
              ~, ~, this.FirstOrderSolution{7} ] = sspaceMatrices( model, ...
                                                                   variantRequested, ...
                                                                   keepExpansion, ...
                                                                   triangular );
            [this.FirstOrderExpansion{:}] = expansionMatrices( model, ...
                                                               variantRequested, ...
                                                               triangular );
        end%


        function ensureExpansionForData(this, data)
            lastAnticipatedE = getLastAnticipatedE(data);
            lastEndogenizedE = getLastEndogenizedE(data);
            requiredForward = max([ 0, ...
                                    lastAnticipatedE-this.FirstColumn, ...
                                    lastEndogenizedE-this.FirstColumn ]);
            ensureExpansion(this, requiredForward);
        end%


        function ensureExpansion(this, requiredForward)
            R = this.FirstOrderSolution{2};
            if size(R, 2)==0
                % No shocks in the model, return immediately
                return
            end
            if requiredForward<=this.CurrentForward
                % Current expansion sufficient, return immediately
                return
            end
            R = model.expandFirstOrder(R, [ ], this.FirstOrderExpansion, requiredForward);
            this.FirstOrderSolution{2} = R;
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


        function this = set.FirstColumn(this, firstColumn)
            VEC = @(x) x(:);
            [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
            idOfXib = VEC(this.SolutionVector{2}(nf+1:end));
            idOfCurrentXi = VEC(this.SolutionVector{2}(this.InxOfCurrentWithinXi));
            numOfQuants = length(this.Quantity.Name);
            this.FirstColumn = firstColumn;
            pretendSizeOfData = [numOfQuants, firstColumn];
            this.LinxOfXib = sub2ind( pretendSizeOfData, ...
                                      real(idOfXib), ...
                                      firstColumn + imag(idOfXib) );
            this.LinxOfCurrentXi = sub2ind( pretendSizeOfData, ...
                                            real(idOfCurrentXi), ...
                                            firstColumn + imag(idOfCurrentXi) );
        end%
    end


    methods (Static)
        function this = fromModel(model, variantRequested)
            if nargin<2
                variantRequested = 1;
            end
            this = simulate.Rectangular( );

            % Get first-order solution matrices and expansion matrices
            update(this, model, variantRequested);

            % Quantities
            this.Quantity = getp(model, 'Quantity');

            % Solution vector
            this.SolutionVector = getp(model, 'Vector', 'Solution');

            this.NumOfHashEquations = getp(model, 'Equation', 'NumOfHashEquations');
            this.InxOfCurrentWithinXi = imag(this.SolutionVector{2})==0;
        end%
    end
end

