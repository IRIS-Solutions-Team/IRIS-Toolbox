% BareLinearKalman  Bare Bones Linear Kalman Filter Object
%
%     xi = T*xi(-1) + k + R*v
%      y = Z*xi + d + H*w
%
%

classdef BareLinearKalman < shared.Kalman
    properties (SetAccess=protected)
        % NumPeriods  Number of periods in which system matrices vary from asymptotic system
        NumPeriods (1, 1) double = 0

        % Dimensions  Dimensions of state space vectors [xi, v, y, w]
        Dimensions (1, 4) double = [0, 0, 0, 0]

        % SystemMatrices  State space system matrices TRkZHd
        SystemMatrices (1, 8) cell = cell(1, 8)

        % CovarianceMatrices  Covariance matrices for transition and measurement shocks
        CovarianceMatrices (1, 2) cell = cell(1, 2)

        % NumUnitRoots  Number of unit roots in transition matrix T
        NumUnitRoots (1, 1) double = 0
    end




    properties (Constant)
        NAMES_SYSTEM_MATRICES     = {'T', 'R', 'k', 'Z', 'H', 'd', 'U', 'Zb'}
        NAMES_COVARIANCE_MATRICES = {'OmegaV', 'OmegaW'}
    end




    properties (Dependent)
        NumExtendedPeriods
        NumVariants
        Omega
        NumXi
        NumV
        NumY
        NumW
    end




    methods % Public interface 
        %( 
        function this = BareLinearKalman(varargin)
            if nargin==1 && isa(varargin{1}, 'BareLinearKalman')
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
                thisError = { 'BareLinearKalman'
                              'Invalid time specified when assigning time varying system' };
                throw(exception.Base(THIS_ERROR, 'error'));
            end
            this = assign(this, time, varargin{:});
        end%


        varargout = filter(varargin)
        %varargout = triangularize(this)
        %)
    end






    methods (Hidden)
        varargout = getIthKalmanSystem(varargin)


        function [W, dW] = evalTrendEquations(this, ~, inputData, ~)
            ny = this.NumY;
            numPeriods = size(inputData, 2);
            numPages = size(inputData, 3);
            numVariantsRequested = 1;
            numParamsOut = 0;
            W = zeros(ny, numPeriods, numPages);
            dW = zeros(ny, numParamsOut, numPeriods, numVariantsRequested);
        end%


        function [ny, nxi, nb, nf, ne, ng, nz] = sizeOfSolution(this)
            nxi = this.Dimensions(1);
            nv  = this.Dimensions(2);
            ny  = this.Dimensions(3);
            nw  = this.Dimensions(4);
            ne  = nv + nw;
            nb  = nxi;
            nf  = 0;
            ng  = 0;
            nz  = 0;
        end%


        function getIthStdcorr( )
        end%


        function Omega = getIthOmega(this, varargin)
            Omega = this.Omega;
        end%
    end




    methods (Access=protected, Hidden)
        function this = setup(this)
            nxi = this.Dimensions(1);
            nv  = this.Dimensions(2);
            ny  = this.Dimensions(3);
            nw  = this.Dimensions(4);
            nxp = this.NumExtendedPeriods;
            T = nan(nxi, nxi, nxp);
            R = nan(nxi, nv, nxp);
            k = nan(nxi, 1, nxp);
            Z = nan(ny, nxi, nxp);
            H = nan(ny, nw, nxp);
            d = nan(ny, 1, nxp);
            U = nan(0, 0, nxp);
            Zb = nan(0, 0, nxp);
            this.SystemMatrices = {T, R, k, Z, H, d, U, Zb};
            OmegaV = nan(nv, nv, nxp);
            OmegaW = nan(nw, nw, nxp);
            this.CovarianceMatrices = {OmegaV, OmegaW};
        end%
    end




    methods
        function numExtendedPeriods = get.NumExtendedPeriods(this)
            numExtendedPeriods = this.NumPeriods + 1;
        end%


        function numVariants = get.NumVariants(this)
            numVariants = 1;
        end%


        function Omega = get.Omega(this)
            nv = this.NumV;
            nw = this.NumW;
            ne = nv + nw;
            OmegaV = this.clipAndFillMissing(this.CovarianceMatrices{1});
            OmegaW = this.clipAndFillMissing(this.CovarianceMatrices{2});
            numOmegaV = size(OmegaV, 3);
            numOmegaW = size(OmegaW, 3);
            numOmega = max(numOmegaV, numOmegaW);
            Omega = zeros(ne, ne, numOmega);
            for i = 1 : numOmega
                if i<=numOmegaV
                    OmegaV_t = this.CovarianceMatrices{1}(:, :, i);
                end
                if i<=numOmegaW
                    OmegaW_t = this.CovarianceMatrices{2}(:, :, i);
                end
                Omega(1:nv, 1:nv, i) = OmegaV_t;
                Omega(nv+1:end, nv+1:end, i) = OmegaW_t;
            end
            Omega = this.clipAndFillMissing(Omega);
        end%


        function nv = get.NumXi(this)
            nv = this.Dimensions(1);
        end%


        function nv = get.NumV(this)
            nv = this.Dimensions(2);
        end%


        function nw = get.NumY(this)
            nw = this.Dimensions(3);
        end%


        function nw = get.NumW(this)
            nw = this.Dimensions(4);
        end%
    end




    methods (Static)
        function [x, last] = clipAndFillMissing(x)
            if isempty(x)
                return
            end
            inxValid = ~isnan(x);
            inxValid = any(any(inxValid, 1), 2);
            last = find(inxValid, 1, 'last');
            if isempty(last)
                last = 0;
            end
            x = x(:, :, 1:last);
            if any(isnan(x(:)))
                x = permute(x, [3, 1, 2]);
                x = fillmissing(x, 'previous');
                x = ipermute(x, [3, 1, 2]);
            end
        end%
    end
end

