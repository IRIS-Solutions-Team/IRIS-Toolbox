classdef (InferiorClasses={?table, ?timetable}) ...
         model < shared.GetterSetter ...
               & shared.UserDataContainer ...
               & shared.CommentContainer ...
               & shared.Estimation ...
               & shared.LoadObjectAsStructWrapper ...
               & shared.DatabankPipe ...
               & shared.Kalman


    properties (GetAccess=public, SetAccess=protected)
        % FileName  Name of model file or files from which the model object was created
        FileName = ''

        % IsLinear  True for models designated by user as linear
        IsLinear = false
    end




    properties (GetAccess=public, SetAccess=protected, Hidden)
        % IsGrowth  True for models with nonzero deterministic growth in steady state
        IsGrowth = false 

        % Tolerance  Tolerance levels for different contexts
        Tolerance = shared.Tolerance 
        
        % Reporting  [Legacy] Reporting equations
        Reporting = rpteq( ) 

        % D2S  Derivatives to system matrices conversion
        D2S = model.component.D2S( ) 

        % Quantity  Container for model quantities (variables, shocks, parameters)
        Quantity = model.component.Quantity( )
        
        % Equation  Container for model equations (equations, dtreds, links)
        Equation = model.component.Equation( ) 
       
        % Incidence  Incidence matrices for dynamic and steady equations
        Incidence = struct( 'Dynamic', model.component.Incidence( ), ...
                            'Steady',  model.component.Incidence( ) ) 

        % Link  Dynamic links
        Link = model.component.Link.empty(0)

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
        PREAMBLE_DYNAMIC = '@(x,t,L)'
        PREAMBLE_STEADY = '@(x,t)'
        PREAMBLE_DTREND = '@(x,t)'
        PREAMBLE_LINK = '@(x,t)'
        PREAMBLE_REVISION = '@(x,t)'
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




    methods
        varargout = acf(varargin)
        varargout = alter(varargin)
        varargout = altName(varargin)
        varargout = assign(varargin)
        varargout = assigned(varargin)
        varargout = autocaption(varargin)

        varargout = autoswap(varargin)
        function varargout = autoexog(varargin)
            thisWarning = { 'Model:LegacyFunctionName' 
                            'The function name autoexog(~) is obsolete and will be removed from a future version of IRIS; use autoswap(~) instead' };
            throw(exception.Base(thisWarning, 'warning'));
            [varargout{1:nargout}] = autoswap(varargin{:});
        end%
        function output = autoexogenise(varargin)
            thisWarning = { 'Model:LegacyFunctionNameForGPMN' 
                            'The function name autoexogenise(~) is obsolete and will be removed from a future version of IRIS; use autoswap(~) instead' };
            throw(exception.Base(thisWarning, 'warning'));
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
            [flag, discrepancy, list] = checkSteady(varargin{:});
            if nargout<=2
                varargout = {flag, list};
            else
                varargout = {flag, discrepancy, list};
            end
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
        varargout = sstate(varargin)


        varargout = steadydb(varargin)
        function varargout = sstatedb(varargin)
            [varargout{1:nargout}] = steadydb(varargin{:});
        end%


        varargout = stdscale(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)        
        varargout = system(varargin)
        varargout = templatedb(varargin)
        varargout = tolerance(varargin)
        varargout = trollify(varargin)
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


        function value = countVariants(this)
            value = length(this.Variant);
        end%


        varargout = createHashEquations(varargin)
        varargout = createTrendArray(varargin)        
        varargout = evalTrendEquations(varargin)
        varargout = expansionMatrices(varargin)
        varargout = getIthOmega(varargin)
        varargout = getIthKalmanSystem(varargin)


        function names = nameAppendables(this)
            TYPE = @int8;
            names = getNamesByType(this.Quantity, TYPE(1), TYPE(2), TYPE(31), TYPE(32), TYPE(5));
        end%


        varargout = getVariant(varargin)
        varargout = hdatainit(varargin)
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
        

        %varargout = saveobj(varargin)
        varargout = size(varargin)        
        varargout = sizeOfSolution(varargin)
        varargout = sspaceMatrices(varargin)


        function stdcorr = getIthStdcorr(this, variantsRequested)
            stdcorr = getIthStdcorr(this.Variant, variantsRequested);
        end%


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
        varargout = assignNameValue(varargin)
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
        varargout = symbDiff(varargin)
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
                numOfVariants = Inf;
            end
            flag = isa(input, 'model') && ~isempty(input) && all(beenSolved(input)) ...
                && length(input)<=maxNumVariants;
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
    
    


    methods % Constructor
        function this = model(varargin)
