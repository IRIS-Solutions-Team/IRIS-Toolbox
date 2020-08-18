% # Model Objects #
%
% Model objects (objects of class `Model`) are created from a model file.
% Model files are written in 
% [IRIS Model File Language](../model-file-language/README.md). 
% After a model object is created in the Matlab workspace, you can combine
% model functions and standard Matlab functions to work with it in your own
% m-files (scripts, functions, etc.): assign or estimate model parameters,
% run model simulations, calculate its stochastic properties, etc.
%
%
% Model methods:
%
% ## Summary of Model Functions by Category ##
%
% ### Constructor ###
% ------------------------------------------------------------------------------------------------------------
%   Model                     - Create Model object from source model files
%
%
% ### Getting Information about Model Objects ###
% ------------------------------------------------------------------------------------------------------------
%   addToDatabank             - Add model quantities to existing or new databank 
%   autocaption               - Create captions for reporting model variables or parameters
%   autoswap                  - Inquire about or assign autoswap pairs
%   beenSolved                - True if first-order solution has been successfully calculated
%   chkredundant              - Check for redundant shocks and/or parameters
%   comment                   - Get or set user comments in IRIS object
%   eig                       - Eigenvalues of model transition matrix
%   findeqtn                  - Find equations by their labels
%   findname                  - Find names of variables, shocks, or parameters by their labels
%   get                       - Query @Model object properties
%   isactive                  - True if dynamic link or steady-state revision is active (not disabled)
%   testCompatible              - True if two models can occur together on the LHS and RHS in an assignment
%   islinear                  - True for models declared as linear
%   islog                     - True for log-linearised variables
%   ismissing                 - True if some initical conditions are missing from input database
%   isnan                     - Check for NaNs in model object
%   isname                    - True for valid names of variables, parameters, or shocks in model object
%   isstationary              - True if model or specified combination of variables is stationary
%   length                    - Number of parameter variants within model object
%   changeLogStatus           - Change log status of model variables
%   omega                     - Get or set the covariance matrix of shocks
%   sspace                    - State-space matrices describing the model solution
%   system                    - System matrices for unsolved model
%   userdata                  - Get or set user data in an IRIS object
%
%
% ### Referencing Model Objects ###
% ------------------------------------------------------------------------------------------------------------
%   subsasgn                  - Subscripted assignment for model objects
%   subsref                   - Subscripted reference for model objects
%
%
% ### Changing Model Objects ###
% ------------------------------------------------------------------------------------------------------------
%   alter                     - Expand or reduce number of parameter variants in model object
%   assign                    - Assign parameters, steady states, std deviations or cross-correlations
%   disable                   - Disable dynamic links or steady-state revision equations
%   enable                    - Enable dynamic links or revision equations
%   export                    - Save all export files associated with model object to current working folder
%   horzcat                   - Merge two or more compatible model objects into multiple parameterizations
%   refresh                   - Refresh dynamic links
%   reset                     - Reset specific values within model object
%   rename                    - Rename temporarily model quantities
%   stdscale                  - Rescale all std deviations by the same factor
%   set                       - Change settable model object property
%
%
% ### Steady State ###
% ------------------------------------------------------------------------------------------------------------
%   blazer                    - Reorder dynamic or steady equations and variables into sequential block structure
%   checkSteady               - Check if equations hold for currently assigned steady-state values
%   steady                    - Compute steady state or balance-growth path of the model
%
%
% ### Solution, Simulation and Forecasting ###
% ------------------------------------------------------------------------------------------------------------
%   chkmissing                - Check for missing initial values in simulation database
%   diffsrf                   - Differentiate shock response functions w.r.t. specified parameters
%   expand                    - Compute forward expansion of model solution for anticipated shocks
%   jforecast                 - Forecast with judgmental adjustments (conditional forecasts)
%   icrf                      - Initial-condition response functions, first-order solution only
%   lhsmrhs                   - Discrepancy between the LHS and RHS of each model equation for given data
%   resample                  - Resample from the model implied distribution
%   reporting                 - Evaluate reporting equations from within model object
%   shockplot                 - Short-cut for running and plotting plain shock simulation
%   simulate                  - Simulate model
%   solve                     - Calculate first-order accurate solution of the model
%   srf                       - First-order shock response functions
%   tolerance                 - Get or set model-specific tolerance levels
%
%
% ### Model Data ###
% ------------------------------------------------------------------------------------------------------------
%   data4lhsmrhs              - Prepare data array for running `lhsmrhs`
%   emptydb                   - Create model database with empty time series for each variable and shock
%   shockdb                   - Create model-specific databank with random shocks
%   steadydb                  - Create model-specific steady-state or balanced-growth-path database
%   templatedb                - Create model-specific template database
%   zerodb                    - Create model-specific zero-deviation database
%
%
% ### Stochastic Properties ###
% ------------------------------------------------------------------------------------------------------------
%   acf                       - Autocovariance and autocorrelation function for model variables
%   ifrf                      - Frequency response function to shocks
%   fevd                      - Forecast error variance decomposition for model variables
%   ffrf                      - Filter frequency response function of transition variables to measurement variables
%   fmse                      - Forecast mean square error matrices
%   vma                       - Vector moving average representation of the model
%   xsf                       - Power spectrum and spectral density for model variables
%
%
% ### Identification, Estimation and Filtering ###
% ------------------------------------------------------------------------------------------------------------
%   bn                        - Beveridge-Nelson trends
%   diffloglik                - Approximate gradient and hessian of log-likelihood function
%   estimate                  - Estimate model parameters by optimizing selected objective function
%   filter                    - Kalman smoother and estimator of out-of-likelihood parameters
%   fisher                    - Approximate Fisher information matrix in frequency domain
%   lognormal                 - Characteristics of log-normal distributions returned from filter of forecast
%   loglik                    - Evaluate minus the log-likelihood function in time or frequency domain
%   neighbourhood             - Local behaviour of the objective function around the estimated parameters
%   regress                   - Centred population regression for selected model variables
%   VAR                       - Population VAR for selected model variables
%
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef Model ...
    < model ...
    & matlab.mixin.CustomDisplay ...
    & shared.Plan ...
    & shared.DataProcessor


    methods % Constructor
        function this = Model(varargin)
