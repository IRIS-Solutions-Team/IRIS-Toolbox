classdef (InferiorClasses={?table, ?timetable}) ...
         model < shared.GetterSetter ...
               & shared.UserDataContainer ...
               & shared.CommentContainer ...
               & shared.Estimation ...
               & shared.LoadObjectAsStructWrapper ...
               & model.Data

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

        % Pairing  Definition of pairs in autoswaps, dtrends, links, and assignment equations
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

        % NamesOfAppendables  Variable names that can be appended pre-sample or post-sample database
        NamesOfAppendables
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

        varargout = autoswap(varargin)
        function varargout = autoexog(varargin)
            THIS_WARNING = { 'Model:LegacyFunctionName' 
                             'The function name autoexog(~) is obsolete and will be removed from a future version of IRIS; use autoswap(~) instead' };
            throw( exception.Base(THIS_WARNING, 'warning') );
            [varargout{1:nargout}] = autoswap(varargin{:});
        end%
        function output = autoexogenise(varargin)
            THIS_WARNING = { 'Model:LegacyFunctionNameForGPMN' 
                             'The function name autoexogenise(~) is obsolete and will be removed from a future version of IRIS; use autoswap(~) instead' };
            throw( exception.Base(THIS_WARNING, 'warning') );
            output = autoswap(varargin{:});
            output = output.Simulate;
        end%

        varargout = beenSolved(varargin)
        varargout = blazer(varargin)
        varargout = bn(varargin)
        varargout = chkmissing(varargin)
        varargout = chkredundant(varargin)
        varargout = chkpriors(varargin)                


        varargout = checkSteady(varargin)
        function varargout = chksstate(varargin)
            [varargout{1:nargout}] = checkSteady(varargin{:});
        end%


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


        varargout = steady(varargin)
        function varargout = sstate(varargin)
            [varargout{1:nargout}] = steady(varargin{:});
        end%


        varargout = steadydb(varargin)
        function varargout = sstatedb(varargin)
            [varargout{1:nargout}] = steadydb(varargin{:});
        end%


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


    methods
        function varargout = issolved(varargin)
            [varargout{1:nargout}] = beenSolved(varargin{:});
        end%
    end
    
    
    methods (Hidden)
        varargout = cat(varargin)        
        varargout = checkZeroLog(varargin)
        varargout = checkConsistency(varargin)
        varargout = chkQty(varargin)
        varargout = createHashEquations(varargin)
        varargout = createTrendArray(varargin)        
        varargout = evalTrendEquations(varargin)
        varargout = expansionMatrices(varargin)
        varargout = getIthOmega(varargin)
        varargout = getVariant(varargin)
        varargout = hdatainit(varargin)
        varargout = kalmanFilter(varargin)        
        varargout = myfdlik(varargin)
        varargout = myfindsspacepos(varargin)
        varargout = myinfo4plan(varargin)
        varargout = datarequest(varargin)


        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%


        varargout = end(varargin)
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
        varargout = checkSyntax(varargin)
        varargout = createD2S(varargin)
        varargout = createSourceDbase(varargin)
        varargout = diffFirstOrder(varargin)        
        varargout = file2model(varargin)        
        implementDisp(varargin)
        varargout = kalmanFilterRegOutp(varargin)
        varargout = myanchors(varargin)
        varargout = mydiffloglik(varargin)
        varargout = myeqtn2afcn(varargin)
        varargout = myfind(varargin)
        varargout = myforecastswap(varargin)
        varargout = swapForecast(varargin)
        varargout = operateLock(varargin)
        varargout = optimalPolicy(varargin)
        varargout = populateTransient(varargin)
        varargout = postparse(varargin)
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

        varargout = implementCheckSteady(varargin)

        varargout = prepareLoglik(varargin)
        varargout = prepareSimulate1(varargin)
        varargout = prepareSimulate2(varargin)
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
            flag = isa(input, 'model') && ~isempty(input) && all(beenSolved(input)) ...
                && length(input)<=maxNumOfVariants;
        end%


        function flag = validateChksstate(input)
            flag = isequal(input, true) || isequal(input, false) ...
                || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateFilter(input)
            flag = isempty(input) || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateSolve(input)
            flag = isequal(input, true) || isequal(input, false) ...
                   || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateSstate(input)
            flag = isequal(input, true) || isequal(input, false) ...
                || (iscell(input) && iscellstr(input(1:2:end))) ...
                || isa(input, 'function_handle') ...
                || (iscell(input) && ~isempty(input) && isa(input{1}, 'function_handle'));
        end%
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
% * `CheckSyntax=true` [ true | false ] - Perform syntax checks on model
% equations; setting `CheckSyntax=false` may help reduce load time for
% larger model objects (provided the model file is known to be free of
% syntax errors).
%
% * `Epsilon=eps^(1/4)` [ numeric ] - The minimum relative step
% size for numerical differentiation.
%
% * `Linear=false` [ `true` | `false` ] - Indicate linear models.
%
% * `MakeBkw=@auto` [ `@auto` | `@all` | cellstr | char ] - Variables
% included in the list will be made part of the vector of backward-looking
% variables; `@auto` means the variables that do not have any lag in model
% equations will be put in the vector of forward-looking variables.
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
                inputParser.addParameter('addlead', false, @validate.logicalScalar);
                inputParser.addParameter('Assign', [ ], @(x) isempty(x) || isstruct(x) || (iscell(x) && iscellstr(x(1:2:end))));
                inputParser.addParameter({'baseyear', 'torigin'}, @config, @(x) isequal(x, @config) || isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x)));
                inputParser.addParameter({'CheckSyntax', 'ChkSyntax'}, true, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('comment', '', @ischar);
                inputParser.addParameter({'DefaultStd', 'Std'}, @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x>=0));
                inputParser.addParameter('Growth', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('epsilon', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0 && x<1));
                inputParser.addParameter({'removeleads', 'removelead'}, false, @validate.logicalScalar);
                inputParser.addParameter('Linear', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x));
                inputParser.addParameter('optimal', cell.empty(1, 0), @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))));
                inputParser.addParameter('OrderLinks', true, @validate.logicalScalar);
                inputParser.addParameter({'precision', 'double'}, @(x) ischar(x) && any(strcmp(x, {'double', 'single'})));
                % inputParser.addParameter('quadratic', false, @(x) isequal(x, true) || isequal(x, false));
                inputParser.addParameter('Refresh', true, @validate.logicalScalar);
                inputParser.addParameter({'SavePreparsed', 'SaveAs'}, '', @ischar);
                inputParser.addParameter({'symbdiff', 'symbolicdiff'}, true, @(x) isequal(x, true) || isequal(x, false) || ( iscell(x) && iscellstr(x(1:2:end)) ));
                inputParser.addParameter('stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
                inputParser.addParameter('stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
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
                        if iscell(opt.Assign)
                            opt.Assign(1:2:end) = regexprep(opt.Assign(1:2:end), '\W', '');
                            newAssign = struct( );
                            for i = 1 : 2 : numel(opt.Assign)
                                name = opt.Assign{i};
                                value = opt.Assign{i+1};
                                newAssign.(name) = value;
                            end
                            opt.Assign = newAssign;
                        else
                            opt.Assign = struct( );
                        end
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
        end%


        function n = get.NumOfVariants(this)
            n = length(this);
        end%


        function names = get.NamesOfAppendables(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(1), TYPE(2), TYPE(31), TYPE(32), TYPE(5));
        end%
    end
end
