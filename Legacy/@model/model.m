classdef (InferiorClasses={?table, ?timetable}) ...
         model < iris.mixin.GetterSetter ...
               & iris.mixin.UserDataContainer ...
               & iris.mixin.CommentContainer ...
               & iris.mixin.Estimation ...
               & iris.mixin.LoadObjectAsStructWrapper ...
               & iris.mixin.DatabankPipe ...
               & iris.mixin.Kalman


    properties (GetAccess=public, SetAccess=protected)
        % FileName  Name of model file or files from which the model object was created
        FileName (1, :) string = string.empty(1, 0)

        % LinearStatus  True for models designated by user as linear
        LinearStatus (1, 1) logical = false
    end


    properties (GetAccess=public, SetAccess=protected, Hidden)
        % GrowthStatus  True for models with nonzero deterministic growth in steady state
        GrowthStatus (1, 1) logical = false

        % Tolerance  Tolerance levels for different contexts
        Tolerance = iris.mixin.Tolerance

        % Reporting  [Legacy] Reporting equations
        Reporting = rpteq( )

        % D2S  Derivatives to system matrices conversion
        D2S = model.D2S( )

        % Quantity  Container for model quantities (variables, shocks, parameters)
        Quantity = model.Quantity( )

        % Equation  Container for model equations (equations, dtreds, links)
        Equation = model.Equation( )

        % Incidence  Incidence matrices for dynamic and steady equations
        Incidence = struct( 'Dynamic', model.Incidence( ), ...
                            'Steady',  model.Incidence( ) )

        % Link  Dynamic links
        Link = model.Link.empty(0)

        % Gradient  Symbolic gradients of model equations
        Gradient = model.Gradient(0)


        % Pairing  Definition of pairs in autoswaps, measurement trends,
        % links, and assignment equations
        Pairing = model.Pairing(0, 0)

        % PreparserControl  Preparser control parameters
        PreparserControl = struct( )

        % Substitutions  Struct with substitution names and bodies
        Substitutions = struct( )

        % Vector  Vectors of variables in rows of system and solution matrices
        Vector = model.Vector( )

        % Variant  Parameter variant dependent properties
        Variant = model.Variant( )

        % Behavior  Settings to control behavior of model objects
        Behavior = model.Behavior( )

        % Export  Export files
        Export = iris.mixin.Export.empty(1, 0)

        % TaskSpecific  Not used any more
        TaskSpecific = [ ]

        PreallocateFunc
    end




    properties (GetAccess=public, SetAccess=protected, Hidden, Transient)
        % LastSystem  Handle to last derivatives and system matrices
        LastSystem = model.LastSystem( )

        % Affected  Logical array of equations affected by changes in parameters and steady-state values
        Affected = logical.empty(0)
    end




    properties (GetAccess=public, SetAccess=protected, Hidden)
        % Update  Temporary container for repeated updates of model solutions
        Update = model.EMPTY_UPDATE
    end




    properties (Constant, Hidden)
        LAST_LOADABLE = 20180116
        LEVEL_BOUNDS_ALLOWED  = [int8(1), int8(2), int8(4)]
        GROWTH_BOUNDS_ALLOWED = [int8(1), int8(2)]
        DEFAULT_STEADY_EXOGENOUS = NaN
        DEFAULT_STD_LINEAR = 1
        DEFAULT_STD_NONLINEAR = log(1.01)
        COMMENT_TTREND = 'Time trend'
        STEADY_TTREND = 0 + 1i
        CONTRIBUTION_INIT_CONST_DTREND = 'Init+Const+DTrend'
        CONTRIBUTION_NONLINEAR = 'Nonlinear'
        PREAMBLE_HASH = '@(y,xi,e,p,t,L,T)'
        EMPTY_UPDATE = struct( 'Values', [ ], ...
                               'StdCorr', [ ], ...
                               'PosOfValues', [ ], ...
                               'PosOfStdCorr', [ ], ...
                               'Solve', [ ], ...
                               'Steady', [ ], ...
                               'CheckSteady', [ ], ...
                               'NoSolution', [ ] );
    end




    properties % Legacy properties maintained to enable loadobj
        %(
        NumOfAppendables
        %)
    end




    methods
        varargout = addToDatabank(varargin)
        varargout = lookupNames(varargin)

        varargout = addparam(varargin)
        varargout = addplainparam(varargin)
        varargout = addstd(varargin)
        varargout = addcorr(varargin)
    end


    methods (Hidden) % Implement methods for @Kalman mixin
        varargout = getKalmanDataNames(varargin)
        varargout = getIthKalmanSystem(varargin)

        function stdcorr = getIthStdcorr(this, variantsRequested)
            stdcorr = getIthStdcorr(this.Variant, variantsRequested);
        end%

        function flag = hasLogVariables(this)
            flag = hasLogVariables(this.Quantity);
        end%

        varargout = getIthOmega(varargin)
    end


    methods
        varargout = acf(varargin)
        varargout = alter(varargin)
        varargout = altName(varargin)
        varargout = assign(varargin)
        varargout = assigned(varargin)
        varargout = autocaption(varargin)

        function varargout = autoswap(varargin)
            [varargout{1:nargout}] = autoswaps(varargin{:});
        end%

        varargout = autoswaps(varargin)
        varargout = beenSolved(varargin)
        varargout = blazer(varargin)
        varargout = bn(varargin)
        varargout = chkmissing(varargin)
        varargout = chkredundant(varargin)
        varargout = chkpriors(varargin)


        varargout = checkSteady(varargin)
        function varargout = chksstate(varargin)
            [flag, discrepancy, list] = checkSteady(varargin{:});
            if nargout<=2
                varargout = {flag, list};
            else
                varargout = {flag, discrepancy, list};
            end
        end%


        function value = countVariants(this)
            value = length(this.Variant);
        end%


        varargout = data4lhsmrhs(varargin)
        varargout = differentiate(varargin)
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

        function flag = hasGrowth(this)
            flag = this.GrowthStatus;
        end%

        varargout = horzcat(varargin)
        varargout = icrf(varargin)
        varargout = ifrf(varargin)
        varargout = irf(varargin)
        varargout = isLinkActive(varargin)
        varargout = testCompatible(varargin)
        varargout = islinear(varargin)
        varargout = islog(varargin)
        varargout = ismissing(varargin)
        varargout = isname(varargin)
        varargout = isnan(varargin)
        varargout = isstationary(varargin)
        varargout = jforecast(varargin)
        varargout = length(varargin)
        varargout = lhsmrhs(varargin)
        varargout = lp4lhsmrhs(varargin)
        varargout = deactivateLink(varargin)
        varargout = loglik(varargin)
        varargout = lognormal(varargin)
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
        function varargout = sstate(this, varargin)
            [varargout{1:nargout}] = steady(this, varargin{:});
        end%


        varargout = steadydb(varargin)
        function varargout = sstatedb(varargin)
            [varargout{1:nargout}] = steadydb(varargin{:});
        end%


        varargout = rescaleStd(varargin)
        varargout = stdscale(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = system(varargin)
        varargout = templatedb(varargin)
        varargout = tolerance(varargin)
        varargout = activateLink(varargin)
        varargout = VAR(varargin)
        varargout = varyStdCorr(varargin)
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

        function numEquations = countEquations(this)
            numEquations = countEquations(this.Equation);
        end%

        function numQuantities = countQuantities(this)
            numQuantities = countQuantities(this.Quantity);
        end%

        varargout = createHashEquations(varargin)
        varargout = createSourceDb(varargin)
        varargout = createTrendArray(varargin)
        varargout = evalTrendEquations(varargin)
        varargout = expansionMatrices(varargin)
        varargout = getStationaryStatus(varargin)


        function names = nameAppendables(this)
            names = getNamesByType(this.Quantity, 1, 2, 31, 32, 5);
        end%

        varargout = getVariant(varargin)

        varargout = hdatainit(varargin)
        varargout = insertTrendLine(varargin)
        varargout = freql(varargin)
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
        varargout = prepareZeroSteady(varargin)
        varargout = resolveAutoswap(varargin)


        %varargout = saveobj(varargin)
        varargout = size(varargin)
        varargout = sizeSolution(varargin)
        varargout = sizeSystem(varargin)
        varargout = getSolutionMatrices(varargin)


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
        function value = getPreallocateFunc(this)
            value = @nan;
        end%

        varargout = assignNameValue(varargin)
        varargout = affected(varargin)
        varargout = build(varargin)
        varargout = checkStructureAfter(varargin)
        varargout = checkStructureBefore(varargin)
        varargout = checkSyntax(varargin)
        varargout = createD2S(varargin)
        varargout = diffFirstOrder(varargin)
        varargout = file2model(varargin)
        implementDisp(varargin)
        varargout = kalmanFilterRegOutp(varargin)
        varargout = myanchors(varargin)
        varargout = mydiffloglik(varargin)
        varargout = functionsFromEquations(varargin)
        varargout = myfind(varargin)
        varargout = myforecastswap(varargin)
        varargout = swapForecast(varargin)
        varargout = operateActivationStatusOfLink(varargin)
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
        varargout = steadyUserFunc(varargin)
        varargout = systemFirstOrder(varargin)

        varargout = implementCheckSteady(varargin)

        varargout = prepareFreqlOptions(varargin)
        varargout = prepareSimulate1(varargin)
        varargout = prepareSimulate2(varargin)
    end


    methods (Static)
        varargout = failed(varargin)
    end


    methods (Static, Hidden)
        varargout = expandFirstOrder(varargin)
        varargout = myalias(varargin)
        varargout = fourierData(varargin)
        varargout = myoutoflik(varargin)
        varargout = loadobj(varargin)


        function flag = validateSolvedModel(input, maxNumVariants)
            if nargin<2
                maxNumVariants = Inf;
            end
            flag = isa(input, 'model') && ~isempty(input) && all(beenSolved(input)) ...
                && length(input)<=maxNumVariants;
        end%


        function flag = validateChksstate(input)
            flag = isequal(input, true) || isequal(input, false) ...
                || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateSolve(input)
            flag = isequal(input, true) || isequal(input, false) ...
                   || (iscell(input) && iscellstr(input(1:2:end)));
        end%


        function flag = validateSteady(input)
            flag = isequal(input, true) || isequal(input, false) || iscell(input);
        end%
    end


    methods % Constructor
        function this = model(varargin)
% model  Legacy model object; use Model (capitalized) instead
%
% Legacy [IrisToolbox] object
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

            if nargin==0
                return
            end

            exception.warning([
                "Deprecated"
                "Deprecated: The 'model' object is deprecated and wil removed in the future. "
                "Use the 'Model' object instead. "
            ]);


            if nargin==1 && isa(varargin{1}, 'model')
                this = varargin{1};
                return
            end

            if nargin==1 && isstruct(varargin{1})
                this = struct2obj(this, varargin{1});
                return
            end

            modelSource = varargin{1};
            varargin(1) = [ ];

            if ischar(modelSource) || isstring(modelSource) || iscellstr(modelSource)
                modelSource = ModelSource(modelSource, varargin{:});
            end

            [opt, parserOpt, optimalOpt] = this.processConstructorOptions(varargin{:});
            [this, opt] = file2model(this, modelSource, opt, opt.Preparser, parserOpt, optimalOpt);
            this = build(this, opt);
        end%
    end
end

