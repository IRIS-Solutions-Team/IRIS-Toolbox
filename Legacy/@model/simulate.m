function [outputData, exitFlag, finalAddf, finalDcy] = simulate(this, inputData, range, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('model.simulate');
    ip.addRequired('M', @(x) isa(x, 'model') && ~isempty(x) && all(beenSolved(x)));
    ip.addRequired('D', @isstruct);
    ip.addRequired('Range', @(x) validate.properRange(x));
end
ip.parse(this, inputData, range);
[opt, legacyOpt] = parseSimulateOptions(this, varargin{:});

range = range(1) : range(end);

% Convert plain numeric range into DateWrapper range
if ~isa(range, 'DateWrapper')
    range = Dater(range);
end

% Conditional simulation
isCond = isa(opt.Plan, 'plan') && ~isempty(opt.Plan, 'cond');
if isCond
    outputData = jforecast( this, inputData, range, ...
                            'Plan', opt.Plan, ...
                            'Anticipate', opt.Anticipate, ...
                            'Deviation', opt.Deviation, ...
                            'EvalTrends', opt.DTrends, ...
                            'MeanOnly', true );
    return
end

%--------------------------------------------------------------------------

% Input struct to the backend functions in `+simulate` package.
s = struct( );

[ny, nxx, nb, nf, ne, ng] = sizeSolution(this.Vector);
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
    hData = hdataobj(this, extendedRange, ne+2, 'Contributions', @shock);
end

s.progress = [ ];
if opt.Progress
    if strcmpi(opt.Method, 'FirstOrder') ...
       || (strcmpi(opt.Method, 'Selective') && s.Solver.Display==0)
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

    systemProperty.CallerData = s;
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
            % Add to trends to the current simulation; when Contributions=true, we
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
        finalDcy{ithRun} = Series( range(1), finalDcy{ithRun}, label );
        finalAddf{ithRun} = permute(finalAddf{ithRun}, [2, 1, 3]);
        nSgm = size(finalAddf{ithRun}, 3);
        label = repmat(label, 1, 1, nSgm);
        finalAddf{ithRun} = Series( range(1), finalAddf{ithRun}, label );
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
outputData = hdata2tseries(hData, 'delog', opt.Delog);

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
        % The option Contributions option cannot be used with the Plan
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

