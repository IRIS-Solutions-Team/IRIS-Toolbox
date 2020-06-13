function [outputData, exitFlag, finalAddf, finalDcy] = simulate(this, inputData, range, varargin)
% simulate  Simulate model
%
% __Syntax__
%
%     S = simulate(M, D, Range, ...)
%     [S, ExitFlag, AddF, Delta] = simulate(M, D, Range, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Solved model object.
%
% * `D` [ struct | cell ] - Input database or datapack from which the
% initial conditions and shocks from within the simulation range will be
% read.
%
% * `Range` [ numeric | char ] - Simulation range.
%
%
% __Output Arguments__
%
% * `S` [ struct | cell ] - Database with simulation results.
%
%
% __Output Arguments in Nonlinear Simulations__
%
% * `ExitFlag` [ cell | empty ] - Cell array with exit flags for
% nonlinearised simulations.
%
% * `AddF` [ cell | empty ] - Cell array of time series with final add-factors
% added to first-order approximate equations to make nonlinear equations
% hold.
%
% * `Delta` [ cell | empty ] - Cell array of time series with final
% discrepancies between LHS and RHS in equations marked for nonlinear
% simulations by a double-equal sign.
%
%
% __Options__
%
% * `Anticipate=true` [ `true` | `false` ] - If `true`, real future shocks
% are anticipated, imaginary are unanticipated; vice versa if `false`.
%
% * `'AppendPresample=false` [ `true` | `false` ] - Append data from
% periods preceding the simulation start date found in the input database
% to the output time series.
%
% * `Contributions=false` [ `true` | `false` ] - Decompose the simulated
% paths into contributions of individual shocks.
%
% * `DbOverlay=false` [ `true` | `false` | struct ] - Use the function
% `DbOverlay` to combine the simulated output data with the input database, 
% (or a user-supplied database); both the data preceeding the simulation
% range and after the simulation range are appended.
%
% * `Deviation=false` [ `true` | `false` ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `DTrends=@auto` [ `@auto` | `true` | `false` ] - Add deterministic
% trends to measurement variables; `@auto` means the deterministic trends
% will be added if `Deviation=false`.
%
% * `IgnoreShocks=false` [ `true` | `false` ] - Read only initial
% conditions from input data, and ignore any shocks within the simulation
% range.
%
% * `Method='FirstOrder'` [ `'FirstOrder'` | `'Selective'` ] -
% Method of running simulations; `'FirstOrder'` means first-order
% approximate solution (calculated around steady state); `'Selective'`
% means equation-selective nonlinear method.
%
% * `Plan=[ ]` [ Scenario | empty ] - Specify scenario to swap endogeneity
% and exogeneity of some variables and shocks temporarily, and/or to
% simulate some nonlinear equations.
%
% * `Progress=false` [ `true` | `false` ] - Display progress bar in the
% command window.
%
% * `SparseShocks=false` [ `true` | `false` ] - Store anticipated shocks
% (including endogenized anticipated shocks) in sparse array.
%
%
% __Options for Equation-Selective Nonlinear Simulations__
%
% * `Solver=@qad` [ `@qad` | `@fsolve` | `@lsqnonlin` ] - Solution
% algorithm; see Description.
%
% * `MaxNumelJv=1e6` [ numeric ] - Maximum number of data points (nonlinear
% plus exogenized) allowed for a nonrecursive algorithm in the nonlinear
% equation updating step; if exceeded, a recursive (period-by-period)
% simulation is used to update nonlinear equations instead.
%
% * `NonlinWindow=@all` [ numeric  - Time window (number of periods from
% the beginning of the simulation, and from the beginning of each
% simulation segment) over which nonlinearities will be preserved; the
% remaining periods will be simulated using first-order approximate
% solution.
%
%
% __Options for Equation-selective Nonlinear Simulations with @qad Solver__
%
% * `AddSstate=true` [ `true` | `false` ] - Add steady state levels to
% simulated paths before evaluating nonlinear equations; this option is
% used only if `Deviation=true`.
%
% * `Display=true` [ `true` | `false` | numeric | `Inf` ] - Report iterations
% on the screen; if `Display=N`, report every `N` iterations; if
% `Display=Inf`, report only the final iteration.
%
% * `Error=false` [ `true` | `false` ] - Throw an error whenever a
% nonlinear simulation fails converge; if `false`, only an warning will
% display.
%
% * `Lambda=1` [ numeric | `1` ] - Initial step size (between `0` and `1`)
% for add factors added to nonlinearised equations in every iteration; see
% also `NOptimLambda=`.
%
% * `NOptimLambda=1` [ numeric | `false` ] - Find the optimal step
% size on a grid of 10 points between 0 and `Lambda=` before each of the
% first `NOptimLambda=` iterations; if `false`, the value assigned to
% `Lambda` is used and no grid search is performed.
%
% * `ReduceLambda=0.5` [ numeric ] - Reduction factor (between `0` and `1`)
% by which `Lambda` will be multiplied if the nonlinear simulation gets on
% an divergence path.
%
% * `UpperBound=1.5` [ numeric ] - Multiple of all-iteration minimum
% achieved that triggers a reversion to that iteration and a reduciton in
% `Lambda`.
%
% * `MaxIter=100` [ numeric ] - Maximum number of iterations.
%
% * `Tolerance=1e-5` [ numeric ] - Convergence tolerance.
%
%
% __Options for Nonlinear Simulations with Optim Tbx Solver__
%
% * `OptimSet=[ ]` [ cell | struct | empty ] - Optimization Tbx options.
%
%
% __Description__
%
% The function `simulate( )` simulates a model on the specified
% simulation range. By default, the simulation is based on a first-order
% approximate solution (calculated around steady state). To run nonlinear
% simulations, use the option `Nonlinear=` (to set the number of periods
%
% _Output Range_
%
% Time series in the output database, `S`, are are defined on the
% simulation range, `Range`, plus include all necessary initial conditions, 
% ie. lags of variables that occur in the model code. You can use the
% option `DbOverlay=` to combine the output database with the input
% database (ie. to include a longer history of data in the simulated
% series).
%
%
% _Deviations from Steady-State and Deterministic Trends_
%
% By default, both the input database, `D`, and the output database, `S`, 
% are in full levels and the simulated paths for measurement variables
% include the effect of deterministic trends, including possibly exogenous
% variables. The default behavior can be changed by changing the options
% `Deviation=` and `DTrends=`.
%
% The default value for `Deviation=` is false. If set to `true`, then the
% input database is expected to contain data in the form of deviations from
% their steady state levels or paths. For ordinary variables (ie. variables
% whose log status is `false`), it is \(x_t-\bar x_t\), meaning that a 0
% indicates that the variable is at its steady state and e.g. 2 indicates
% the variables exceeds its steady state by 2. For log variables (ie.
% variables whose log status is `true`), it is \(x_t/\bar x_t\), meaning that
% a 1 indicates that the variable is at its steady state and e.g. 1.05
% indicates that the variable is 5 per cent above its steady state.
%
% The default value for `DTrends=` is `@auto`. This means that its
% behavior depends on the option `Deviation=`. If `Deviation=false`
% then deterministic trends are added to measurement variables, unless you
% manually override this behavior by setting `DTrends=false`.  On the
% other hand, if `Deviation=true` then deterministic trends are not
% added to measurement variables, unless you manually override this
% behavior by setting `DTrends=true`.
%
%
% _Simulating Contributions of Shocks_
%
% Use the option `Contributions=true` to request the contributions of
% shocks to the simulated path for each variable; this option cannot be
% used in models with multiple alternative parameterizations or with
% multiple input data sets.
%
% The output database, `s`, contains Ne+2 columns for each variable, where
% Ne is the number of shocks in the model:
%
% * the first columns 1...Ne are the
% contributions of the Ne individual shocks to the respective variable;
%
% * column Ne+1 is the contribution of initial condition, th econstant, and
% deterministic trends, including possibly exogenous variables;
%
% * column Ne+2 is the contribution of nonlinearities in nonlinear
% simulations (it is always zero otherwise).
%
% The contributions are additive for ordinary variables (ie. variables
% whose log status is `false`), and multplicative for log variables (ie.
% variables whose log status is `true`). In other words, if `S` is the
% output database from a simulation with `Contributions=true`, `X` is an
% ordinary variable, and `Z` is a log variable, then
%
%     sum(s.X, 2)
%
% (ie. the sum of all Ne+2 contributions in each period, ie. summation goes
% across 2nd dimension) reproduces the final simulated path for the
% variable `X`, whereas
%
%     prod(s.Z, 2)
%
% (ie. the product of all Ne+2 contributions) reproduces the final
% simulated path for the variable `Z`.
%
%
% _Simulations with Multiple Parameter Variants and/or Multiple Input Data Sets_
%
% If you simulate a model with `N` parameterisations and the input database
% contains `K` data sets (ie. each variable is a time series with `K`
% columns), then the following happens:
%
% * The model will be simulated a total of `P = max(N, K)` number of times.
% This means that each variables in the output database will have `P`
% columns.
%
% * The 1st parameterisation will be simulated using the 1st data set, the
% 2nd parameterisation will be simulated using the 2nd data set, etc. until
% you reach either the last parameterisation or the last data set, ie.
% \(min(N, K)\). From that point on, the last parameterisation or the last
% data set will be simply repeated (re-used) in the remaining simulations.
%
% * Formally, the \(i\)-th column in the output database is the
% simulation of the \(p\)-th parameter variant where \(p=min(i, n)\) using the 
% the \(s\)-th data set where \(s=min(i, k)\).
%
%
% _Equation-Selective Nonlinear Simulations_
%
% The equation-selective nonlinear simulation approach is invoked by
% setting `Method='Selective'`. In equation-selective nonlinear
% simulations, the solver tries to find add-factors to user-selected
% nonlinear equations (ie. equations with `=#` instead of the equal sign in
% the model file) in the first-order solution such that the original
% nonlinear equations hold for simulated trajectories (with expectations
% replaced with actual leads).
%
% Two numerical approaches are available, controlled by the option
% `Solver=`:
%
% * `'QaD'` - a quick-and-dirty, but less robust method (default);
%
% * `@fsolve`, `@lsqnonlin` - which are standard Optimization Tbx routines, 
% slower but likely to converge for a wider variety of simulations.
%
%
% Optimization Tbx routines: `@fsolve` or `@lsqnonlin` (default).
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.simulate');
    parser.addRequired('M', @(x) isa(x, 'model') && ~isempty(x) && all(beenSolved(x)));
    parser.addRequired('D', @isstruct);
    parser.addRequired('Range', @(x) DateWrapper.validateProperRangeInput(x));
end
parser.parse(this, inputData, range);
[opt, legacyOpt] = parseSimulateOptions(this, varargin{:});

range = range(1) : range(end);

% Convert plain numeric range into DateWrapper range
if ~isa(range, 'DateWrapper')
    range = DateWrapper(range);
end

% Conditional simulation
isCond = isa(opt.Plan, 'plan') && ~isempty(opt.Plan, 'cond');
if isCond
    outputData = jforecast( this, inputData, range, ...
                            'Plan=', opt.Plan, ...
                            'Anticipate=', opt.Anticipate, ...
                            'Deviation=', opt.Deviation, ...
                            'DTrends=', opt.DTrends, ...
                            'MeanOnly=', true );
    return
end

%--------------------------------------------------------------------------

% Input struct to the backend functions in `+simulate` package.
s = struct( );

[ny, nxx, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
nv = length(this);

nPer = length(range);
s.NPer = nPer;
s.TTrend = dat2ttrend(range, this);

% Simulation plan., ignoreresiduals, ignoreresidual',
isSwap = isa(opt.Plan, 'plan') ...
    && nnzendog(opt.Plan)>0 && nnzexog(opt.Plan)>0;

% Get initial condition for alpha.
% alpha is always expanded to match nv within datarequest(...).
[xbInit, listInitMissing] = datarequest('xbinit', this, inputData, range);
if ~isempty(listInitMissing)
    if isnan(opt.Missing)
        listInitMissing = unique(listInitMissing);
        utils.error('model:simulate', ...
            'This initial condition is missing from input databank: %s ', ...
            listInitMissing{:});
    else
        xbInit(isnan(xbInit)) = opt.Missing;
    end
end
numOfInitDataSets = size(xbInit, 3);

% Get shocks; both reals and imags are checked for NaNs within
% datarequest( )
if ~opt.IgnoreShocks
    eInp = datarequest('e', this, inputData, range);
    % Find the last anticipated shock to determine t+k for expansion.
    if opt.Anticipate
        lastEa = utils.findlast(real(eInp));
    else
        lastEa = utils.findlast(imag(eInp));
    end
    numOfShockDataSets = size(eInp, 3);
else
    lastEa = 0;
    numOfShockDataSets = 0;
end
s.LastEa = lastEa;

% Check for option conflicts.
checkConflicts( );

yTune = [ ];
xTune = [ ];
lastEndgA = 0;
lastEndgU = 0;
numSwapDataSets = 0;
if isSwap
    % Get anchors; simulation range and plan range must be identical.
    % Get data for measurement and transition tunes.
    getPlanData( );
else
    s.Anch = false(ny+nxx+ne+ne, nPer);
    s.Wght = sparse(ne+ne, nPer);
end
s.LastEndgA = lastEndgA;
s.LastEndgU = lastEndgU;

% Get exogenous variables in dtrend equations.
G = datarequest('g', this, inputData, range);
numExogDataSets = size(G, 3);

% Total number of cycles.
numRuns = max([1, nv, numOfInitDataSets, numOfShockDataSets, numSwapDataSets, numExogDataSets]);
s.NLoop = numRuns;

exitFlag = cell(1, numRuns);
finalAddf = cell(1, numRuns);
finalDcy = cell(1, numRuns);

displayMode = 'Verbose';
s = prepareSimulate1(this, s, opt, displayMode, legacyOpt{:});
s.IsSwap = isSwap;
checkConflictsSelective( );

% Initialise handle to output data.
extendedRange = range(1)-1 : range(end);
if ~s.IsContributions
    hData = hdataobj(this, extendedRange, numRuns);
else
    hData = hdataobj(this, extendedRange, ne+2, 'Contributions=', @shock);
end

s.progress = [ ];
if opt.Progress
    if strcmpi(opt.Method, 'FirstOrder') ...
       || (strcmpi(opt.Method, 'Selective') && opt.Solver.Display==0)
        s.progress = ProgressBar('[IrisToolbox] @model/simulate Progress');
    end
end

% Prepare SystemProperty
systemProperty = SystemProperty(this);
systemProperty.Function = @simulate.linear.wrapper;
systemProperty.MaxNumOfOutputs = 1;
systemProperty.NamedReferences = cell(1, 1);
systemProperty.NamedReferences{1} = [ printSolutionVector(this, 'y', @Behavior), ...
                                      printSolutionVector(this, 'xi', @Behavior), ...
                                      printSolutionVector(this, 'e', @Behavior) ];

% __Main Loop__
for ithRun = 1 : numRuns
    s.ILoop = ithRun;
    variantRunningNow = min(ithRun, nv);
    inxOfRequiredInitials = getIthIndexInitial(this.Variant, variantRunningNow);

    % Get current initial condition for the transformed state vector, 
    % current shocks, and measurement and transition tunes.
    getData( );
    
    % __Call +simulate Package__
    exit = [ ];
    dcy = [ ];
    addf = [ ];
    s.y = [ ]; % Measurement variables.
    s.w = [ ]; % Transformed transition variables, w := [xf;alpha].
    s.v = [ ]; % Correction vector for nonlinear equations.
    s.M = [ ];

    systemProperty.Specifics = s;
    if ~isequal(opt.SystemProperty, false)
        systemProperty.OutputNames = opt.SystemProperty;
        outputData = systemProperty;
        return
    end
    update(systemProperty, this, variantRunningNow); 

    if strcmpi(s.Method, 'FirstOrder')
        s = simulate.linear.wrapper(this, systemProperty, variantRunningNow);

    elseif strcmpi(s.Method, 'Selective')
        if ithRun<=nv
            % Update solution and other loop-dependent info to be used in this
            % simulation round.
            s = prepareSimulate2(this, s, ithRun);
        end
        s.Alp0 = s.U\s.XbInit;
        yTrend = double.empty(0);
        if ny>0 && s.IsDeterministicTrends
            yTrend = evalTrendEquations(this, [ ], s.ExogenousData, ithRun);
            if isSwap
                % Subtract deterministic trends from measurement tunes.
                s.Tune(1:ny, :) = s.Tune(1:ny, :) - yTrend;
            end
        end
        % Equation-selective nonlinear simulations.
        if s.IsContributions
            % Simulate linear contributions of shocks.
            c = struct( );
            [c.y, c.xx, c.Ea, c.Eu] = ...
                simulate.linear.contributions(s, Inf);
        end
        % Simulate contributions of nonlinearities residually.
        [s.y, s.xx, s.Ea, s.Eu, ~, exit, dcy, addf] = ...
            simulate.selective.run(s);
        if s.IsContributions
            c.y(:, :, ne+2) = s.y - sum(c.y, 3);
            c.xx(:, :, ne+2) = s.xx - sum(c.xx, 3);
            s.y = c.y;
            s.xx = c.xx;
            s.Ea = c.Ea;
            s.Eu = c.Eu;
        end
        % Add measurement detereministic trends.
        if ~isempty(yTrend)
            % Add to trends to the current simulation; when `'contributions=' true`, we
            % need to add the trends to (ne+1)-th simulation (ie. the contribution of
            % init cond and constant).
            if s.IsContributions
                s.y(:, :, ne+1) = s.y(:, :, ne+1) + yTrend;
            else
                s.y = s.y + yTrend;
            end            
        end
    end
    %-------------------------------------------------------------------
    % Beyond this point, only `s.y`, `s.xx`, `s.Ea` and `s.Eu` are used
    
    % Diagnostics output arguments for selective nonlinear simulations.
    if strcmpi(s.Method, 'Selective')
        exitFlag{ithRun} = exit;
        finalDcy{ithRun} = dcy;
        finalAddf{ithRun} = addf;
    end
    
    % Assign output data.
    assignOutp( );
    
    % Add equation labels to add-factor and discrepancy series.
    if strcmpi(s.Method, 'Selective') && nargout>2
        label = s.Selective.EqtnLabelN;
        finalDcy{ithRun} = permute(finalDcy{ithRun}, [2, 1, 3]);
        finalDcy{ithRun} = TIME_SERIES_CONSTRUCTOR( range(1), finalDcy{ithRun}, label );
        finalAddf{ithRun} = permute(finalAddf{ithRun}, [2, 1, 3]);
        nSgm = size(finalAddf{ithRun}, 3);
        label = repmat(label, 1, 1, nSgm);
        finalAddf{ithRun} = TIME_SERIES_CONSTRUCTOR( range(1), finalAddf{ithRun}, label );
    end

    % Update progress bar.
    if ~isempty(s.progress)
        update(s.progress, s.ILoop/s.NLoop);
    end
end % for

% __Post Mortem__
if isSwap
    % Throw a warning if the system is not exactly determined.
    chkDetermined( );
end

% Convert hdataobj to struct. The comments assigned to the output series
% depend on whether contributions=true or false.
outputData = hdata2tseries(hData, 'Delog=', opt.Delog);

% Overlay the input (or user-supplied) database with the simulation
% database if DbOverlay=true or AppendPresample=true
outputData = appendData(this, inputData, outputData, range, opt);

return


    function chkNanExog( )
        % Check for NaNs in exogenised variables.
        inx1 = s.Anch(1:ny+nxx, :);
        inx2 = [any(~isfinite(yTune), 3);any(~isfinite(xTune), 3)];
        inx3 = [any(imag(yTune) ~= 0, 3);any(imag(xTune) ~= 0, 3)];
        inx = any(inx1 & (inx2 | inx3), 2);
        if any(inx)
            list = printSolutionVector(this, 'yx');
            utils.error('model:simulate', ...
                ['This variable is exogenised to NaN, Inf or ', ...
                'complex number: ''%s''.'], ...
                list{inx});
        end
    end 


    function chkDetermined( )
        if nnzexog(opt.Plan) ~= nnzendog(opt.Plan)
            utils.warning('model:simulate', ...
                ['The number of exogenised data points (%g) does not ', ...
                'match the number of endogenised data points (%g).'], ...
                nnzexog(opt.Plan), nnzendog(opt.Plan));
        end
    end 


    function assignOutp( )
        n = size(s.xx, 3);
        % Add pre-sample init cond to x.
        xf = [nan(nf, 1, n), s.xx(1:nf, :, :)];
        xb = s.xx(nf+1:end, :, :);
        if s.IsContributions
            pos = 1 : ne+2;
            xb = [zeros(nb, 1, ne+2), xb];
            xb(:, 1, ne+1) = xbInit(:, 1, min(ithRun, end));
            g = zeros(ng, nPer, ne+2);
            g(:, :, ne+1) = s.ExogenousData;
        else
            pos = ithRun;
            xb = [xbInit(:, 1, min(ithRun, end)), xb];
            g = s.ExogenousData;
        end
        % Add current results to output data.
        if opt.Anticipate
            e = s.Ea + 1i*s.Eu;
        else
            e = s.Eu + 1i*s.Ea;
        end
        hdataassign( hData, pos, { [nan(ny, 1, n), s.y], ...
                                   [xf ; xb], ...
                                   [nan(ne, 1, n), e], ...
                                   [ ], ...
                                   [nan(ng, 1, n), g]  } );
    end 


    function checkConflicts( )
        % The option 'contributions=' option cannot be used with the 'plan='
        % option, with multiple parameter variants, or multiple data sets.
        if opt.Contributions
            if nv>1 || numOfInitDataSets>1 || numOfShockDataSets>1
                utils.error('model:simulate', ...
                    ['Cannot simulate(...) ', ...
                    'models with multiple alternative parameterizations ', ...
                    'with option contributions=true.']);
            end
            if numOfInitDataSets>1 || numOfShockDataSets>1
                utils.error('model:simulate', ...
                    ['Cannot simulate(...) ', ...
                    'multiple data sets ', ...
                    'with option contributions=true.']);
            end
        end
        
        assert( strcmpi(opt.Method, 'FirstOrder') || ~opt.SystemProperty, ...
                'model:simulate:SystemPropertyFirstOrder', ...
                'Only first-order simulations are permitted as system property' );
    end% 


    function checkConflictsSelective( )
        if strcmpi(s.Method, 'Selective') && lastEndgU>0 && lastEndgA>0
            utils.error('model:simulate', ...
                ['Cannot simulate(...) with option method=selective and ', ...
                'both anticipated and unanticipated endogenized shocks.']);
        end
    end%


    function getData( )        
        % Get current initial conditions and and current shocks
        s.XbInit = xbInit(:, 1, min(ithRun, end));
        inxOfNaNInitials = isnan(s.XbInit);
        s.XbInit(inxOfNaNInitials & ~inxOfRequiredInitials(:)) = 0;
        if opt.IgnoreShocks
            s.Ea = zeros(ne, nPer);
            s.Eu = zeros(ne, nPer);
        else
            if opt.Anticipate
                s.Ea = real(eInp(:, :, min(ithRun, end)));
                s.Eu = imag(eInp(:, :, min(ithRun, end)));
            else
                s.Ea = imag(eInp(:, :, min(ithRun, end)));
                s.Eu = real(eInp(:, :, min(ithRun, end)));
            end
        end
        if opt.SparseShocks
            s.Ea = sparse(s.Ea);
        end
        % Current tunes on measurement and transition variables.
        if isSwap
            s.Tune = [ ...
                yTune(:, :, min(ithRun, end)); ...
                xTune(:, :, min(ithRun, end)); ...
                ];
        else
            s.Tune = sparse(ny+nxx, nPer);
        end
        % Exogenous variables in dtrend equations.
        s.ExogenousData = G(:, :, min(ithRun, end));
    end%


    function getPlanData( )
        [yAnch, xAnch, eaAnch, euAnch, ~, ~, eaWght, euWght] = ...
            myanchors(this, opt.Plan, range, opt.Anticipate);
        s.Anch = [yAnch;xAnch;eaAnch;euAnch];
        s.Wght = [eaWght;euWght];
        % Get values for exogenised data points.
        if any(yAnch(:))
            % Retrieve all data for measurement variables, but zero all non-anchored
            % data points so that they do not affect position of last anchor.
            yTune = datarequest('y', this, inputData, range);
            yTune(~yAnch) = 0;
        else
            yTune = zeros(ny, nPer);
        end
        if any(xAnch(:))
            % Retrieve all data for transition variables, but zero all non-anchored
            % data points so that they do not affect position of last anchor.
            xTune = datarequest('x', this, inputData, range);
            xTune(~xAnch) = 0;
        else
            xTune = zeros(nxx, nPer);
        end
        % Check for NaNs in exogenised variables.
        chkNanExog( );
        numSwapDataSets = max(size(yTune, 3), size(xTune, 3));
        lastEndgA = utils.findlast(eaAnch);
        lastEndgU = utils.findlast(euAnch);
    end%
end%

