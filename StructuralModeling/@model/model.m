% Models
%
% This section describes the `Model` class of objects.
%
% Description
% ------------
%
% Model objects are created by loading a model file written in [IRIS Model
% File Language](ModelFileLanguage). Once a model object exists in the
% Matlab workspace, you can combine model functions and standard Matlab
% functions to work with it in your own m-files (scripts, functions, etc.):
% assign or estimate model parameters, run model simulations, calculate its
% stochastic properties, etc.
%
%
% model methods:
%
% Functions by Category
% ----------------------
%
% __Constructor__
%
%   model - Create new model object from model file
%
%
% __Getting Information about Models__
%
%   addparam - Add model parameters to a database
%   autocaption - Create captions for reporting model variables or parameters
%   autoexog - Get or set pairs of names in dynamic and steady autoexog
%   chkredundant - Check for redundant shocks and/or parameters
%   comment - Get or set user comments in an IRIS object
%   eig - Eigenvalues of the transition matrix
%   findeqtn - Find equations by their labels
%   findname - Find names of variables, shocks, or parameters by their labels
%   get - Query model object properties
%   isactive - True if dynamic link or steady-state revision is active (not disabled)
%   iscompatible - True if two models can occur together on the LHS and RHS in an assignment
%   islinear - True for models declared as linear
%   islog - True for log-linearised variables
%   ismissing - True if some initical conditions are missing from input database
%   isnan - Check for NaNs in model object
%   isname - True for valid names of variables, parameters, or shocks in model object
%   issolved - True if model solution exists
%   isstationary - True if model or specified combination of variables is stationary
%   length - Number of model variants
%   omega - Get or set the covariance matrix of shocks
%   sspace - State-space matrices describing the model solution
%   system - System matrices for unsolved model
%   userdata - Get or set user data in an IRIS object
%
%
% __Referencing Model Objects__
%
%   subsasgn - Subscripted assignment for model and systemfit objects
%   subsref - Subscripted reference for model and systemfit objects
%
%
% __Changing Model Objects__
%
%   alter - Expand or reduce number of model variants
%   assign - Assign parameters, steady states, std deviations or cross-correlations
%   disable - Disable dynamic links or steady-state revision equations
%   enable - Enable dynamic links or revision equations
%   export - Save all export files associated with model object to current working folder
%   horzcat - Merge two or more compatible model objects into multiple parameterizations
%   refresh - Refresh dynamic links
%   reset - Reset specific values within model object
%   stdscale - Rescale all std deviations by the same factor
%   set - Change settable model object property
%
%
% __Steady State__
%
%   blazer - Reorder dynamic or steady equations and variables into sequential block structure
%   chksstate - Check if equations hold for currently assigned steady-state values
%   sstate - Compute steady state or balance-growth path of the model
%
%
% __Solution, Simulation and Forecasting__
%
%   chkmissing - Check for missing initial values in simulation database
%   diffsrf - Differentiate shock response functions w.r.t. specified parameters
%   expand - Compute forward expansion of model solution for anticipated shocks
%   jforecast - Forecast with judgmental adjustments (conditional forecasts)
%   icrf - Initial-condition response functions, first-order solution only
%   lhsmrhs - Discrepancy between the LHS and RHS of each model equation for given data
%   resample - Resample from the model implied distribution
%   reporting - Evaluate reporting equations from within model object
%   shockplot - Short-cut for running and plotting plain shock simulation
%   simulate - Simulate model
%   solve - Calculate first-order accurate solution of the model
%   srf - Shock response functions, first-order solution only
%   tolerance - Get or set model-specific tolerance levels
%
%
% __Model Data__
%
%   data4lhsmrhs - Prepare data array for running `lhsmrhs`
%   emptydb - Create model database with empty time series for each variable and shock
%   shockdb - Create model-specific database with random shocks
%   sstatedb - Create model-specific steady-state or balanced-growth-path database
%   templatedb - Create model-specific template database
%   zerodb - Create model-specific zero-deviation database
%
%
% __Stochastic Properties__
%
%   acf - Autocovariance and autocorrelation function for model variables
%   ifrf - Frequency response function to shocks
%   fevd - Forecast error variance decomposition for model variables
%   ffrf - Filter frequency response function of transition variables to measurement variables
%   fmse - Forecast mean square error matrices
%   vma - Vector moving average representation of the model
%   xsf - Power spectrum and spectral density of model variables
%
%
% __Identification, Estimation and Filtering__
%
%   bn - Beveridge-Nelson trends
%   diffloglik - Approximate gradient and hessian of log-likelihood function
%   estimate - Estimate model parameters by optimising selected objective function
%   filter - Kalman smoother and estimator of out-of-likelihood parameters
%   fisher - Approximate Fisher information matrix in frequency domain
%   lognormal - Characteristics of log-normal distributions returned from filter of forecast
%   loglik - Evaluate minus the log-likelihood function in time or frequency domain
%   neighbourhood - Local behaviour of the objective function around the estimated parameters
%   regress - Centred population regression for selected model variables
%   VAR - Population VAR for selected model variables
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef model < shared.GetterSetter & shared.UserDataContainer & shared.Estimation
    
    properties (GetAccess=public, SetAccess=protected, Hidden)
        FileName = '' % File name of source model file.
        IsLinear = false % True for linear models.
        IsGrowth = false % True for models with nonzero deterministic growth in steady state.
        Tolerance = model.DEFAULT_TOLERANCE_STRUCT % Tolerance levels for different contexts.
        
        Reporting = rpteq( ) % Reporting equations.

        % Derivatives to system matrices conversion.
        d2s = [ ]

        % Matrices necessary to generate forward expansion of model solution.
        Expand = { }
        
        % Model state-space matrices T, R, K, Z, H, D, U, Y, ZZ.
        solution = repmat( {zeros(0, 0, 0)}, 1, 9 )

        Quantity = model.Quantity( ) % Variables, shocks, parameters.
        
        Equation = model.Equation( ) % Equations, dtrends, links, revisions
       
        Incidence = struct( ...
            'Dynamic', model.Incidence( ), ...
            'Steady',  model.Incidence( ), ...
            'Affected', model.Incidence( ) ...
            ) % Incidence matrices.
        
        Link = model.Link( ) % Dynamic links.

        Gradient = model.Gradient(0) % Automatic derivatives.
        
        Pairing = model.Pairing(0, 0) % Autoexog, Dtrend, Link, Revision, Assignment.
        
        PreparserControl = struct( ) % Preparser control parameters.
        
        Vector = model.Vector( ) % System and solution vectors.
        
        Variant = cell(1, 0) % Cell array of model.Variant objects with parameter dependent data.
        
        Behavior = model.Behavior( ) % Behavior control.

        Export = shared.Export.empty(1, 0) % Export files.
    end

    

    
    properties(GetAccess=public, SetAccess=protected, Hidden, Transient)
        % Handle to last derivatives and system matrices.
        LastSystem = model.LastSystem( )
    end

    

    
    properties (Constant, Hidden)
        LAST_LOADABLE = 20170317
        DEFAULT_SOLVE_TOLERANCE = eps( )^(5/9)
        DEFAULT_EIGEN_TOLERANCE = eps( )^(5/9)
        DEFAULT_STEADY_TOLERANCE = eps( )^(5/9)
        DEFAULT_SEVN2PATCH_TOLERANCE = eps( )^(5/9)
        DEFAULT_MSE_TOLERANCE = eps( )^(7/9)
        DEFAULT_DIFF_STEP = eps^(1/3)
        DEFAULT_TOLERANCE_STRUCT = struct( ...
            'Solve',     model.DEFAULT_SOLVE_TOLERANCE, ...
            'Eigen',     model.DEFAULT_EIGEN_TOLERANCE, ...
            'Steady',    model.DEFAULT_STEADY_TOLERANCE, ...
            'Mse',       model.DEFAULT_MSE_TOLERANCE, ...
            'DiffStep',  model.DEFAULT_DIFF_STEP, ...
            'Sevn2Patch', model.DEFAULT_SEVN2PATCH_TOLERANCE ...
            )
        DEFAULT_STEADY_EXOGENOUS = NaN;
        DEFAULT_STD_LINEAR = 1;
        DEFAULT_STD_NONLINEAR = log(1.01)
        RESERVED_NAME_TTREND = 'ttrend'
        COMMENT_TTREND = 'Time trend'
        STEADY_TTREND = 0 + 1i
        RESERVED_NAME_LINEAR = 'linear'
        CONTRIBUTION_INIT_CONST_DTREND = 'Init+Const+DTrend'
        CONTRIBUTION_NONLINEAR = 'Nonlinear'
        PREAMBLE_DYNAMIC = '@(x,t,L)'
        PREAMBLE_STEADY = '@(x,t)'
        PREAMBLE_DTREND = '@(x,t)'
        PREAMBLE_LINK = '@(x,t)'
        PREAMBLE_REVISION = '@(x,t)'
        PREAMBLE_HASH = '@(y,xi,e,p,t,L,T)'
        OBJ_FUN_PENALTY = 1e+10
    end
    
    
    methods
        varargout = acf(varargin)
        varargout = alter(varargin)
        varargout = altName(varargin)
        varargout = assign(varargin)
        varargout = assigned(varargin)
        varargout = autocaption(varargin)
        varargout = autoexog(varargin)
        varargout = autoexogenise(varargin)
        varargout = blazer(varargin)
        varargout = bn(varargin)
        varargout = chkmissing(varargin)
        varargout = chkredundant(varargin)
        varargout = chkpriors(varargin)                
        varargout = chksstate(varargin)
        varargout = data4lhsmrhs(varargin)
        varargout = diffloglik(varargin)
        varargout = diffsrf(varargin)
        varargout = eig(varargin)
        varargout = emptydb(varargin)        
        varargout = estimate(varargin)
        varargout = expand(varargin)
        varargout = export(varargin)
        varargout = fevd(varargin)
        varargout = ffrf(varargin)
        varargout = filter(varargin)
        varargout = findeqtn(varargin)
        varargout = fisher(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = horzcat(varargin)        
        varargout = icrf(varargin)
        varargout = ifrf(varargin)
        varargout = irf(varargin)
        varargout = isactive(varargin)
        varargout = iscompatible(varargin)
        varargout = islinear(varargin)
        varargout = islog(varargin)
        varargout = ismissing(varargin)
        varargout = isname(varargin)
        varargout = isnan(varargin)
        varargout = issolved(varargin)
        varargout = isstationary(varargin)
        varargout = jforecast(varargin)
        varargout = length(varargin)
        varargout = lhsmrhs(varargin)
        varargout = disable(varargin)
        varargout = loglik(varargin)
        varargout = lognormal(varargin)
        varargout = kalman(varargin)
        varargout = refresh(varargin)
        varargout = reporting(varargin)
        varargout = resample(varargin)
        varargout = reset(varargin)        
        varargout = set(varargin)
        varargout = shockdb(varargin)
        varargout = shockplot(varargin)
        varargout = simulate(varargin)
        varargout = solve(varargin)
        varargout = sprintf(varargin)
        varargout = srf(varargin)
        varargout = sspace(varargin)
        varargout = sstate(varargin)
        varargout = sstatedb(varargin)
        varargout = stdscale(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)        
        varargout = system(varargin)
        varargout = templatedb(varargin)
        varargout = tolerance(varargin)
        varargout = trollify(varargin)
        varargout = enable(varargin)
        varargout = VAR(varargin)
        varargout = vma(varargin)
        varargout = xsf(varargin)
        varargout = zerodb(varargin)
    end
    
    
    methods (Hidden)
        varargout = cat(varargin)        
        varargout = chkConsistency(varargin)
        varargout = createTrendArray(varargin)        
        varargout = evalDtrends(varargin)
        varargout = hdatainit(varargin)
        varargout = chkQty(varargin)
        varargout = kalmanFilter(varargin)        
        varargout = myfdlik(varargin)
        varargout = myfindsspacepos(varargin)
        varargout = myinfo4plan(varargin)
        varargout = datarequest(varargin)
        varargout = disp(varargin)
        varargout = end(varargin)
        varargout = getnonlinobj(varargin)
        varargout = objfunc(varargin)
        varargout = isempty(varargin)
        

        varargout = prepareBlazer(varargin)        
        varargout = prepareChkSteady(varargin)
        varargout = prepareGlobal(varargin)        
        varargout = prepareGrouping(varargin)
        varargout = prepareSolve(varargin)        
        varargout = prepareSteady(varargin)
        

        %varargout = saveobj(varargin)
        varargout = size(varargin)        
        varargout = sizeOfSolution(varargin)
        varargout = sspaceMatrices(varargin)
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        varargout = update(varargin)
        varargout = verifyEstimStruct(varargin)
        varargout = vertcat(varargin)


        function listOfAllNames = properties(this)
            listOfAllNames = [ ...
                this.Quantity.Name, ...
                getStdName(this.Quantity), ...
                getCorrName(this.Quantity), ...
                ];
        end
        

        function this = setp(this, prop, value)
            this.(prop) = value;
        end


        function value = getp(this, prop)
            value = this.(prop);
        end


        function varargout = lookup(this, varargin)
            [varargout{1:nargout}] = lookup(this.Quantity, varargin{:});
        end
    end
    
    
    methods (Access=protected, Hidden)
        varargout = affected(varargin)
        varargout = build(varargin)
        varargout = chkStructureAfter(varargin)
        varargout = chkStructureBefore(varargin)
        varargout = chkSyntax(varargin)
        varargout = createSourceDbase(varargin)
        varargout = diffFirstOrder(varargin)        
        varargout = file2model(varargin)        
        varargout = getXRange(varargin)
        varargout = kalmanFilterRegOutp(varargin)
        varargout = lp4yxe(varargin)
        varargout = myanchors(varargin)
        varargout = mychksstate(varargin)
        varargout = myd2s(varargin)
        varargout = mydiffloglik(varargin)
        varargout = myeqtn2afcn(varargin)
        varargout = myfind(varargin)
        varargout = myforecastswap(varargin)
        varargout = mysimulateper(varargin)
        varargout = operateLock(varargin)
        varargout = optimalPolicy(varargin)
        varargout = parseEstimStruct(varargin)
        varargout = populateTransient(varargin)
        varargout = postparse(varargin)
        varargout = prepareLoglik(varargin)
        varargout = prepareSimulate1(varargin)
        varargout = prepareSimulate2(varargin)
        varargout = printSolutionVector(varargin)
        varargout = responseFunction(varargin)
        varargout = simulateNonlinear(varargin)
        varargout = solveFail(varargin)
        varargout = solveFirstOrder(varargin)        
        varargout = steadyLinear(varargin)
        varargout = steadyNonlinear(varargin)
        varargout = subsalt(varargin)
        varargout = symbDiff(varargin)
        varargout = systemFirstOrder(varargin)
        varargout = varyStdCorr(varargin)

    end
    
    
    methods (Static)
        varargout = failed(varargin)
    end
    
    
    methods (Static, Hidden)
        varargout = appendData(varargin)
        varargout = createNonlinEqtn(varargin)
        varargout = myalias(varargin)        
        varargout = myexpand(varargin)
        varargout = myfourierdata(varargin)
        varargout = myoutoflik(varargin)
        varargout = loadobj(varargin)
    end
    
    
    % Constructor and dependent properties.
    methods
        function this = model(varargin)
            % model  Create new model object from model file.
            %
            % Syntax
            % =======
            %
            %     M = model(FName, ...)
            %     M = model(M, ...)
            %
            %
            % Input arguments
            % ================
            %
            % * `FName` [ char | cellstr ] - Name(s) of model file(s) that will be
            % loaded and converted to a new model object.
            %
            % * `M` [ model ] - Rebuild a new model object from an existing one; see
            % Description for when you may need this.
            %
            %
            % Output arguments
            % =================
            %
            % * `M` [ model ] - New model object based on the input model code file or
            % files.
            %
            %
            % Options
            % ========
            %
            % * `'Assign='` [ struct | *empty* ] - Assign model parameters and/or steady
            % states from this database at the time the model objects is being created.
            %
            % * `'AutoDeclareParameters='` [ `true` | *`false`* ] - If `true`, skip
            % parameter declaration in the model file, and determine the list of
            % parameters automatically as residual names found in equations but not
            % declared.
            %
            % * `'BaseYear='` [ numeric | *2000* ] - Base year for constructing
            % deterministic time trends.
            %
            % * `'Comment='` [ char | *empty* ] - Text comment attached to the model
            % object.
            %
            % * `'Epsilon='` [ numeric | *eps^(1/4)* ] - The minimum relative step size
            % for numerical differentiation.
            %
            % * `'Linear='` [ `true` | *`false`* ] - Indicate linear models.
            %
            % * `'MakeBkw='` [ *`@auto`* | `@all` | cellstr | char ] -
            % Variables included in the list will be made part of the
            % vector of backward-looking variables; `@auto` means
            % the variables that do not have any lag in model equations
            % will be put in the vector of forward-looking variables.
            %
            % * `'Multiple='` [ true | *false* ] - Allow each variable, shock, or
            % parameter name to be declared (and assigned) more than once in the model
            % file.
            %
            % * `'Optimal='` [ cellstr ] - Specify optimal policy options,
            % see below; only applies when the keyword
            % [`min`](modellang/min) is used in the model file.
            %
            % * `'OrderLinks='` [ *`true`* | `false` ] - Reorder !links so that they
            % can be executed sequentially.
            %
            % * `'RemoveLeads='` [ `true` | *`false`* ] - Remove all leads from the
            % state-space vector, keep included only current dates and lags.
            %
            % * `'SstateOnly='` [ `true` | *`false`* ] - Read in only the steady-state
            % versions of equations (if available).
            %
            % * `'Std='` [ numeric | `@auto` ] - Default standard deviation for model
            % shocks; `@auto` means `1` for linear models and `log(1.01)` for nonlinear
            % models.
            %
            % * `'UserData='` [ ... | *empty* ] - Attach user data to the model object.
            %
            %
            % Optimal policy options
            % =======================
            %
            % * `'MultiplierPrefix='` [ char | *`'Mu_'`* ] - Prefix used to
            % create names for lagrange multipliers associated with the
            % optimal policy problem; the prefix is followed by the
            % equation number.
            %
            % * `'Nonnegative='` [ cellstr ] - List of variables
            % constrained to be nonnegative.
            %
            % * `'Type='` [ `'commitment'` | *`'discretion'`* ] - Type of
            % optimal policy.
            %
            %
            % Description
            % ============
            %
            % Loading a model file
            % ---------------------
            %
            % The `model` function can be used to read in a [model
            % file](modellang/Contents) named `fname`, and create a model object `m`
            % based on the model file. You can then work with the model object in your
            % own m-files, using using the IRIS [model functions](model/Contents) and
            % standard Matlab functions.
            %
            % If `fname` is a cell array of more than one file names then all files are
            % combined together in order of appearance.
            %
            % Rebuilding an existing model object
            % ------------------------------------
            %
            % When calling the function `model` with an existing model object as the
            % first input argument, the model will be rebuilt from scratch. The typical
            % instance where you may need to call the constructor this way is changing
            % the `'removeLeads='` option. Alternatively, the new model object can be
            % simply rebuilt from the model file.
            %
            %
            % Example
            % ========
            %
            % Read in a model code file named `my.model`, and declare the model as
            % linear:
            %
            %     m = model('my.model', 'Linear=', true);
            %
            %
            % Example
            % ========
            %
            % Read in a model code file named `my.model`, declare the model as linear,
            % and assign some of the model parameters:
            %
            %     m = model('my.model', 'Linear=', true, 'Assign=', P);
            %
            % Note that this is equivalent to
            %
            %     m = model('my.model', 'Linear=', true);
            %     m = assign(m, P);
            %
            % unless some of the parameters passed in to the `model` fuction are needed
            % to evaluate [`if`](modellang/if) or [`!switch`](modellang/switch)
            % expressions.
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            %--------------------------------------------------------------------------
            
            opt = struct( );
            optimalOpt = struct( );
            
            if nargin==0
                % Empty model object.
                return
            elseif nargin==1 && isa(varargin{1}, 'model')
                % Copy model object.
                this = varargin{1};
            elseif nargin==1 && isstruct(varargin{1})
                % Convert struct (potentially based on old model object
                % syntax) to model object.
                this = struct2obj(this, varargin{1});
            elseif nargin>=1
                if ischar(varargin{1}) || iscellstr(varargin{1})
                    fileName = strtrim(varargin{1});
                    varargin(1) = [ ];
                    processOptions( );
                    this.IsLinear = opt.Linear;
                    this.IsGrowth = opt.Growth;
                    [this, opt] = file2model(this, fileName, opt, optimalOpt);
                    this = build(this, opt);
                elseif isa(varargin{1}, 'model')
                    this = varargin{1};
                    varargin(1) = [ ];
                    opt = processOptions( );
                    this = build(this, opt);
                end
            else
                utils.error('model:model', ...
                    'Incorrect number or type of input argument(s).');
            end
            
            return
            
            
            
            
            function processOptions( )
                [opt, varargin] = passvalopt('model.model', varargin{:});
                optimalOpt = passvalopt('model.optimal', opt.optimal);
                if ~isstruct(opt.Assign)
                    % Default for Assign= is an empty array.
                    opt.Assign = struct( );
                end
                opt.Assign.SteadyOnly = opt.sstateonly;
                opt.Assign.Linear = opt.Linear;
                % Bkw compatibility:
                opt.Assign.sstateonly = opt.sstateonly;
                opt.Assign.linear = opt.Linear;
                for iArg = 1 : 2 : length(varargin)
                    opt.Assign.(varargin{iArg}) = varargin{iArg+1};
                end
            end
        end
    end
end
