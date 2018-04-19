% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight data matrix.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

classdef Rectangular < handle
    properties
        FirstOrderSolution = cell(1, 6)   % First-order solution matrices {T, R, K, Z, H, D}
        FirstOrderExpansion = cell(1, 5)  % First-order expansion matrices {Xa, Xf, Ru, J, Yu}
        IndexLog                          % Index of log variables
        IdObserved                        % Positions of observed variables
        IdStates                          % Positions and shifts of state variables
        IdShocks                          % Positions of shocks
        IdExogenous                       % Positions of exogenous variables
        Expected                          % Function to retrieve expected shocks from data
        Unexpected                        % Function to retrieve unexpected shocks from data
        
        NumObserved
        NumStates
        NumForward
        NumBackward
        NumShocks
        NumExogenous
        LenExpansion
        IdBackward
        IndexCurrent
        IdCurrent

        LinxBackward
        LinxCurrent
        LinxStep
    end


    methods
        flat(varargin)


        function prepareDataDependentProperties(this, data, firstColumn)
            sizeOfData = size(data.YXEPG);
            this.LinxBackward = sub2ind(sizeOfData, real(this.IdBackward), firstColumn+imag(this.IdBackward));
            this.LinxCurrent = sub2ind(sizeOfData, real(this.IdCurrent), firstColumn+imag(this.IdCurrent));
            this.LinxStep = sizeOfData(1);
        end
    end


    methods (Static)
        function this = fromModel(model, variantRequested, anticipate)
            this = simulate.Rectangular( );
            keepExpansion = true;
            triangular = false;
            [this.FirstOrderSolution{:}] = sspaceMatrices(model, variantRequested, keepExpansion, triangular);
            [this.FirstOrderExpansion{:}] = expansionMatrices(model, variantRequested, triangular);
            this.IndexLog = get(model, 'Quantity.IxLog');
            solutionVector = get(model, 'Vector.Solution');
            this.IdObserved = solutionVector{1}(:);
            this.IdStates = solutionVector{2}(:);
            this.IdShocks = solutionVector{3}(:);
            this.IdExogenous = solutionVector{5}(:);
            if anticipate
                this.Expected = @real;
                this.Unexpected = @imag;
            else
                this.Expected = @imag;
                this.Unexpected = @real;
            end

            this.NumObserved = numel(this.IdObserved);
            this.NumStates = numel(this.IdStates);
            this.NumBackward = size(this.FirstOrderSolution{1}, 2);
            this.NumForward = this.NumStates - this.NumBackward;
            this.NumShocks = numel(this.IdShocks);
            this.NumExogenous = numel(this.IdExogenous);
            if this.NumShocks>0
                this.LenExpansion = size(this.FirstOrderSolution{2}, 2) / this.NumShocks;
            else
                this.LenExpansion = 0;
            end
            this.IdBackward = this.IdStates(this.NumForward+1:end);
            this.IndexCurrent = imag(this.IdStates)==0;
            this.IdCurrent = this.IdStates(this.IndexCurrent);
        end
    end
end

