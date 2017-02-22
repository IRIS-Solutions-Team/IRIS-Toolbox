classdef VAR < varobj
    % VAR  Vector Autoregressions (VAR Objects).
    %
    % VAR objects can be constructed as plain VARs or simple panel VARs (with
    % fixed effect), and estimated without or with prior dummy observations
    % (quasi-bayesian VARs). VAR objects are reduced-form models; they are also
    % the point of departure for identifying structural VARs
    % ([`SVAR`](SVAR/Contents) objects).
    %
    % VAR methods:
    %
    % Constructor
    % ============
    %
    % * [`VAR`](VAR/VAR) - Create new empty reduced-form VAR object.
    %
    %
    % Getting information about VAR objects
    % ======================================
    %
    % * [`addparam`](VAR/addparam) - Add VAR parameters to a database (struct).
    % * [`comment`](VAR/comment) - Get or set user comments in an IRIS object.
    % * [`companion`](VAR/companion) - Matrices of first-order companion VAR.
    % * [`eig`](VAR/eig) - Eigenvalues of a VAR process.
    % * [`fprintf`](VAR/fprintf) - Write VAR model as formatted model code to text file.
    % * [`get`](VAR/get) - Query VAR object properties.
    % * [`iscompatible`](VAR/iscompatible) - True if two VAR objects can occur together on the LHS and RHS in an assignment.
    % * [`isexplosive`](VAR/isexplosive) - True if any eigenvalue is outside unit circle.
    % * [`ispanel`](VAR/ispanel) - True for panel VAR objects.
    % * [`isstationary`](VAR/isstationary) - True if all eigenvalues are within unit circle.
    % * [`length`](VAR/length) - Number of alternative parameterisations in VAR object.
    % * [`mean`](VAR/mean) - Mean of VAR process.
    % * [`nfitted`](VAR/nfitted) - Number of data points fitted in VAR estimation.
    % * [`rngcmp`](VAR/rngcmp) - True if two VAR objects have been estimated using the same dates.
    % * [`sprintf`](VAR/sprintf) - Print VAR model as formatted model code.
    % * [`sspace`](VAR/sspace) - Quasi-triangular state-space representation of VAR.
    % * [`userdata`](VAR/userdata) - Get or set user data in an IRIS object.
    %
    %
    % Referencing VAR objects
    % ========================
    %
    % * [`group`](VAR/group) - Retrieve VAR object from panel VAR for specified group of data.
    % * [`subsasgn`](VAR/subsasgn) - Subscripted assignment for VAR objects.
    % * [`subsref`](VAR/subsref) - Subscripted reference for VAR objects.
    %
    %
    % Simulation, forecasting and filtering
    % ======================================
    %
    % * [`ferf`](VAR/ferf) - Forecast error response function.
    % * [`filter`](VAR/filter) - Filter data using a VAR model.
    % * [`forecast`](VAR/forecast) - Unconditional or conditional VAR forecasts.
    % * [`instrument`](VAR/instrument) - Define forecast conditioning instruments in VAR models.
    % * [`resample`](VAR/resample) - Resample from a VAR object.
    % * [`simulate`](VAR/simulate) - Simulate VAR model.
    %
    %
    % Manipulating VARs
    % ==================
    %
    % * [`assign`](VAR/assign) - Manually assign system matrices to VAR object.
    % * [`alter`](VAR/alter) - Expand or reduce the number of alternative parameterisations within a VAR object.
    % * [`backward`](VAR/backward) - Backward VAR process.
    % * [`demean`](VAR/demean) - Remove constant and the effect of exogenous inputs from VAR object.
    % * [`horzcat`](VAR/horzcat) - Combine two compatible VAR objects in one object with multiple parameterisations.
    % * [`integrate`](VAR/integrate) - Integrate VAR process and data associated with it.
    % * [`xasymptote`](VAR/xasymptote) - Set or get asymptotic assumptions for exogenous inputs.
    %
    %
    % Stochastic properties
    % ======================
    %
    % * [`acf`](VAR/acf) - Autocovariance and autocorrelation functions for VAR variables.
    % * [`fmse`](VAR/fmse) - Forecast mean square error matrices.
    % * [`vma`](VAR/vma) - Matrices describing the VMA representation of a VAR process.
    % * [`xsf`](VAR/xsf) - Power spectrum and spectral density functions for VAR variables.
    %
    %
    % Estimation, identification, and statistical tests
    % ==================================================
    %
    % * [`estimate`](VAR/estimate) - Estimate a reduced-form VAR or BVAR.
    % * [`infocrit`](VAR/infocrit) - Populate information criteria for a parameterised VAR.
    % * [`lrtest`](VAR/lrtest) - Likelihood ratio test for VAR models.
    % * [`portest`](VAR/portest) - Portmanteau test for autocorrelation in VAR residuals.
    % * [`schur`](VAR/schur) - Compute and store triangular representation of VAR.
    %
    %
    % Getting on-line help on VAR functions
    % ======================================
    %
    %     help VAR
    %     help VAR/function_name
    %
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    properties
        K = [ ] % Constant vector.
        G = [ ] % Coefficients at co-integrating vector in VEC form.
        Sigma = [ ] % Cov of parameters.
        T = [ ] % Shur decomposition of the transition matrix.
        U = [ ] % Schur transformation of the variables.
        Aic = [ ] % Akaike info criterion.
        Sbc = [ ] % Schwartz bayesian criterion.
        Rr = [ ] % Parameter restrictions.
        NHyper = NaN % Number of estimated hyperparameters.
        
        % Exogenous inputs in VARXs.
        XNames = cell(1,0) % Names of exogenous inputs.
        X0 = [ ] % Asymptotic mean assumption for exogenous inputs.
        J = [ ] % Coefficient matrix for exogenous inputs.
        
        % Conditioning instruments.
        INames = cell(1,0) % Names of conditioning instruments.
        IEqtn = cell(1,0) % Expressions for conditioning instruments.
        Zi = [ ] % Measurement matrix for conditioning instruments.
    end
    
    
    
    
    methods
        varargout = assign(varargin)
        varargout = acf(varargin)
        varargout = backward(varargin)
        varargout = companion(varargin)
        varargout = datarequest(varargin)
        varargout = demean(varargin)
        varargout = eig(varargin)
        varargout = estimate(varargin)
        varargout = ferf(varargin)
        varargout = filter(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = group(varargin)
        varargout = infocrit(varargin)
        varargout = instrument(varargin)
        varargout = integrate(varargin)
        varargout = iscompatible(varargin)
        varargout = isexplosive(varargin)
        varargout = isstationary(varargin)
        varargout = length(varargin)
        varargout = lrtest(varargin)
        varargout = mean(varargin)
        varargout = portest(varargin)
        varargout = resample(varargin)
        varargout = schur(varargin)
        varargout = simulate(varargin)
        varargout = sprintf(varargin)
        varargout = sspace(varargin)
        varargout = vma(varargin)
        varargout = xasymptote(varargin)
        varargout = xsf(varargin)
        varargout = subsref(varargin)
        varargout = subsasgn(varargin)
    end
    
    
    
    
    methods (Hidden)
        varargout = hdatainit(varargin)
        varargout = end(varargin)
        varargout = saveobj(varargin)
        varargout = implementGet(varargin)
        varargout = SVAR(varargin)
        varargout = myresponse(varargin)
        varargout = mysystem(varargin)
    end
    
    
    
    
    methods (Access=protected, Hidden)
        varargout = assignEst(varargin)
        varargout = getEstimationData(varargin)
        varargout = mycompatible(varargin)
        varargout = myglsqweights(varargin)
        varargout = myisvalidinpdata(varargin)
        varargout = myny(varargin)
        varargout = myprealloc(varargin)
        varargout = myrngcmp(varargin);
        varargout = subsalt(varargin)
        varargout = myxnames(varargin)
        varargout = size(varargin)
        varargout = specdisp(varargin)
        varargout = stackData(varargin)
    end
    
    
    
    
    methods (Static, Hidden)
        varargout = myglsq(varargin)
        varargout = restrict(varargin)
    end
    
    
    
    
    methods (Access=protected, Hidden)
        % Methods sealed in extension classes svarobj.
        varargout = mybmatrix(varargin)
        varargout = mycovmatrix(varargin)
    end

    
    
    
    methods
        function This = VAR(varargin)
            % VAR  Create new empty reduced-form VAR object.
            %
            %
            % Syntax for plain VAR and VAR with exogenous variables
            % ======================================================
            %
            %     V = VAR(YNames)
            %     V = VAR(YNames,'exogenous=',XNames)
            %
            %
            % Syntax for panel VAR and VAR with exogenous variables
            % ======================================================
            %
            %
            %     V = VAR(YNames,'groups=',GroupNames)
            %     V = VAR(YNames,'exogenous=',XNames,'groups=',GroupNames)
            %
            %
            % Output arguments
            % =================
            %
            % * `V` [ VAR ] - New empty VAR object.
            %
            % * `YNames` [ cellstr | char | function_handle ] - Names of endogenous variables.
            %
            % * `XNames` [ cellstr | char | function_handle ] - Names of exogenous inputs.
            %
            % * `GroupNames` [ cellstr | char | function_handle ] - Names of groups for
            % panel VAR estimation.
            %
            %
            % Options
            % ========
            %
            % * `'exogenous='` [ cellstr | *empty* ] - Names of exogenous regressors;
            % one of the names can be `!ttrend`, a linear time trend, which will be
            % created automatically each time input data are required, and then
            % included in the output database under the name `ttrend`.
            %
            % * `'groups='` [ cellstr | *empty* ] - Names of groups for panel VAR
            % estimation.
            %
            %
            % Description
            % ============
            %
            %
            % This function creates a new empty VAR object. It is usually followed by
            % an [`estimate`](VAR/estimate) command to estimate the coefficient
            % matrices in the VAR object using some data.
            %
            %
            % Example
            % ========
            %
            % To estimate a VAR, first create an empty VAR object specifying the
            % variable names, and then run the [VAR/estimate](VAR/estimate) function on
            % it, e.g.
            %
            %     v = VAR({'x','y','z'});
            %     [v,d] = estimate(v,d,range);
            %
            % where the input database `d` ought to contain time series `d.x`, `d.y`,
            % `d.z`.
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            %--------------------------------------------------------------------------
            
            This = This@varobj(varargin{:});
            
            if nargin==0
                return
            elseif nargin==1 && isVAR(varargin{1})
                This = varargin{1};
                return
            elseif nargin==1 && isstruct(varargin{1})
                This = struct2obj(This, varargin{1});
                return
            elseif nargin>=3
                % VAR(YNames,...)
                varargin(1) = [ ];
                [opt, ~] = passvalopt('VAR.VAR', varargin{:});
                if ~isempty(opt.exogenous)
                    This = myxnames(This, opt.exogenous);
                end
            end
        end
        
    end
    
end
