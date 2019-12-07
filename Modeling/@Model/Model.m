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
%   iscompatible              - True if two models can occur together on the LHS and RHS in an assignment
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
% -Copyright (c) 2007-2019 IRIS Solutions Team


classdef Model ...
    < model ...
    & matlab.mixin.CustomDisplay ...
    & model.Plan ...
    & shared.DataProcessor


    methods % Constructor
        function this = Model(varargin)
% Model  Create Model object from source model files
%
% ## Syntax ##
%
%     m = Model(fileNames, ...)
%
%
% ## Input Arguments ##
%
% * `fileNames` [ char | cellstr | string ] - File name or a list of
% multiple file names of source model files from which the new model object
% will be created; multiple source model files are simply combined all
% together.
%
% 
% ## Output Arguments ##
%
% * `m` [ Model ] - New model object based on the source model file(s)
% specified in `fileNames`.
%
%
% ## Options ##
%
%
% ## Description ##
%
%
% ## Example ##
%
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

            this = this@model(varargin{:});
        end%
    end % methods


    methods % Public Interface
        varargout = changeLogStatus(varargin)
        varargout = get(varargin)
        varargout = simulate(varargin)
    end % methods


    methods (Access=protected) % Custom Display
        function groups = getPropertyGroups(this)
            x = struct( 'FileName', this.FileName, ...
                        'Comment', this.Comment, ...
                        'IsLinear', this.IsLinear, ...
                        'IsGrowth', this.IsGrowth, ...
                        'NumVariants', countVariants(this), ...
                        'NumVariantsSolved', countVariantsSolved(this), ...
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
    end % methods


    methods (Hidden) 
        varargout = checkCompatibilityOfPlan(varargin)
        varargout = checkInitialConditions(varargin)


        function value = countVariantsSolved(this)
            [~, inx] = isnan(this, 'Solution');
            value = nnz(~inx);
        end%


        varargout = getIdOfInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = simulateSelective(varargin)
        varargout = simulateStacked(varargin)
        varargout = simulateStatic(varargin)
        varargout = simulateTimeFrames(varargin)
    end % methods


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


        function value = getAutoswapPairsForPlan(this)
            pairingVector = this.Pairing.Autoswap.Simulate;
            [namesOfExogenized, namesOfEndogenized] = ...
                model.component.Pairing.getAutoswap(pairingVector, this.Quantity);
            value = [ namesOfExogenized(:), namesOfEndogenized(:) ];
        end%
    %)
    end
end % classdef