% model  Create new Model object from model file
%{
% ## Syntax ##
%
%
%     m = Model(fileName, ...)
%     m = Model(modelFile, ...)
%     m = Model(m, ...)
%
%
% ## Input Arguments ##
%
%
% __`fileName`__ [ char | cellstr | string ]
% >
% Name(s) of model file(s) that will be loaded and converted to a new model
% object.
%
%
% __`modelFile`__ [ model.File ]
% >
% Object of model.File class.
%
%
% __`m`__ [ Model ]
% >
% Rebuild a new model object from an existing one; see Description for when
% you may need this.
%
%
% ## Output Arguments ##
%
%
% __`M`__ [ model ]
% >
% New model object based on the input model code file or files.
%
%
% ## Options ##
%
%
% __`Assign=struct( )`__ [ struct | *empty* ]
% >
% Assign model parameters and/or steady states from this database at the
% time the model objects is being created.
%
%
% __`AutoDeclareParameters=false`__ [ `true` | `false` ]
% >
% If `true`, skip parameter declaration in the model file, and determine
% the list of parameters automatically as residual names found in equations
% but not declared.
%
%
% __`BaseYear=@config`__ [ numeric | `@config` ]
% >
% Base year for constructing deterministic time trends; `@config` means the
% base year will be read from iris configuration.
%
%
% __`Comment=''`__ [ char ]
% >
% Text comment attached to the model object.
%
%
% __`CheckSyntax=true`__ [ `true` | `false` ]
% >
% Perform syntax checks on model equations; setting `CheckSyntax=false` may
% help reduce load time for larger model objects (provided the model file
% is known to be free of syntax errors).
%
%
% __`Epsilon=eps^(1/4)`__ [ numeric ]
% >
% The minimum relative step size for numerical differentiation.
%
%
% __`Linear=false`__ [ `true` | `false` ]
% >
% Indicate linear models.
%
%
% __`MakeBkw=@auto`__ [ `@auto` | `@all` | cellstr | char ]
% >
% Variables included in the list will be made part of the vector of
% backward-looking variables; `@auto` means the variables that do not have
% any lag in model equations will be put in the vector of forward-looking
% variables.
%
%
% __`AllowMultiple=false`__ [ true | false ]
% >
% Allow each variable, shock, or parameter name to be declared (and
% assigned) more than once in the model file.
%
%
% __`Optimal={ }`__ [ cellstr ]
% >
% Specify optimal policy options, see below; only applies when the keyword
% [`min`](irislang/min) is used in the model file.
%
%
% __`OrderLinks=true`__ [ `true` | `false` ]
% >
% Reorder `!links` so that they can be executed sequentially.
%
%
% __`RemoveLeads=false`__ [ `true` | `false` ]
% >
% Remove all leads (aka forward-looking variables) from the state-space
% vector and keep included only current dates and lags; the leads are not a
% necessary part of the model solution and can dropped e.g. for memory
% efficiency reasons in larger model objects.
%
%
% __`SteadyOnly=false`__ [ `true` | `false` ]
% >
% Read in only the steady-state versions of equations (if available).
%
%
% __`Std=@auto`__ [ numeric | `@auto` ]
% >
% Default standard deviation for model shocks; `@auto` means `1` for linear
% models and `log(1.01)` for nonlinear models.
%
%
% __`UserData=[ ]`__ [ ... ]
% >
% Attach user data to the model object.
%
%
% ## Options for Optimal Policy Models ##
%
%
% The following options for optimal policy models need to be
% nested within the `'Optimal='` option.
%
%
% __`MultiplierPrefix='Mu_'`__ [ char ]
% >
% Prefix used to create names for lagrange multipliers associated with the
% optimal policy problem; the prefix is followed by the equation number.
%
%
% __`Nonnegative={ }`__ [ cellstr ]
% >
% List of variables
% constrained to be nonnegative.
%
%
% __`Type='discretion'`__ [ `'commitment'` | `'discretion'` ]
% >
% Type of optimal policy; `'discretion'` means leads (expectations) are
% taken as given and not differentiated w.r.t. whereas `'commitment'` means
% both lags and leads are differentiated w.r.t.
%
%
% ## Description ##
%
%
% ### Loading a Model File ###
%
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
% ### Rebuilding an Existing Model Object ###
%
%
% When calling the function `model` with an existing model object as the
% first input argument, the model will be rebuilt from scratch. The typical
% instance where you may need to call the constructor this way is changing
% the `RemoveLeads=` option. Alternatively, the new model object can be
% simply rebuilt from the model file.
%
%
% ## Example ##
%
%
% Read in a model code file named `my.model`, and declare the model as
% linear:
%
%     m = Model('my.model', 'Linear=', true);
%
%
% ## Example ##
%
%
% Read in a model code file named `my.model`, declare the model as linear,
% and assign some of the model parameters:
%
%     m = Model('my.model', 'Linear=', true, 'Assign=', P);
%
% Note that this is equivalent to
%
%     m = Model('my.model', 'Linear=', true);
%     m = assign(m, P);
%
% unless some of the parameters passed in to the `model` fuction are needed
% to evaluate [`!if`](irislang/if) or [`!switch`](irislang/switch)
% expressions.
%}

