% Models
%
% This section describes the `Model` class of objects
%
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
% model methods:
%
%
% Categorical List 
% -----------------
%
% __Constructor__
%
%   model - Create new model object from model file
%
%
% __Getting Information about Models__
%
%   addToDatabank - Add model quantities to databank or create new databank
%   autocaption - Create captions for reporting model variables or parameters
%   autoexog - Get or set pairs of names in dynamic and steady autoexog
%   chkredundant - Check for redundant shocks and/or parameters
%   comment - Get or set user comments in an IRIS object
%   eig - Eigenvalues of model transition matrix
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
%   length - Number of parameter variants within model object
%   omega - Get or set the covariance matrix of shocks
%   sspace - State-space matrices describing the model solution
%   system - System matrices for unsolved model
%   userdata - Get or set user data in an IRIS object
%
%
% __Referencing Model Objects__
%
%   subsasgn - Subscripted assignment for model objects
%   subsref - Subscripted reference for model objects
%
%
% __Changing Model Objects__
%
%   alter - Expand or reduce number of parameter variants in model object
%   assign - Assign parameters, steady states, std deviations or cross-correlations
%   disable - Disable dynamic links or steady-state revision equations
%   enable - Enable dynamic links or revision equations
%   export - Save all export files associated with model object to current working folder
%   horzcat - Merge two or more compatible model objects into multiple parameterizations
%   refresh - Refresh dynamic links
%   reset - Reset specific values within model object
%   rename - Rename temporarily model quantities
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
%   srf - First-order shock response functions
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
%   xsf - Power spectrum and spectral density for model variables
%
%
% __Identification, Estimation and Filtering__
%
%   bn - Beveridge-Nelson trends
%   diffloglik - Approximate gradient and hessian of log-likelihood function
%   estimate - Estimate model parameters by optimizing selected objective function
%   filter - Kalman smoother and estimator of out-of-likelihood parameters
%   fisher - Approximate Fisher information matrix in frequency domain
%   lognormal - Characteristics of log-normal distributions returned from filter of forecast
%   loglik - Evaluate minus the log-likelihood function in time or frequency domain
%   neighbourhood - Local behaviour of the objective function around the estimated parameters
%   regress - Centred population regression for selected model variables
%   VAR - Population VAR for selected model variables
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

