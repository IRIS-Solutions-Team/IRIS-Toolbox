% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight yxepg matrix.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

classdef Rectangular < handle
    properties
        Method
        FirstOrderSolution = cell(1, 7)   % First-order solution matrices {T, R, K, Z, H, D, Y}, discard U, Zb
        FirstOrderExpansion = cell(1, 5)  % First-order expansion matrices {Xa, Xf, Ru, J, Yu}

        % FirstOrderMultipliers  First-order multipliers for endogenized shocks
        FirstOrderMultipliers = double.empty(0) 
        InvFirstOrderMultipliers = double.empty(0)
        MultipliersExogenizedYX = logical.empty(0)
        MultipliersEndogenizedE = logical.empty(0)

        SolutionVector
        
        Quantity

        InxOfCurrentWithinXi
        LinxOfXib
        LinxOfCurrentXi

        Deviation = false
        SimulateY = true
        NeedsEvalTrends = true

        HashEquationsFunction
        NumOfHashEquations = NaN
    end


    properties (SetAccess=protected)
        FirstColumn = NaN
        LastColumn = NaN
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
            [ this.FirstOrderSolution{1:6}, ~, ~, ~, ...
              this.FirstOrderSolution{7} ] = sspaceMatrices( model, ...
                                                             variantRequested, ...
                                                             keepExpansion, ...
                                                             triangular );
            [this.FirstOrderExpansion{:}] = expansionMatrices( model, ...
                                                               variantRequested, ...
                                                               triangular );
        end%


        function ensureExpansionGivenData(this, data)
            lastAnticipatedE = data.LastAnticipatedE;
            lastEndogenizedE = data.LastEndogenizedE;
            requiredForward = max([ lastAnticipatedE-this.FirstColumn, ...
                                    lastEndogenizedE-this.FirstColumn, ...
                                    data.Window ]);
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


        function setTimeFrame(this, timeFrame)
            VEC = @(x) x(:);
            this.FirstColumn = timeFrame(1);
            this.LastColumn = timeFrame(2);
            [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
            idOfXib = VEC(this.SolutionVector{2}(nf+1:end));
            idOfCurrentXi = VEC(this.SolutionVector{2}(this.InxOfCurrentWithinXi));
            numOfQuants = length(this.Quantity.Name);
            pretendSizeOfData = [numOfQuants, this.FirstColumn];
            this.LinxOfXib = sub2ind( pretendSizeOfData, ...
                                      real(idOfXib), ...
                                      this.FirstColumn + imag(idOfXib) );
            this.LinxOfCurrentXi = sub2ind( pretendSizeOfData, ...
                                            real(idOfCurrentXi), ...
                                            this.FirstColumn + imag(idOfCurrentXi) );
        end%


        function this = set.FirstOrderMultipliers(this, value)
            this.FirstOrderMultipliers = value;
            if this.Method==solver.Method.SELECTIVE
                this.InvFirstOrderMultipliers = inv(value);
            else
                this.InvFirstOrderMultipliers = double.empty(0);
            end
        end%
    end



    methods (Static)
        function this = fromModel(model, variantRequested)
            if nargin<2
                variantRequested = 1;
            elseif variantRequested>1 && length(model)==1 
                variantRequested = 1;
            end

            this = simulate.Rectangular( );

            % Get first-order solution matrices and expansion matrices
            update(this, model, variantRequested);

            % Quantities
            this.Quantity = getp(model, 'Quantity');

            % Solution vector
            this.SolutionVector = getp(model, 'Vector', 'Solution');

            this.InxOfCurrentWithinXi = imag(this.SolutionVector{2})==0;
        end%
    end
end