%--------------------------------------------------------------------------

            this = this@model(varargin{:});
        end%
    end % methods


    methods % Public Interface
        %(
        varargout = equationStartsWith(varargin)
        varargout = changeLogStatus(varargin)
        varargout = simulate(varargin)
        varargout = table(varargin)
        %)
    end % methods


    methods (Access=protected) % Custom Display
        %(
        function groups = getPropertyGroups(this)
            x = struct( 'FileName', this.FileName, ...
                        'Comment', this.Comment, ...
                        'IsLinear', this.IsLinear, ...
                        'IsGrowth', this.IsGrowth, ...
                        'NumOfVariants', countVariants(this), ...
                        'NumOfVariantsSolved', countVariantsSolved(this), ...
                        'NumOfMeasurementEquations', this.NumOfMeasurementEquations, ...
                        'NumOfTransitionEquations', this.NumOfTransitionEquations, ... 
                        'SizeOfTransitionMatrix', this.SizeOfTransitionMatrix, ...
                        'NumOfExportFiles', this.NumOfExportFiles, ...
                        'UserData', this.UserData );
            groups = matlab.mixin.util.PropertyGroup(x);
        end% 


        function displayScalarObject(this)
            groups = getPropertyGroups(this);
            disp(getHeader(this));
            disp(groups.PropertyList);
        end%


        function displayNonScalarObject(this)
            displayScalarObject(this);
        end%


        function header = getHeader(this)
            dimString = matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
            adjective = ' ';
            if isempty(this)
                adjective = [adjective, 'Empty '];
            end
            if this.IsLinear
                adjective = [adjective, 'Linear'];
            else
                adjective = [adjective, 'Nonlinear'];
            end
            header = ['  ', dimString, adjective, ' ', className, sprintf('\n')]; 
        end%
        %)
    end % methods


    methods (Hidden) 
        varargout = checkInitialConditions(varargin)


        function value = countVariantsSolved(this)
            [~, inx] = isnan(this, 'Solution');
            value = nnz(~inx);
        end%


        varargout = getIdOfInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = implementGet(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = prepareLinearSystem(varargin)
        varargout = simulateFrames(varargin)
    end % methods




    methods (Access=protected, Hidden)
        varargout = varyParams(varargin)
    end % methods



    methods (Static, Hidden) % Simulation methods
        %(
        varargout = simulateFirstOrder(varargin)
        varargout = simulateSelective(varargin)
        varargout = simulateStacked(varargin)
        varargout = simulateStatic(varargin)
        varargout = simulateNone(varargin)
        varargout = splitIntoFrames(varargin)
        %)
    end


    properties (Dependent)
        NumOfMeasurementEquations
        NumOfTransitionEquations
        SizeOfTransitionMatrix

        % NumOfExportFiles  Number of export files
        NumOfExportFiles
    end % properties


    methods
        function value = get.NumOfMeasurementEquations(this)
            TYPE = @int8;
            value = nnz(this.Equation.Type==TYPE(1));
        end%


        function value = get.NumOfTransitionEquations(this)
            TYPE = @int8;
            value = nnz(this.Equation.Type==TYPE(2));
        end%


        function value = get.SizeOfTransitionMatrix(this)
            [~, nxi, nb] = sizeOfSolution(this);
            value = [nxi, nb];
        end%


        function value = get.NumOfExportFiles(this)
            value = numel(this.Export);
        end%
    end




    methods (Access=protected) % mixin.Plan interface
    %(
        function names = getEndogenousForPlan(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(1), TYPE(2));
        end%


        function names = getExogenousForPlan(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(31), TYPE(32));
        end%


        function value = getAutoswapsForPlan(this)
            pairingVector = this.Pairing.Autoswap.Simulate;
            [namesOfExogenized, namesOfEndogenized] = ...
                model.component.Pairing.getAutoswap(pairingVector, this.Quantity);
            value = [ namesOfExogenized(:), namesOfEndogenized(:) ];
        end%


        function sigmas = getSigmasForPlan(this)
            TYPE = @int8;
            ne = nnz(getIndexByType(this.Quantity, TYPE(31), TYPE(32)));
            sigmas = this.Variant.StdCorr(:, 1:ne, :);
            sigmas = reshape(sigmas, ne, 1, [ ]);
        end%
    %)
    end
end % classdef

