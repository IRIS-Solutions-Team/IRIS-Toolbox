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
        InxOfLog                        % Index of log variables
        IdOfObserved                      % Ids of observed variables
        IdOfStates                        % Ids (including shifts) of state variables
        IdOfShocks                        % Ids of shocks
        IdOfExogenous                     % Ids of exogenous variables
        RetrieveExpected                  % Function to retrieve expected shocks from yxepg
        RetrieveUnexpected                % Function to retrieve unexpected shocks from yxepg
        
        NumOfQuantities
        NumOfObserved
        NumOfStates
        NumOfForward
        NumOfBackward
        NumOfShocks
        NumOfExogenous
        LenOfExpansion
        IdOfBackward
        InxOfCurrent
        IdOfCurrent

        LinxOfBackward
        LinxOfCurrent

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
            if nargin<3
                variantRequested = 1;
            end
            keepExpansion = true;
            triangular = false;
            [ this.FirstOrderSolution{1:6}, ...
              ~, ~, ...
              this.FirstOrderSolution{7} ] = sspaceMatrices(model, variantRequested, keepExpansion, triangular);
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


        function currentForward = get.CurrentForward(this)
            R = this.FirstOrderSolution{2};
            currentForward = size(R, 2)/ne - 1;
        end%


        function this = set.FirstColumn(this, firstColumn)
            this.FirstColumn = firstColumn;
            pretendSizeOfData = [this.NumOfQuantities, firstColumn];
            this.LinxOfBackward = sub2ind( pretendSizeOfData, ...
                                           real(this.IdOfBackward), ...
                                           firstColumn + imag(this.IdOfBackward) );
            this.LinxOfCurrent = sub2ind( pretendSizeOfData, ...
                                          real(this.IdOfCurrent), ...
                                          firstColumn + imag(this.IdOfCurrent) );
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
            update(this, model variantRequested);
            numOfQuantities = getp(model, 'Quantity', 'NumOfQuantities');
            this.InxOfLog = getp(model, 'Quantity', 'IxLog');
            solutionVector = getp(model, 'Vector', 'Solution');
            this.IdOfObserved = solutionVector{1}(:);
            this.IdOfStates = solutionVector{2}(:);
            this.IdOfShocks = solutionVector{3}(:);
            this.IdOfExogenous = solutionVector{5}(:);

            this.NumOfObserved = numel(this.IdOfObserved);
            this.NumOfStates = numel(this.IdOfStates);
            this.NumOfBackward = size(this.FirstOrderSolution{1}, 2);
            this.NumOfForward = this.NumOfStates - this.NumOfBackward;
            this.NumOfShocks = numel(this.IdOfShocks);
            this.NumOfExogenous = numel(this.IdOfExogenous);
            this.NumOfHashEquations = getp(model, 'Equation', 'NumOfHashEquations');
            this.IdOfBackward = this.IdOfStates(this.NumOfForward+1:end);
            this.InxOfCurrent = imag(this.IdOfStates)==0;
            this.IdOfCurrent = this.IdOfStates(this.InxOfCurrent);
            this.NumOfQuantities = numOfQuantities;
        end%
    end
end

