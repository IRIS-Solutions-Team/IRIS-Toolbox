% Rectangular
%
% Simulate system with rectangular (non-triangular) transition matrix off
% a straight data matrix.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Rectangular < handle
    properties
        Solution = cell(1, 6)   % Solution matrices {T, R, K, Z, H, D}
        Expansion = cell(1, 5)  % Solution expansion matrices {Xa, Xf, Ru, J, Yu}
        IndexLog                % Index of log variables
        IdObserved              % Positions of observed variables
        IdStates                % Positions and shifts of state variables
        IdShocks                % Positions of shocks
        IdExogenous             % Positions of exogenous variables
        Expected                % Function to retrieve expected shocks from data
        Unexpected              % Function to retrieve unexpected shocks from data
        
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
            sizeData = size(data.YXEPG);
            this.LinxBackward = sub2ind(sizeData, real(this.IdBackward), firstColumn+imag(this.IdBackward));
            this.LinxCurrent = sub2ind(sizeData, real(this.IdCurrent), firstColumn+imag(this.IdCurrent));
            this.LinxStep = sizeData(1);
        end
    end


    methods (Static)
        function this = fromModel(model, variantRequested, anticipate)
            this = simulate.Rectangular( );
            keepExpansion = true;
            triangular = false;
            [this.Solution{:}] = sspaceMatrices(model, variantRequested, keepExpansion, triangular);
            [this.Expansion{:}] = expansionMatrices(model, variantRequested, triangular);
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
            this.NumBackward = size(this.Solution{1}, 2);
            this.NumForward = this.NumStates - this.NumBackward;
            this.NumShocks = numel(this.IdShocks);
            this.NumExogenous = numel(this.IdExogenous);
            if this.NumShocks>0
                this.LenExpansion = size(this.Solution{2}, 2) / this.NumShocks;
            else
                this.LenExpansion = 0;
            end
            this.IdBackward = this.IdStates(this.NumForward+1:end);
            this.IndexCurrent = imag(this.IdStates)==0;
            this.IdCurrent = this.IdStates(this.IndexCurrent);
        end
    end
end