classdef (InferiorClasses={?table, ?timetable}) ...
         model < shared.GetterSetter ...
               & shared.UserDataContainer ...
               & shared.CommentContainer ...
               & shared.Estimation ...
               & shared.LoadObjectAsStructWrapper ...
               & model.Data ...
               & model.Plan

    properties (GetAccess=public, SetAccess=protected)
        % FileName  Name of model file or files from which the model object was created
        FileName = ''

        % IsLinear  True for models designated by user as linear
        IsLinear = false
    end


    properties (GetAccess=public, SetAccess=protected, Hidden)
        IsGrowth = false % True for models with nonzero deterministic growth in steady state
        Tolerance = model.DEFAULT_TOLERANCE_STRUCT % Tolerance levels for different contexts
        
        Reporting = rpteq( ) % Reporting equations

        D2S = model.component.D2S( )  % Conversion of derivatives to system matrices

        Quantity = model.component.Quantity( ) % Variables, shocks, parameters
        
        Equation = model.component.Equation( ) % Equations, dtrends, links, revisions
       
        % Incidence  Incidence matrices for dynamic and steady equations
        Incidence = struct( 'Dynamic', model.component.Incidence( ), ...
                            'Steady',  model.component.Incidence( ) ) 

        % Link  Dynamic links
        Link = model.component.Link( ) 

        % Gradient  Symbolic gradients of model equations
        Gradient = model.component.Gradient(0) 

        % Pairing  Definition of pairs in autoexog, dtrends, links, and assignment equations
        Pairing = model.component.Pairing(0, 0) 
        
        % PreparserControl  Preparser control parameters
        PreparserControl = struct( ) 
        
        % Substitutions  Struct with substitution names and bodies
        Substitutions = struct( )

        % Vector  Vectors of variables in rows of system and solution matrices
        Vector = model.component.Vector( ) 
        
        % Variant  Parameter variant dependent properties
        Variant = model.component.Variant( ) 
        
        % Behavior  Settings to control behavior of model objects
        Behavior = model.component.Behavior( ) 

        % Export  Export files
        Export = shared.Export.empty(1, 0)

        % TaskSpecific  Not used any more
        TaskSpecific = [ ]
    end

    
    properties (GetAccess=public, SetAccess=protected, Hidden, Transient)
        % LastSystem  Handle to last derivatives and system matrices
        LastSystem = model.component.LastSystem( )

        % Affected  Logical array of equations affected by changes in parameters and steady-state values
        Affected = logical.empty(0)
    end


    properties (GetAccess=public, SetAccess=protected, Hidden)
        % Update  Temporary container for repeated updates of model solutions
        Update = model.EMPTY_UPDATE
    end


    properties (Dependent)
        % NumOfVariants  Number of parameter variants
        NumOfVariants

        % NamesOfAppendablesInData  Variable names that can be appended pre-sample or post-sample database
        NamesOfAppendablesInData

        % NamesOfEndogenousInPlan  Names of variables that can be exogenized in simulation plan
        NamesOfEndogenousInPlan

        % NamesOExogenousInPlan  Names of variables that can be endogenized in simulation plan
        NamesOfExogenousInPlan
    end

    
    properties (Constant, Hidden)
        LAST_LOADABLE = 20180116
        STD_PREFIX = 'std_'
        CORR_PREFIX = 'corr_'
        LOG_PREFIX = 'log_'
        FLOOR_PREFIX = 'floor_'
        LEVEL_BOUNDS_ALLOWED  = [int8(1), int8(2), int8(4)]
        GROWTH_BOUNDS_ALLOWED = [int8(1), int8(2)]
        DEFAULT_SOLVE_TOLERANCE = eps( )^(5/9)
        DEFAULT_EIGEN_TOLERANCE = eps( )^(5/9)
        DEFAULT_SEVN2PATCH_TOLERANCE = eps( )^(5/9)
        DEFAULT_MSE_TOLERANCE = eps( )^(7/9)
        DEFAULT_STEADY_TOLERANCE = 1e-12
        DEFAULT_DIFF_STEP = eps^(1/3)
        DEFAULT_TOLERANCE_STRUCT = struct( ...
            'Solve',      model.DEFAULT_SOLVE_TOLERANCE, ...
            'Eigen',      model.DEFAULT_EIGEN_TOLERANCE, ...
            'Mse',        model.DEFAULT_MSE_TOLERANCE, ...
            'DiffStep',   model.DEFAULT_DIFF_STEP, ...
            'Sevn2Patch', model.DEFAULT_SEVN2PATCH_TOLERANCE, ...
            'Steady',     model.DEFAULT_STEADY_TOLERANCE ...
            )
        DEFAULT_STEADY_EXOGENOUS = NaN
        DEFAULT_STD_LINEAR = 1
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
        OBJ_FUNC_PENALTY = 1e+10
        EMPTY_UPDATE = struct( 'Values', [ ], ...
                               'StdCorr', [ ], ...
                               'PosOfValues', [ ], ...
                               'PosOfStdCorr', [ ], ...
                               'Solve', [ ], ...
                               'Steady', [ ], ...
                               'CheckSteady', [ ], ...
                               'NoSolution', [ ] );
    end
    
    
    methods
        varargout = addToDatabank(varargin)
        varargout = lookupNames(varargin)

        varargout = addparam(varargin)
        varargout = addplainparam(varargin)
        varargout = addstd(varargin)
        varargout = addcorr(varargin)

        varargout = getExtendedRange(varargin)
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
        varargout = getActualMinMaxShifts(varargin)
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
        varargout = jforecast_old(varargin)
        varargout = length(varargin)
        varargout = lhsmrhs(varargin)
        varargout = lp4lhsmrhs(varargin)
        varargout = disable(varargin)
        varargout = loglik(varargin)
        varargout = lognormal(varargin)
        varargout = kalman(varargin)
        varargout = refresh(varargin)
        varargout = rename(varargin)
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
        varargout = table(varargin)
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
        varargout = createHashEquations(varargin)
        varargout = createTrendArray(varargin)        
        varargout = evalDtrends(varargin)
        varargout = expansionMatrices(varargin)
        varargout = getIthOmega(varargin)
        varargout = getVariant(varargin)
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
        

        varargout = parseSimulateOptions(varargin)
        varargout = prepareBlazer(varargin)        
        varargout = prepareCheckSteady(varargin)
        varargout = prepareGrouping(varargin)
        varargout = preparePosteriorAndUpdate(varargin)
        varargout = prepareSolve(varargin)        
        varargout = prepareSteady(varargin)
        varargout = prepareSystemPriorWrapper(varargin)
        

        %varargout = saveobj(varargin)
        varargout = size(varargin)        
        varargout = sizeOfSolution(varargin)
        varargout = sspaceMatrices(varargin)
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        varargout = update(varargin)
        varargout = verifyEstimStruct(varargin)
        varargout = vertcat(varargin)


        function allNames = properties(this)
            allNames = [ this.Quantity.Name, ...
                         getStdNames(this.Quantity), ...
                         getCorrNames(this.Quantity) ];
        end%
        

        function this = setp(this, prop, value)
            this.(prop) = value;
        end%


        function value = getp(this, varargin)
            value = this.(varargin{1});
            varargin(1) = [ ];
            while ~isempty(varargin)
                value = value.(varargin{1});
                varargin(1) = [ ];
            end
        end%


        function varargout = getIndexByType(this, varargin)
            [varargout{1:nargout}] = getIndexByType(this.Quantity, varargin{:});
        end%


        function varargout = lookup(this, varargin)
            [varargout{1:nargout}] = lookup(this.Quantity, varargin{:});
        end%


        function n = numel(varargin)
            n = 1;
        end%


        function varargout = getIthFirstOrderSolution(this, variantsRequested)
            [varargout{1:nargout}] = ...
                getIthFirstOrderSolution(this.Variant, variantsRequested);
        end%


        function varargout = getIthIndexInitial(this, variantsRequested)
            [varargout{1:nargout}] = ...
                getIthIndexInitial(this.Variant, variantsRequested);
        end%


        function varargout = getIthFirstOrderExpansion(this, variantsRequested)
            [varargout{1:nargout}] = ... 
                getIthFirstOrderExpansion(this.Variant, variantsRequested);
        end%


        function x = getIthValues(this, variantsRequested)
            x = this.Variant.Values(:, :, variantsRequested);
        end%


        function x = getIthStdCorr(this, variantsRequested)
            x = this.Variant.StdCorr(:, :, variantsRequested);
        end%
    end
    
    
    methods (Access=protected, Hidden)
        varargout = affected(varargin)
        varargout = build(varargin)
        varargout = chkStructureAfter(varargin)
        varargout = chkStructureBefore(varargin)
        varargout = chkSyntax(varargin)
        varargout = createD2S(varargin)
        varargout = createSourceDbase(varargin)
        varargout = diffFirstOrder(varargin)        
        varargout = file2model(varargin)        
        varargout = kalmanFilterRegOutp(varargin)
        varargout = myanchors(varargin)
        varargout = checkSteady(varargin)
        varargout = mydiffloglik(varargin)
        varargout = myeqtn2afcn(varargin)
        varargout = myfind(varargin)
        varargout = myforecastswap(varargin)
        varargout = swapForecast(varargin)
        varargout = operateLock(varargin)
        varargout = optimalPolicy(varargin)
        varargout = populateTransient(varargin)
        varargout = postparse(varargin)
        varargout = prepareLoglik(varargin)
        varargout = prepareSimulate1(varargin)
        varargout = prepareSimulate2(varargin)
        varargout = printSolutionVector(varargin)
        varargout = reportNaNSolutions(varargin)
        varargout = responseFunction(varargin)
        varargout = solveFail(varargin)
        varargout = solveFirstOrder(varargin)        
        varargout = steadyLinear(varargin)
        varargout = steadyNonlinear(varargin)
        varargout = symbDiff(varargin)
        varargout = systemFirstOrder(varargin)
        varargout = varyStdCorr(varargin)
    end
    
    
    methods (Static)
        varargout = failed(varargin)
    end
    
    
    methods (Static, Hidden)
        varargout = expandFirstOrder(varargin)
        varargout = myalias(varargin)        
        varargout = myfourierdata(varargin)
        varargout = myoutoflik(varargin)
        varargout = loadobj(varargin)


        function flag = validateSolvedModel(input, maxNumOfVariants)
            if nargin<2
                numOfVariants = Inf;
            end
            flag = isa(input, 'model') && ~isempty(input) && all(issolved(input)) ...
                && length(input)<=maxNumOfVariants;
        end


        function flag = validateChksstate(input)
            flag = isequal(input, true) || isequal(input, false) ...
                || (iscell(input) && iscellstr(input(1:2:end)));
        end


        function flag = validateFilter(input)
            flag = isempty(input) || (iscell(input) && iscellstr(input(1:2:end)));
        end


        function flag = validateSolve(input)
            flag = isequal(input, true) || isequal(input, false) ...
                   || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateSstate(input)
            flag = isequal(input, true) || isequal(input, false) ...
                || (iscell(input) && iscellstr(input(1:2:end))) ...
                || isa(input, 'function_handle') ...
                || (iscell(input) && ~isempty(input) && isa(input{1}, 'function_handle'));
        end
    end
    
    
    % Constructor and dependent properties
    methods
        function this = model(varargin)
            % model  Create new model object from model file.
            %
            % __Syntax__
            %
            %     M = model(FileName, ...)
            %     M = model(ModelFile, ...)
            %     M = model(M, ...)
            %
            %
            % __Input Arguments__
            %
            % * `FileName` [ char | cellstr | string ] - Name(s) of model file(s)
            % that will be loaded and converted to a new model object.
            %
            % * `ModelFile` [ model.File ] - Object of model.File class.
            %
            % * `M` [ model ] - Rebuild a new model object from an existing one; see
            % Description for when you may need this.
            %
            %
            % __Output Arguments__
            %
            % * `M` [ model ] - New model object based on the input model code file or
            % files.
            %
            %
            % __Options__
            %
            % * `Assign=struct( )` [ struct | *empty* ] - Assign model parameters and/or steady
            % states from this database at the time the model objects is being created.
            %
            % * `AutoDeclareParameters=false` [ `true` | `false` ] - If `true`, skip
            % parameter declaration in the model file, and determine the list of
            % parameters automatically as residual names found in equations but not
            % declared.
            %
            % * `BaseYear=@config` [ numeric | `@config` ] - Base year for constructing
            % deterministic time trends; `@config` means the base year will
            % be read from iris configuration.
            %
            % * `Comment=''` [ char ] - Text comment attached to the model
            % object.
            %
            % * `Epsilon=eps^(1/4)` [ numeric ] - The minimum relative step
            % size for numerical differentiation.
            %
            % * `Linear=false` [ `true` | `false` ] - Indicate linear models.
            %
            % * `MakeBkw=@auto` [ `@auto` | `@all` | cellstr | char ] -
            % Variables included in the list will be made part of the
            % vector of backward-looking variables; `@auto` means
            % the variables that do not have any lag in model equations
            % will be put in the vector of forward-looking variables.
            %
            % * `AllowMultiple=false` [ true | false ] - Allow each variable, shock, or
            % parameter name to be declared (and assigned) more than once in the model
            % file.
            %
            % * `Optimal={ }` [ cellstr ] - Specify optimal policy options,
            % see below; only applies when the keyword
            % [`min`](irislang/min) is used in the model file.
            %
            % * `OrderLinks=true` [ `true` | `false` ] - Reorder `!links` so that they
            % can be executed sequentially.
            %
            % * `RemoveLeads=false` [ `true` | `false` ] - Remove all leads from the
            % state-space vector, keep included only current dates and lags.
            %
            % * `SstateOnly=false` [ `true` | `false` ] - Read in only the steady-state
            % versions of equations (if available).
            %
            % * `Std=@auto` [ numeric | `@auto` ] - Default standard deviation for model
            % shocks; `@auto` means `1` for linear models and `log(1.01)` for nonlinear
            % models.
            %
            % * `UserData=[ ]` [ ... ] - Attach user data to the model object.
            %
            %
            % __Options for Optimal Policy Models__
            %
            % The following options for optimal policy models need to be
            % nested within the `'Optimal='` option.
            %
            % * `MultiplierPrefix='Mu_'` [ char ] - Prefix used to
            % create names for lagrange multipliers associated with the
            % optimal policy problem; the prefix is followed by the
            % equation number.
            %
            % * `Nonnegative={ }` [ cellstr ] - List of variables
            % constrained to be nonnegative.
            %
            % * `Type='discretion'` [ `'commitment'` | `'discretion'` ] - Type of
            % optimal policy; `'discretion'` means leads (expectations) are
            % taken as given and not differentiated w.r.t. whereas
            % `'commitment'` means both lags and leads are differentiated
            % w.r.t.
            %
            %
            % __Description__
            %
            %
            % _Loading a Model File_
            %
            % The `model` function can be used to read in a [model
            % file](irislang/Contents) named `FileName`, and create a model object `M`
            % based on the model file. You can then work with the model object in your
            % own m-files, using using the IRIS [model functions](model/Contents) and
            % standard Matlab functions.
            %
            % If `FileName` is a cell array of more than one file names
            % then all files are combined together in order of appearance.
            %
            %
            % _Rebuilding an Existing Model Object_
            %
            % When calling the function `model` with an existing model object as the
            % first input argument, the model will be rebuilt from scratch. The typical
            % instance where you may need to call the constructor this way is changing
            % the `RemoveLeads=` option. Alternatively, the new model object can be
            % simply rebuilt from the model file.
            %
            %
            % __Example__
            %
            % Read in a model code file named `my.model`, and declare the model as
            % linear:
            %
            %     m = model('my.model', 'Linear=', true);
            %
            %
            % __Example__
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
            % to evaluate [`!if`](irislang/if) or [`!switch`](irislang/switch)
            % expressions.
            
            % -IRIS Macroeconomic Modeling Toolbox
            % -Copyright (c) 2007-2019 IRIS Solutions Team

            persistent inputParser optimalParser parserParser
            if isempty(inputParser)
                inputParser = extend.InputParser('model.model');
                inputParser.KeepUnmatched = true;
                inputParser.PartialMatching = false;
                inputParser.addParameter('addlead', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('Assign', [ ], @(x) isempty(x) || isstruct(x));
                inputParser.addParameter('chksyntax', true, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('comment', '', @ischar);
                inputParser.addParameter('Growth', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('optimal', cell.empty(1, 0), @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))));
                inputParser.addParameter('epsilon', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0 && x<1));
                inputParser.addParameter({'removeleads', 'removelead'}, false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('Linear', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x));
                inputParser.addParameter('OrderLinks', true, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter({'precision', 'double'}, @(x) ischar(x) && any(strcmp(x, {'double', 'single'})));
                inputParser.addParameter('Refresh', true, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('quadratic', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('saveas', '', @ischar);
                inputParser.addParameter({'symbdiff', 'symbolicdiff'}, true, @(x) isequal(x, true) || isequal(x, false) || ( iscell(x) && iscellstr(x(1:2:end)) ));
                inputParser.addParameter({'DefaultStd', 'Std'}, @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x>=0));
                inputParser.addParameter('stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
                inputParser.addParameter('stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
                inputParser.addParameter({'baseyear', 'torigin'}, @config, @(x) isequal(x, @config) || isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x)));
            end
            if isempty(parserParser)
                parserParser = extend.InputParser('model.model');
                parserParser.KeepUnmatched = true;
                parserParser.PartialMatching = false;
                parserParser.addParameter('AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false)); 
                parserParser.addParameter({'SteadyOnly', 'SstateOnly'}, false, @(x) isequal(x, true) || isequal(x, false));
                parserParser.addParameter({'AllowMultiple', 'Multiple'}, false, @(x) isequal(x, true) || isequal(x, false));
            end
            if isempty(optimalParser)
                optimalParser = extend.InputParser('model.model');
                optimalParser.KeepUnmatched = true;
                optimalParser.PartialMatching = false;
                optimalParser.addParameter('MultiplierPrefix', 'Mu_', @ischar);
                optimalParser.addParameter({'Floor', 'NonNegative'}, cell.empty(1, 0), @(x) isempty(x) || ( ischar(x) && isvarname(x) ));
                optimalParser.addParameter('Type', 'Discretion', @(x) ischar(x) && any(strcmpi(x, {'consistent', 'commitment', 'discretion'})));
            end
                
            %--------------------------------------------------------------------------
            
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
                if ischar(varargin{1}) || iscellstr(varargin{1}) || isa(varargin{1}, 'string') ...
                   || isa(varargin{1}, 'model.File')
                    modelFile = varargin{1};
                    varargin(1) = [ ];
                    [opt, parserOpt, optimalOpt] = processOptions( );
                    this.IsLinear = opt.Linear;
                    this.IsGrowth = opt.Growth;
                    [this, opt] = file2model(this, modelFile, opt, parserOpt, optimalOpt);
                    this = build(this, opt);
                elseif isa(varargin{1}, 'model')
                    this = varargin{1};
                    varargin(1) = [ ];
                    opt = processOptions( );
                    this = build(this, opt);
                end
            end
            
            return
            
            
            function [opt, parserOpt, optimalOpt] = processOptions( )
                inputParser.parse(varargin{:});
                opt = inputParser.Options;
                % Optimal policy options
                optimalParser.parse(opt.optimal{:});
                optimalOpt = optimalParser.Options;
                % IRIS parser options
                parserParser.parse(inputParser.UnmatchedInCell{:});
                parserOpt = parserParser.Options;
                % Control parameters
                unmatched = parserParser.UnmatchedInCell;
                if ~isstruct(opt.Assign)
                    % Default for Assign= is an empty array
                    opt.Assign = struct( );
                end
                opt.Assign.SteadyOnly = parserOpt.SteadyOnly;
                opt.Assign.Linear = opt.Linear;
                % Legacy options
                opt.Assign.sstateonly = opt.Assign.SteadyOnly;
                opt.Assign.linear = opt.Assign.Linear;
                for i = 1 : 2 : numel(unmatched)
                    opt.Assign.(unmatched{i}) = unmatched{i+1};
                end
            end%
        end


        function n = get.NumOfVariants(this)
            n = length(this);
        end%


        function names = get.NamesOfAppendablesInData(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(1), TYPE(2), TYPE(31), TYPE(32), TYPE(5));
        end%


        function names = get.NamesOfEndogenousInPlan(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(1), TYPE(2));
        end%


        function names = get.NamesOfExogenousInPlan(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(31), TYPE(32));
        end%
    end
end
