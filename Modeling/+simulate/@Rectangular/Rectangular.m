% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight yxepg matrix.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

classdef Rectangular < handle
    properties
        FirstOrderSolution = cell(1, 7)   % First-order solution matrices {T, R, K, Z, H, D, Y}
        FirstOrderExpansion = cell(1, 5)  % First-order expansion matrices {Xa, Xf, Ru, J, Yu}
        InxOfLog                          % Index of log variables

        RetrieveExpected                  % Function to retrieve expected shocks from yxepg
        RetrieveUnexpected                % Function to retrieve unexpected shocks from yxepg

        SolutionVector
        
        NumOfQuantities
        NumOfHashEquations
        LenOfExpansion

        InxOfCurrentWithinXi
        LinxOfXib
        LinxOfCurrentXi

        Anticipate = NaN
        Deviation = false
        SimulateObserved = true
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
            [ this.FirstOrderSolution{1:6}, ...
              ~, ~, this.FirstOrderSolution{7} ] = sspaceMatrices( model, ...
                                                                   variantRequested, ...
                                                                   keepExpansion, ...
                                                                   triangular );
            [this.FirstOrderExpansion{:}] = expansionMatrices(model, variantRequested, triangular);
            if this.NumOfShocks>0
                this.LenOfExpansion = size(this.FirstOrderSolution{2}, 2) / this.NumOfShocks;
            else
                this.LenOfExpansion = 0;
            end
        end%


        function ensureExpansion(this, requiredForward)
            if requiredForward>this.CurrentForward
                R = model.expandFirstOrder(R, [ ], this.FirstOrderExpansion, requiredForward);
                this.FirstOrderSolution{2} = R;
            end
        end%


        function [ny, nx, nb, nf, ne, ng] = sizeOfSolution(this)
            ny = numel(this.SolutionVector{1});
            [nxi, nb] = size(this.FirstOrderSolution{1});
            nf = nxi - nb;
            ne = numel(this.SolutionVector{3});
            ng = numel(this.SolutionVector{5});
        end%


        function currentForward = get.CurrentForward(this)
            R = this.FirstOrderSolution{2};
            currentForward = size(R, 2)/ne - 1;
        end%


        function this = set.FirstColumn(this, firstColumn)
            [ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
            idOfXib = this.SolutionVector{2}(nf+1:end);
            idOfCurrentXi = this.SolutionVector{2}(this.InxOfCurrentWithinXi);
            this.FirstColumn = firstColumn;
            pretendSizeOfData = [this.NumOfQuantities, firstColumn];
            this.LinxOfXib = sub2ind( pretendSizeOfData, ...
                                      real(idOfXib), ...
                                      firstColumn + imag(idOfXib) );
            this.LinxOfCurrentXi = sub2ind( pretendSizeOfData, ...
                                            real(idOfCurrentXi), ...
                                            firstColumn + imag(idOfCurrentXi) );
        end%


        function this = set.Anticipate(this, anticipate)
            this.Anticipate = anticipate;
            if anticipate
                this.RetrieveExpected = @real;
                this.RetrieveUnexpected = @imag;
            else
                this.RetrieveExpected = @imag;
                this.RetrieveUnexpected = @real;
            end
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

            % Quantity
            quantity = getp(model, 'Quantity');
            this.NumOfQuantities = numel(quantity.Name);
            this.InxOfLog = quantity.IxLog;

            % Solution vector
            this.SolutionVector = getp(model, 'Vector', 'Solution');

            this.NumOfHashEquations = getp(model, 'Equation', 'NumOfHashEquations');
            this.InxOfCurrentWithinXi = imag(this.SolutionVector{2})==0;
        end%
    end
end

