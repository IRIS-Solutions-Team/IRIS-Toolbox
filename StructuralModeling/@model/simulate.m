function [outp, exitFlag, finalAddf, finalDcy] = simulate(this, inp, range, varargin)
% simulate  Simulate model
%
% Syntax
%========
%
%     s = simulate(m, d, range)
%     [s, exitFlag, addF, delta] = simulate(m, d, range)
%
%
% Input arguments
%=================
%
% * `m` [ model ] - Solved model object.
%
% * `d` [ struct | cell ] - Input database or datapack from which the
% initial conditions and shocks from within the simulation range will be
% read.
%
% * `range` [ numeric | char ] - Simulation range.
%
%
% Output arguments
%==================
%
% * `s` [ struct | cell ] - Database with simulation results.
%
%
% Output arguments in nonlinear simulations
%===========================================    
%
% * `exitFlag` [ cell | empty ] - Cell array with exit flags for
% nonlinearised simulations.
%
% * `addF` [ cell | empty ] - Cell array of time series with final add-factors
% added to first-order approximate equations to make nonlinear equations
% hold.
%
% * `delta` [ cell | empty ] - Cell array of time series with final
% discrepancies between LHS and RHS in equations marked for nonlinear
% simulations by a double-equal sign.
%
%
% Options
%=========
%
% * `'Anticipate='` [ *`true`* | `false` ] - If `true`, real future shocks
% are anticipated, imaginary are unanticipated; vice versa if `false`.
%
% * `'Contributions='` [ `true` | *`false`* ] - Decompose the simulated
% paths into contributions of individual shocks.
%
% * `'DbOverlay='` [ `true` | *`false`* | struct ] - Use the function
% `dboverlay` to combine the simulated output data with the input database, 
% (or a user-supplied database); both the data preceeding the simulation
% range and after the simulation range are appended.
%
% * `'Deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - Add deterministic
% trends to measurement variables.
%
% * `'IgnoreShocks='` [ `true` | *`false`* ] - Read only initial conditions
% from input data, and ignore any shocks within the simulation range.
%
% * `'Method='` [ *`'firstorder'`* | `'selective'` | `'global'` ] - Method
% of running simulations; `'firstorder'` means first-order approximate
% solution (calculated around steady state); `'selective'` means
% equation-selective nonlinear method; `'global'` means global nonlinear
% method (available only in models with no leads).
%
% * `'Plan='` [ Scenario ] - Specify scenario to swap endogeneity and
% exogeneity of some variables and shocks temporarily, and/or to simulate
% some nonlinear equations.
%
% * `'Progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'SparseShocks='` [ `true` | *`false`* ] - Store anticipated shocks
% (including endogenized anticipated shocks) in sparse array.
%
%
% Options for equation-selective nonlinear simulations
%======================================================
%
% * `'Solver='` [ *`@qad`* | `@fsolve` | `@lsqnonlin` ] - Solution
% algorithm; see Description.
%
% * `'MaxNumelJv='` [ numeric | *`1e6`* ] - Maximum number of data points
% (nonlinear plus exogenized) allowed for a nonrecursive algorithm in the
% nonlinear equation updating step; if exceeded, a recursive
% (period-by-period) simulation is used to update nonlinear equations
% instead.
%
% * `'NonlinWindow='` [ numeric | *`@all`* ] - Time window (number of
% periods from the beginning of the simulation, and from the beginning of
% each simulation segment) over which nonlinearities will be preserved; the
% remaining periods will be simulated using first-order approximate
% solution.
%
%
% Options for equation-selective nonlinear simulations with @qad solver
%=======================================================================
%
% * `'AddSstate='` [ *`true`* | `false` ] - Add steady state levels to
% simulated paths before evaluating nonlinear equations; this option is
% used only if `'deviation=' true`.
%
% * `'Display='` [ *`true`* | `false` | numeric | Inf ] - Report iterations
% on the screen; if `'display=' N`, report every `N` iterations; if
% `'display=' Inf`, report only final iteration.
%
% * `'Error='` [ `true` | *`false`* ] - Throw an error whenever a
% nonlinear simulation fails converge; if `false`, only an warning will
% display.
%
% * `'Lambda='` [ numeric | *`1`* ] - Initial step size (between `0` and
% `1`) for add factors added to nonlinearised equations in every iteration;
% see also `'nOptimLambda='`.
%
% * `'NOptimLambda='` [ numeric | `false` | *`1`* ] - Find the optimal step
% size on a grid of 10 points between 0 and `'lambda='` before each of the
% first `'nOptimLambda='` iterations; if `false`, the value assigned to
% `Lambda` is used and no grid search is performed.
%
% * `'ReduceLambda='` [ numeric | *`0.5`* ] - Reduction factor (between `0`
% and `1`) by which `lambda` will be multiplied if the nonlinear
% simulation gets on an divergence path.
%
% * `'UpperBound='` [ numeric | *`1.5`* ] - Multiple of all-iteration
% minimum achieved that triggers a reversion to that iteration and a
% reduciton in `lambda`.
%
% * `'MaxIter='` [ numeric | *`100`* ] - Maximum number of iterations.
%
% * `'Tolerance='` [ numeric | *`1e-5`* ] - Convergence tolerance.
%
%
% Options for nonlinear simulations with Optim Tbx solver
%=========================================================
%
% * `'OptimSet='` [ cell | struct ] - Optimization Tbx options.
%
%
% Options for global nonlinear simulations
%==========================================
%
% * `'OptimSet='` [ cell | struct ] - Optimization Tbx options.
%
% * `'Solver='` [ `@fsolve` | *`@lsqnonlin`* ] - Solution algorithm; see
% Description.
%
%
% Description
%=============
%
% The function `simulate( )` simulates a model on the specified
% simulation range. By default, the simulation is based on a first-order
% approximate solution (calculated around steady state). To run nonlinear
% simulations, use the option `'Nonlinear='` (to set the number of periods
%
% Output range
%--------------
%
% Time series in the output database, `s`, are are defined on the
% simulation range, `range`, plus include all necessary initial conditions, 
% ie. lags of variables that occur in the model code. You can use the
% option `'DbOverlay='` to combine the output database with the input
% database (ie. to include a longer history of data in the simulated
% series).
%
%
% Deviations from steady-state and deterministic trends
%-------------------------------------------------------
%
% By default, both the input database, `d`, and the output database, `s`, 
% are in full levels and the simulated paths for measurement variables
% include the effect of deterministic trends, including possibly exogenous
% variables. The default behavior can be changed by changing the options
% `'Deviation='` and `'Dtrends='`.
%
% The default value for `'Deviation='` is false. If set to `true`, then the
% input database is expected to contain data in the form of deviations from
% their steady state levels or paths. For ordinary variables (ie. variables
% whose log status is `false`), it is $x_t-\bar x_t$, meaning that a 0
% indicates that the variable is at its steady state and e.g. 2 indicates
% the variables exceeds its steady state by 2. For log variables (ie.
% variables whose log status is `true`), it is $x_t/\Bar x_t$, meaning that
% a 1 indicates that the variable is at its steady state and e.g. 1.05
% indicates that the variable is 5 per cent above its steady state.
%
% The default value for `'Dtrends='` is `@auto`. This means that its
% behavior depends on the option `'Deviation='`. If `'Deviation=' false`
% then deterministic trends are added to measurement variables, unless you
% manually override this behavior by setting `'Dtrends=' false`.  On the
% other hand, if `'Deviation=' true` then deterministic trends are not
% added to measurement variables, unless you manually override this
% behavior by setting `'Dtrends=' true`.
%
%
% Simulating contributions of shocks
%------------------------------------
%
% Use the option `'Contributions=' true` to request the contributions of
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
% output database from a simulation with `'Contributions=' true`, `X` is an
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
% Simulations with multiple parameterisations and/or multiple data sets
%-----------------------------------------------------------------------
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
% `min(N, K)`. From that point on, the last parameterisation or the last
% data set will be simply repeated (re-used) in the remaining simulations.
%
% * Formally, the `I`-th column in the output database, where `I = 1, ..., 
% P`, is a simulation of the `min(I, N)`-th model parameterisation using the
% `min(I, K)`-th input data set number.
%
%
% Equation-selective nonlinear simulations
%------------------------------------------
%
% The equation-selective nonlinear simulation approach is invoked by
% setting `'Method=' 'Selective'`. In equation-selective nonlinear
% simulations, the solver tries to find add-factors to user-selected
% nonlinear equations (ie. equations with `=#` instead of the equal sign in
% the model file) in the first-order solution such that the original
% nonlinear equations hold for simulated trajectories (with expectations
% replaced with actual leads).
%
% Two numerical approaches are available, controlled by the option
% `'Solver='`:
%
% * '`QaD`' - a quick-and-dirty, but less robust method (default);
%
% * `@fsolve`, `@lsqnonlin` - which are standard Optimization Tbx routines, 
% slower but likely to converge for a wider variety of simulations.
%
%
% Global nonlinear simulations
%------------------------------
%
% The global nonlinear simulation approach is invoked by setting `'Method='
% 'Global'` and is available only in models with no leads (expectations).
% In global nonlinear simulations, the entire model is solved as a system
% of nonlinear equations, period by period, using one of the following two
% Optimization Tbx routines: `@fsolve` or `@lsqnonlin` (default).
%
%
% Example
%=========
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% [this, inp, range, varargin] = ...
%     irisinp.parser.parse('model.simulate', varargin{:});

TEMPLATE_SERIES = Series( );

opt = passvalopt('model.simulate', varargin{:});

% Global (exact) nonlinear simulation of backward-looking models.
if strcmpi(opt.method, 'global') || strcmpi(opt.method, 'exact')
    if isequal(opt.Solver, @auto)
        opt.Solver = 'IRIS';
    end
    [this, inp, range] = ...
        irisinp.parser.parse('model.run', this, inp, range);
    [outp, exitFlag]  = simulateNonlinear(this, inp, range, @all, 'Verbose', opt);
    outp = model.appendData(inp, outp, range, opt);
    return
end

if isequal(opt.Solver, @auto)
    opt.Solver = 'qad';
end

[this, inp, range] = ...
    irisinp.parser.parse('model.simulate', this, inp, range);

if ischar(opt.Solver) && strcmpi(opt.Solver, 'plain')
    opt.Solver = @qad;
end

%--------------------------------------------------------------------------

% Input struct to the backend functions in `+simulate` package.
s = struct( );

[ny, nxx, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
nAlt = length(this);

nPer = length(range);
s.NPer = nPer;
s.TTrend = dat2ttrend(range, this);

% Simulation plan.
isSwap = isa(opt.plan, 'plan') ...
    && nnzendog(opt.plan)>0 && nnzexog(opt.plan)>0;

% Get initial condition for alpha.
% alpha is always expanded to match nAlt within datarequest(...).
[alp0, x0, nanInit] = datarequest('init', this, inp, range);
if ~isempty(nanInit)
    if isnan(opt.missing)
        nanInit = unique(nanInit);
        utils.error('model:simulate', ...
            'This initial condition is not available: ''%s''.', ...
            nanInit{:});
    else
        alp0(isnan(alp0)) = opt.missing;
    end
end
nInit = size(alp0, 3);

% Get shocks; both reals and imags are checked for NaNs within
% datarequest(...).
if ~opt.ignoreshocks
    eInp = datarequest('e', this, inp, range);
    % Find the last anticipated shock to determine t+k for expansion.
    if opt.anticipate
        lastEa = utils.findlast(real(eInp));
    else
        lastEa = utils.findlast(imag(eInp));
    end
    nShock = size(eInp, 3);
else
    lastEa = 0;
    nShock = 0;
end
s.LastEa = lastEa;

% Check for option conflicts.
chkConflicts( );

yTune = [ ];
xTune = [ ];
lastEndgA = 0;
lastEndgU = 0;
nSwap = 0;
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
G = datarequest('g', this, inp, range);
nExog = size(G, 3);

% Total number of cycles.
nLoop = max([1, nAlt, nInit, nShock, nSwap, nExog]);
s.NLoop = nLoop;

exitFlag = cell(1, nLoop);
finalAddf = cell(1, nLoop);
finalDcy = cell(1, nLoop);

s = prepareSimulate1(this, s, opt);
chkNonlinConflicts( );

% Initialise handle to output data.
xRange = range(1)-1 : range(end);
if ~opt.contributions
    hData = hdataobj(this, xRange, nLoop);
else
    hData = hdataobj(this, xRange, ne+2, 'Contributions=', @shock);
end

% Preallocate array for time-varying parameter revision.
if s.IsRevision
    nRevision = length(s.Revision.PtrRevision);
    pData = nan(nRevision, nPer, nLoop);    
end

% Main loop
%-----------
if opt.progress && strcmpi(opt.method, 'FirstOrder')
    s.progress = ProgressBar('IRIS model.simulate progress');
else
    s.progress = [ ];
end

for iLoop = 1 : nLoop
    s.ILoop = iLoop;
    
    if iLoop <= nAlt
        % Update solution and other loop-dependent info to be used in this
        % simulation round.
        s = prepareSimulate2(this, s, iLoop);
    end

    % Get current initial condition for the transformed state vector, 
    % current shocks, and measurement and transition tunes.
    getData( );
    
    % Compute deterministic trends if requested. Do not compute the dtrends
    % in the `+simulate` package because they are dealt with differently when
    % called from within the Kalman filter.
    dTnd = [ ];
    if ny>0 && opt.dtrends
        dTnd = evalDtrends(this, [ ], s.G, iLoop);
        if isSwap
            % Subtract deterministic trends from measurement tunes.
            s.Tune(1:ny, :) = s.Tune(1:ny, :) - dTnd;
        end
    end
    
    % Call the backend package `simulate`
    %-------------------------------------
    exit = [ ];
    dcy = [ ];
    addf = [ ];
    s.y = [ ]; % Measurement variables.
    s.w = [ ]; % Transformed transition variables, w := [xf;alpha].
    s.v = [ ]; % Correction vector for nonlinear equations.
    s.M = [ ];
    
    if s.IsRevision
        % Simulate period by period, revise steady state in each period.
        [s.y, s.xx, s.Ea, s.Eu, s.p] = mysimulateper(this, s);
        pData(:, :, iLoop) = s.p;
    else
        switch s.Method
            case 'firstorder'
                % Linear simulations.
                if opt.contributions
                    if isSwap
                        [s.y, s.xx, s.Ea, s.Eu] = simulate.linear.run(s, Inf);
                    end
                    [s.y, s.xx, s.Ea, s.Eu] = ...
                        simulate.linear.contributions(s, Inf);
                else
                    [s.y, s.xx, s.Ea, s.Eu] = simulate.linear.run(s, Inf);
                end
            case 'selective'
                % Equation-selective nonlinear simulations.
                if opt.contributions
                    % Simulate linear contributions of shocks.
                    c = struct( );
                    [c.y, c.xx, c.Ea, c.Eu] = ...
                        simulate.linear.contributions(s, Inf);
                end
                % Simulate contributions of nonlinearities residually.
                [s.y, s.xx, s.Ea, s.Eu, ~, exit, dcy, addf] = ...
                    simulate.selective.run(s);
                if opt.contributions
                    c.y(:, :, ne+2) = s.y - sum(c.y, 3);
                    c.xx(:, :, ne+2) = s.xx - sum(c.xx, 3);
                    s.y = c.y;
                    s.xx = c.xx;
                    s.Ea = c.Ea;
                    s.Eu = c.Eu;
                end
        end
    end
    %-------------------------------------------------------------------
    % Beyond this point, only `s.y`, `s.xx`, `s.Ea` and `s.Eu` are used
    
    % Diagnostics output arguments for selective nonlinear simulations.
    if isequal(s.Method, 'selective')
        exitFlag{iLoop} = exit;
        finalDcy{iLoop} = dcy;
        finalAddf{iLoop} = addf;
    end
    
    % Add measurement detereministic trends.
    if ny>0 && opt.dtrends
        % Add to trends to the current simulation; when `'contributions=' true`, we
        % need to add the trends to (ne+1)-th simulation (ie. the contribution of
        % init cond and constant).
        if opt.contributions
            s.y(:, :, ne+1) = s.y(:, :, ne+1) + dTnd;
        else
            s.y = s.y + dTnd;
        end            
    end

    % Assign output data.
    assignOutp( );
    
    % Add equation labels to add-factor and discrepancy series.
    if isequal(s.Method, 'selective') && nargout>2
        label = s.Selective.EqtnLabelN;
        finalDcy{iLoop} = permute(finalDcy{iLoop}, [2, 1, 3]);
        finalDcy{iLoop} = Series( range(1), finalDcy{iLoop}, label );
        finalAddf{iLoop} = permute(finalAddf{iLoop}, [2, 1, 3]);
        nSgm = size(finalAddf{iLoop}, 3);
        label = repmat(label, 1, 1, nSgm);
        finalAddf{iLoop} = Series( range(1), finalAddf{iLoop}, label );
    end

    % Update progress bar.
    if ~isempty(s.progress)
        update(s.progress, s.ILoop/s.NLoop);
    end
end % for

% Post mortem
%-------------
if isSwap
    % Throw a warning if the system is not exactly determined.
    chkDetermined( );
end

% Convert hdataobj to struct. The comments assigned to the output series
% depend on whether contributions=true or false.
outp = hdata2tseries(hData, 'Delog=', opt.Delog);
if s.IsRevision
    createParamRevisionDb( );
end

% Overlay the input (or user-supplied) database with the simulation
% database if DbOverlay=true or AppendPresample=true
outp = model.appendData(inp, outp, range, opt);

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
        if nnzexog(opt.plan) ~= nnzendog(opt.plan)
            utils.warning('model:simulate', ...
                ['The number of exogenised data points (%g) does not ', ...
                'match the number of endogenised data points (%g).'], ...
                nnzexog(opt.plan), nnzendog(opt.plan));
        end
    end 




    function assignOutp( )
        n = size(s.xx, 3);
        % Add pre-sample init cond to x.
        xf = [nan(nf, 1, n), s.xx(1:nf, :, :)];
        xb = s.xx(nf+1:end, :, :);
        if opt.contributions
            pos = 1 : ne+2;
            xb = [zeros(nb, 1, ne+2), xb];
            xb(:, 1, ne+1) = x0(:, 1, min(iLoop, end));
            g = zeros(ng, nPer, ne+2);
            g(:, :, ne+1) = s.G;
        else
            pos = iLoop;
            xb = [x0(:, 1, min(iLoop, end)), xb];
            g = s.G;
        end
        % Add current results to output data.
        if opt.anticipate
            e = s.Ea + 1i*s.Eu;
        else
            e = s.Eu + 1i*s.Ea;
        end
        hdataassign(hData, pos, ...
            { ...
            [nan(ny, 1, n), s.y], ...
            [xf;xb], ...
            [nan(ne, 1, n), e], ...
            [ ], ...
            [nan(ng, 1, n), g], ...
            });
    end 




    function chkConflicts( )
        % The option 'contributions=' option cannot be used with the 'plan='
        % option, with multiple parameterisations, or multiple data sets.
        if opt.contributions
            if nAlt>1 || nInit>1 || nShock>1
                utils.error('model:simulate', ...
                    ['Cannot simulate(...) ', ...
                    'models with multiple alternative parameterizations ', ...
                    'with option contributions=true.']);
            end
            if nInit>1 || nShock>1
                utils.error('model:simulate', ...
                    ['Cannot simulate(...) ', ...
                    'multiple data sets ', ...
                    'with option contributions=true.']);
            end
        end
    end 




    function chkNonlinConflicts( )
        if isequal(s.Method, 'selective') ...
                && lastEndgU>0 && lastEndgA>0
            utils.error('model:simulate', ...
                ['Cannot simulate(...) with option method=selective and ', ...
                'both anticipated and unanticipated exogenized shocks.']);
        end
        if isequal(s.Method, 'selective') && s.IsRevision
            utils.error('model:simulate', ...
                ['Cannot simulate(...) with option method=selective and ', ...
                'Revision=true.']);
        end
        if s.IsRevision && s.IsDeviation
            utils.error('model:simulate', ...
                ['Cannot simulate(...) ', ...
                'with options deviation=true ', ...
                'and Revision=true.']);
        end
    end 




    function getData( )        
        % Get current initial condition for the transformed state vector, 
        % and current shocks.
        s.x0 = x0(:, 1, min(iLoop, end));
        s.Alp0 = alp0(:, 1, min(iLoop, end));
        if opt.ignoreshocks
            s.Ea = zeros(ne, nPer);
            s.Eu = zeros(ne, nPer);
        else
            if opt.anticipate
                s.Ea = real(eInp(:, :, min(iLoop, end)));
                s.Eu = imag(eInp(:, :, min(iLoop, end)));
            else
                s.Ea = imag(eInp(:, :, min(iLoop, end)));
                s.Eu = real(eInp(:, :, min(iLoop, end)));
            end
        end
        if opt.sparseshocks
            s.Ea = sparse(s.Ea);
        end
        % Current tunes on measurement and transition variables.
        if isSwap
            s.Tune = [ ...
                yTune(:, :, min(iLoop, end)); ...
                xTune(:, :, min(iLoop, end)); ...
                ];
        else
            s.Tune = sparse(ny+nxx, nPer);
        end
        % Exogenous variables in dtrend equations.
        s.G = G(:, :, min(iLoop, end));
    end 




    function getPlanData( )
        [yAnch, xAnch, eaAnch, euAnch, ~, ~, eaWght, euWght] = ...
            myanchors(this, opt.plan, range, opt.anticipate);
        s.Anch = [yAnch;xAnch;eaAnch;euAnch];
        s.Wght = [eaWght;euWght];
        % Get values for exogenised data points.
        if any(yAnch(:))
            % Retrieve all data for measurement variables, but zero all non-anchored
            % data points so that they do not affect position of last anchor.
            yTune = datarequest('y', this, inp, range);
            yTune(~yAnch) = 0;
        else
            yTune = zeros(ny, nPer);
        end
        if any(xAnch(:))
            % Retrieve all data for transition variables, but zero all non-anchored
            % data points so that they do not affect position of last anchor.
            xTune = datarequest('x', this, inp, range);
            xTune(~xAnch) = 0;
        else
            xTune = zeros(nxx, nPer);
        end
        % Check for NaNs in exogenised variables.
        chkNanExog( );
        nSwap = max(size(yTune, 3), size(xTune, 3));
        lastEndgA = utils.findlast(eaAnch);
        lastEndgU = utils.findlast(euAnch);
    end 




    function createParamRevisionDb( )
        for ii = 1 : length(s.Revision.PtrRevision)
            iiName = this.Quantity.Name{s.Revision.PtrRevision(ii)};
            iiData = permute(pData(ii, :, :), [2, 3, 1]);
            outp.(iiName) = replace(TEMPLATE_SERIES, iiData, range(1));
        end
    end
end