% model  Legacy model object; use Model (capitalized) instead
%
% Legacy [IrisToolbox] object
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

            %( Input parser
            persistent pp ppOptimal ppParser
            if isempty(pp) || isempty(ppParser) || isempty(ppOptimal)
                pp = extend.InputParser('@Model');
                pp.KeepUnmatched = true;
                pp.PartialMatching = false;
                % addParameter(pp, 'addlead', false, @validate.logicalScalar);
                addParameter(pp, 'Assign', [ ], @(x) isempty(x) || isstruct(x) || validate.nestedOptions(x));
                addParameter(pp, {'baseyear', 'torigin'}, @config, @(x) isequal(x, @config) || isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x)));
                addParameter(pp, {'CheckSyntax', 'ChkSyntax'}, true, @(x) isequal(x, true) || isequal(x, false));
                addParameter(pp, 'comment', '', @ischar);
                addParameter(pp, {'DefaultStd', 'Std'}, @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x>=0));
                addParameter(pp, 'Growth', false, @(x) isequal(x, true) || isequal(x, false));
                addParameter(pp, 'epsilon', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0 && x<1));
                addParameter(pp, {'removeleads', 'removelead'}, false, @validate.logicalScalar);
                addParameter(pp, 'Linear', false, @(x) isequal(x, true) || isequal(x, false));
                addParameter(pp, 'makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x));
                addParameter(pp, 'Optimal', cell.empty(1, 0), @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))));
                addParameter(pp, 'OrderLinks', true, @validate.logicalScalar);
                addParameter(pp, {'precision', 'double'}, @(x) ischar(x) && any(strcmp(x, {'double', 'single'})));
                % addParameter(pp, ('quadratic', false, @(x) isequal(x, true) || isequal(x, false));
                addParameter(pp, 'Preparser', cell.empty(1, 0), @validate.nestedOptions);
                addParameter(pp, 'Refresh', true, @validate.logicalScalar);
                addParameter(pp, {'SavePreparsed', 'SaveAs'}, '', @validate.stringScalar);
                addParameter(pp, {'symbdiff', 'symbolicdiff'}, true, @(x) isequal(x, true) || isequal(x, false) || ( iscell(x) && iscellstr(x(1:2:end)) ));
                addParameter(pp, 'stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
                addParameter(pp, 'stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);


                ppParser = extend.InputParser('@Model');
                ppParser.KeepUnmatched = true;
                ppParser.PartialMatching = false;
                addParameter(ppParser, 'AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false)); 
                addParameter(ppParser, 'EquationSwitch', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'Dynamic', 'Steady'));
                addParameter(ppParser, {'SteadyOnly', 'SstateOnly'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
                addParameter(ppParser, {'AllowMultiple', 'Multiple'}, false, @(x) isequal(x, true) || isequal(x, false));


                ppOptimal = extend.InputParser('@Model');
                ppOptimal.KeepUnmatched = true;
                ppOptimal.PartialMatching = false;
                addParameter(ppOptimal, 'MultiplierPrefix', 'Mu_', @ischar);
                addParameter(ppOptimal, {'Floor', 'NonNegative'}, cell.empty(1, 0), @(x) isempty(x) || ( ischar(x) && isvarname(x) ));
                addParameter(ppOptimal, 'Type', 'Discretion', @(x) ischar(x) && any(strcmpi(x, {'consistent', 'commitment', 'discretion'})));
            end
            %)
                
            %--------------------------------------------------------------------------
            
            if nargin==0
                % Empty model object
                return
            elseif nargin==1 && isa(varargin{1}, 'model')
                % Copy model object
                this = varargin{1};
            elseif nargin==1 && isstruct(varargin{1})
                % Convert struct (potentially based on old model object
                % syntax) to model object
                this = struct2obj(this, varargin{1});
            elseif nargin>=1
                if ischar(varargin{1}) || iscellstr(varargin{1}) || isa(varargin{1}, 'string') ...
                   || isa(varargin{1}, 'model.File')
                    modelFile = varargin{1};
                    varargin(1) = [ ];
                    [opt, parserOpt, optimalOpt] = hereProcessOptions( );
                    this.IsLinear = opt.Linear;
                    this.IsGrowth = opt.Growth;
                    [this, opt] = file2model(this, modelFile, opt, opt.Preparser, parserOpt, optimalOpt);
                    this = build(this, opt);
                elseif isa(varargin{1}, 'model')
                    this = varargin{1};
                    varargin(1) = [ ];
                    opt = hereProcessOptions( );
                    this = build(this, opt);
                end
            end
            
            return
            
            
                function [opt, parserOpt, optimalOpt] = hereProcessOptions( )
                    parse(pp, varargin{:});
                    opt = pp.Options;

                    % Optimal policy options
                    optimalOpt = parse(ppOptimal, opt.Optimal{:});

                    % Parser options
                    parse(ppParser, pp.UnmatchedInCell{:});
                    parserOpt = ppParser.Options;
                    if isequal(parserOpt.EquationSwitch, @auto) && ~isequal(parserOpt.SteadyOnly, @auto)
                        % Legacy parser option
                        if isequal(parserOpt.SteadyOnly, true)
                            parserOpt.EquationSwitch = 'Steady';
                        end
                    end

                    % Control parameters
                    unmatched = ppParser.UnmatchedInCell;
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
    end
end
