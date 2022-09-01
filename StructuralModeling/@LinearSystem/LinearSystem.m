% LinearSystem  Barebones time-varying linear state-space system object
%
%      xi = T*xib(-1) + k + R*v
%       y = Z*xib + d + H*w
%     xib = xi(n+1:end)
%
%

classdef LinearSystem ...
    < iris.mixin.Kalman

    properties
        % Tolerance  Tolerance level object
        Tolerance = iris.mixin.Tolerance()
    end


    properties % (SetAccess=protected)
        % NumPeriods  Number of periods in which system matrices vary from asymptotic system
        NumPeriods (1, 1) double = 0

        % Dimensions  Dimensions of state space vectors [xi, xiB, v, y, w]
        Dimensions (1, 5) double = [0, 0, 0, 0, 0]

        % SystemMatrices  State space system matrices {T, R, k, Z, H, d, U, Zb}
        SystemMatrices (1, 8) cell = cell(1, 8)

        % CovarianceMatrices  Covariance matrices for transition and measurement shocks {OmegaV, OmegaW}
        CovarianceMatrices (1, 2) cell = cell(1, 2)

        % StdVectors  Vectors of std deviations for transition and measurement shocks {StdV, StdW}
        StdVectors (1, 2) cell = cell(1, 2)

        % NumUnitRoots  Number of unit roots in transition matrix T
        NumUnitRoots (1, 1) double = 0
    end


    properties (Constant)
        NAMES_SYSTEM_MATRICES     = ["T", "R", "k", "Z", "H", "d", "U", "Zb"]
        NAMES_COVARIANCE_MATRICES = ["OmegaV", "OmegaW"]
    end


    properties (Dependent)
        NumExtdPeriods
        Omega
        NumXi
        NumXiB
        NumXiF
        NumV
        NumY
        NumW
    end


    methods % Public interface
        %(
        function this = LinearSystem(varargin)
            if nargin==1 && isa(varargin{1}, 'LinearSystem')
                this = varargin{1};
            end
            if nargin>=1
                this.Dimensions = varargin{1};
            end
            if nargin>=2
                this.NumPeriods = varargin{2};
            end
            this = setup(this);
        end%


        function this = steadySystem(this, varargin)
            if numel(varargin)==1 && strcmpi(varargin{1}, 'NotNeeded')
                this = assign(this, 0, 0, 0);
            else
                this = assign(this, 0, varargin{:});
            end
        end%


        function this = timeVaryingSystem(this, time, varargin);
            if any(~ismember(time, 1:this.NumPeriods))
                thisError = { 'LinearSystem'
                              'Invalid time specified when assigning time varying system' };
                throw(exception.Base(THIS_ERROR, 'error'));
            end
            this = assign(this, time, varargin{:});
        end%


        varargout = getSystemMatrix(varargin)
        varargout = getCovarianceMatrix(varargin)
        varargout = filter(varargin)
        varargout = kalmanFilter(varargin)
        varargout = rescaleStd(varargin)
        % varargout = triangularize(this)
        %)
    end






    methods (Hidden)
        varargout = postprocessKalmanOutput(varargin)


        function value = hasLogVariables(this)
            value = false;
        end%


        function value = countVariants(this)
            value = 1;
        end%


        function names = getKalmanDataNames(this, varargin)
            [ny, ~] = sizeSolution(this)
            names = repmat("", 1, ny);
        end%


        varargout = getIthKalmanSystem(varargin)


        function [W, dW] = evalTrendEquations(this, ~, inputData, ~)
            numY = this.NumY;
            numPeriods = size(inputData, 2);
            numPages = size(inputData, 3);
            numVariantsRequested = 1;
            numParamsOut = 0;
            W = zeros(numY, numPeriods, numPages);
            dW = zeros(numY, numParamsOut, numPeriods, numVariantsRequested);
        end%


        function [numY, numXi, numXiB, numXiF, numE, numG, numZ, numV, numW] = sizeSolution(this)
            numXi = this.Dimensions(1);
            numXiB = this.Dimensions(2);
            numV = this.Dimensions(3);
            numY = this.Dimensions(4);
            numW = this.Dimensions(5);
            numE = numV + numW;
            numXiF = numXi - numXiB;
            numG = 0;
            numZ = 0;
            numV = numV;
            numW = numW;
        end%


        function getIthStdcorr( )
        end%


        function Omega = getIthOmega(this, varargin)
            Omega = this.Omega;
        end%
    end


    methods (Access=protected, Hidden)
        function this = setup(this)
            numXi = this.NumXi;
            numXiB = this.NumXiB;
            numV  = this.NumV;
            numY  = this.NumY;
            numW  = this.NumW;
            numExtPeriods = this.NumExtdPeriods;
            T = nan(numXi, numXiB, numExtPeriods);
            R = nan(numXi, numV, numExtPeriods);
            k = nan(numXi, 1, numExtPeriods);
            Z = nan(numY, numXiB, numExtPeriods);
            H = nan(numY, numW, numExtPeriods);
            d = nan(numY, 1, numExtPeriods);
            U = nan(0, 0, numExtPeriods);
            Zb = nan(0, 0, numExtPeriods);
            this.SystemMatrices = {T, R, k, Z, H, d, U, Zb};
            OmegaV = nan(numV, numV, numExtPeriods);
            OmegaW = nan(numW, numW, numExtPeriods);
            this.CovarianceMatrices = {OmegaV, OmegaW};
        end%
    end




    methods
        function numExtendedPeriods = get.NumExtdPeriods(this)
            numExtendedPeriods = this.NumPeriods + 1;
        end%




        function Omega = get.Omega(this)
            numV = this.NumV;
            numW = this.NumW;
            numE = numV + numW;
            OmegaV = this.clipAndFillMissing(this.CovarianceMatrices{1});
            OmegaW = this.clipAndFillMissing(this.CovarianceMatrices{2});
            numOmegaV = size(OmegaV, 3);
            numOmegaW = size(OmegaW, 3);
            numOmega = max(numOmegaV, numOmegaW);
            Omega = zeros(numE, numE, numOmega);
            for i = 1 : numOmega
                if i<=numOmegaV
                    OmegaV_t = this.CovarianceMatrices{1}(:, :, i);
                end
                if i<=numOmegaW
                    OmegaW_t = this.CovarianceMatrices{2}(:, :, i);
                end
                Omega(1:numV, 1:numV, i) = OmegaV_t;
                Omega(numV+1:end, numV+1:end, i) = OmegaW_t;
            end
            Omega = this.clipAndFillMissing(Omega);
        end%




        function n = get.NumXi(this)
            n = this.Dimensions(1);
        end%




        function n = get.NumXiB(this)
            n = this.Dimensions(2);
        end%




        function n = get.NumXiF(this)
            n = this.NumXi - this.NumXiB;
        end%




        function n = get.NumV(this)
            n = this.Dimensions(3);
        end%




        function n = get.NumY(this)
            n = this.Dimensions(4);
        end%




        function n = get.NumW(this)
            n = this.Dimensions(5);
        end%
    end


    methods (Static)
        function [x, last] = clipAndFillMissing(x)
            if isempty(x)
                if size(x, 3)>1
                    x = x(:, :, 1);
                end
                return
            end
            [x, last] = iris.utils.removeTrailingNaNs(x, 3);
            if any(isnan(x(:)))
                x = fillmissing(x, 'previous', 3);
            end
        end%
    end


    methods (Static) % Static constructors
        %(
        varargout = fromModel(varargin)
        %)
    end


    methods (Static, Hidden)
        function flag = validateSystemMatrixName(varargin)
            flag = all( ...
                cellfun(@(x) any(x==LinearSystem.NAMES_SYSTEM_MATRICES), varargin) ...
            );
        end%


        function flag = validateCovarianceMatrixName(varargin)
            flag = all( ...
                cellfun(@(x) any(x==LinearSystem.NAMES_COVARIANCE_MATRICES), varargin) ...
            );
        end%
    end
end

