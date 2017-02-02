function outp = jforecast(this, inp, range, varargin)
% jforecast  Forecast with judgmental adjustments (conditional forecasts).
%
% Syntax
% =======
%
%     f = jforecast(m, d, range, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Solved model object.
%
% * `d` [ struct ] - Input data from which the initial condition is taken.
%
% * `range` [ numeric ] - Forecast range.
%
%
% Output arguments
% =================
%
% * `f` [ struct ] - Output struct with the judgmentally adjusted forecast.
%
%
% Options
% ========
%
% * `'Anticipate='` [ *`true`* | `false` ] - If true, real future shocks are
% anticipated, imaginary are unanticipated; vice versa if false.
%
% * `'CurrentOnly='` [ *`true`* | `false` ] - If `true`, MSE matrices will
% be computed only for the current-dated variables, not for their lags or
% leads (expectations).
%
% * `'Deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - Measurement data
% contain deterministic trends.
%
% * `'InitCond='` [ *`'data'`* | `'fixed'` ] - Use the MSE for the initial
% conditions if found in the input data or treat the initical conditions as
% fixed.
%
% * `'MeanOnly='` [ `true` | *`false`* ] - Return only mean data, i.e. point
% estimates.
%
% * `'Plan='` [ Scenario ] - Scenario specifying exogenised variables,
% endogenised shocks, and conditioning variables.
%
% * `'Vary='` [ struct | *empty* ] - Database with time-varying std
% deviations or cross-correlations of shocks.
%
%
% Description
% ============
%
% When adjusting the mean and/or std devs of shocks, you can use real and
% imaginary numbers ot distinguish between anticipated and unanticipated
% shocks:
%
% * any shock entered as an imaginary number is treated as an
% anticipated change in the mean of the shock distribution;
%
% * any std dev of a shock entered as an imaginary number indicates that
% the shock will be treated as anticipated when conditioning the forecast
% on the reduced-form tunes.
%
% * the same shock or its std dev can have both the real and the imaginary
% part.
%
%
% Description
% ============
%
%
% Example
% ========
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('Inp', @(x) isstruct(x) || iscell(x));
pp.addRequired('Range', @(x) isdatinp(x));
pp.parse(inp, range);

if ischar(range)
    range = textinp2dat(range);
end
range = range(1) : range(end);

if ~isempty(varargin) && ~ischar(varargin{1})
    cond = varargin{1};
    varargin(1) = [ ];
    isCond = true;
else
    cond = [ ];
    isCond = false;
end

opt = passvalopt('model.jforecast', varargin{:});

isPlanCond = isa(opt.plan, 'plan') && ~isempty(opt.plan, 'cond');
isCond = isCond || isPlanCond;

% Tunes.
isSwap = isplan(opt.plan) && ~isempty(opt.plan, 'tunes');

% Create real and imag `stdcorr` vectors from user-supplied databases.
[opt.stdcorrreal, opt.stdcorrimag] = varyStdCorr(this, range, cond, opt);

% TODO: Remove 'missing', 'contributions' options from jforecast, 
% 'anticipate' scalar.

%--------------------------------------------------------------------------

[ny, nxx, nb, nf, ne, ng] = sizeOfSolution(this.Vector);

nAlt = length(this);
nPer = length(range);
xRange = range(1)-1 : range(end);
nXPer = length(xRange);

% Current-dated variables in the original state vector.
if opt.currentonly
    ixXCurr = imag(this.Vector.Solution{2}) == 0;
else
    ixXCurr = true(size(this.Vector.Solution{2}));
end
nXCurr = sum(ixXCurr);
ixXfCurr = ixXCurr(1:nf);
ixXbCurr = ixXCurr(nf+1:end);

% Get initial condition for the alpha vector. The `datarequest` function
% always expands the `alpha` vector to match `nalt`. The `ainitmse` and
% `xinitmse` matrices can be empty.
[aInit, xInit, nanInit, aInitMse, xInitMse] = ...
    datarequest('init', this, inp, range);

% Check for availability of all initial conditions.
chkInitCond( );
nInit = size(aInit, 3);
nInitMse = size(aInitMse, 4);

if opt.anticipate
    antFn = @real;
    unaFn = @imag;
else
    antFn = @imag;
    unaFn = @real;
end

% Get input data for y, current dates of [xf;xb], and e. The size of all
% data is equalised in 3rd dimensin in the `datarequest` function.
[yInp, xInp, eInp] = datarequest('yxe', this, inp, range);
nData = size(xInp, 3);
eaInp = antFn(eInp);
euInp = unaFn(eInp);

% Get exogenous variables includig ttrend.
G = datarequest('g', this, inp, range);
nExog = size(G, 3);

% Determine the total number of cycles.
nLoop = max([nAlt, nInit, nInitMse, nData, nExog]);

lastOrZeroFunc = @(x) max([0, find(any(x, 1), 1, 'last')]);

if isSwap || isPlanCond
    % Anchors for exogenised `AnchX` and conditioning `AnchC` variables.
    [yAnchX, xAnchX, eaAnchX, euAnchX, yAnchC, xAnchC] = ...
        myanchors(this, opt.plan, range, opt.anticipate);
end

if isSwap
    % Load positions (anchors) of exogenised and endogenised data points.
    xAnchX = xAnchX(ixXCurr, :);
    % Check for NaNs in exogenised variables, and check the number of
    % exogenised and endogenised data points.
    chkExogenised( );
    lastEaAnchX = lastOrZeroFunc(eaAnchX);
    lastEuAnchX = lastOrZeroFunc(euAnchX);
    lastYAnchX = lastOrZeroFunc(yAnchX);
    lastXAnchX = lastOrZeroFunc(xAnchX);
else
    lastEaAnchX = 0;
    lastEuAnchX = 0;
    lastYAnchX = 0;
    lastXAnchX = 0;
end

if isCond
    % Load conditioning data.
    if isPlanCond
        Y = yInp;
        X = xInp;
        Ea = zeros(ne, nPer);
        Eu = zeros(ne, nPer);
        xAnchC = xAnchC(ixXCurr, :);
        X = X(ixXCurr, :, :);
    else
        Y = datarequest('y', this, cond, range);
        X = datarequest('x', this, cond, range);
        E = datarequest('e', this, cond, range);
        Y = Y(:, :, 1);
        X = X(:, :, 1);
        E = E(:, :, 1);
        Ea = antFn(E);
        Eu = unaFn(E);
        X = X(ixXCurr, :);
        yAnchC = ~isnan(Y);
        xAnchC = ~isnan(X);
    end
    lastYAnchC = lastOrZeroFunc(yAnchC);
    lastXAnchC = lastOrZeroFunc(xAnchC);
    isCond = lastYAnchC > 0 || lastXAnchC > 0;
    % Check for overlaps between shocks from input data and shocks from
    % conditioning data, and add up the overlapping shocks.
    chkOverlap( );
else
    lastYAnchC = 0;
    lastXAnchC = 0;
end

lastEa = lastOrZeroFunc(any(eaInp ~= 0, 3));
lastEu = lastOrZeroFunc(any(euInp ~= 0, 3));

last = max([lastXAnchX, lastYAnchX, ...
    lastEa, lastEaAnchX, lastEu, lastEuAnchX, ...
    lastYAnchC, lastXAnchC]);

if isSwap
    yAnchX = yAnchX(:, 1:last);
    xAnchX = xAnchX(:, 1:last);
    eaAnchX = eaAnchX(:, 1:last);
    euAnchX = euAnchX(:, 1:last);
    % Indices of exogenised data points and endogenised shocks.
    ixExog = [yAnchX(:).', xAnchX(:).'];
    ixEndg = [false, false(1, nb), euAnchX(:).', eaAnchX(:).'];
else
    ixExog = false(1, (ny+nXCurr)*last);
    ixEndg = false(1, 1+nb+2*ne*last);
end

if isCond
    yAnchC = yAnchC(:, 1:last, :);
    xAnchC = xAnchC(:, 1:last, :);
    Y = Y(:, 1:last, :);
    X = X(:, 1:last, :);
    % Index of conditions on measurement and transition variables.
    ixCond = [yAnchC(:).', xAnchC(:).'];
    % Index of conditions on measurement and transition variables excluding
    % exogenised positions.
    ixCondNotExog = ixCond(~ixExog);
end

% Index of parameterisation with solutions not available.
[~, ixNanSol] = isnan(this, 'solution');

% Create and initialise output hdataobj.
hData = struct( );
hData.mean = hdataobj(this, xRange, nLoop, ...
    'Precision=', opt.precision);
if ~opt.meanonly
    hData.std = hdataobj(this, xRange, nLoop, ...
        'IsVar2Std=', true, ...
        'Precision=', opt.precision);
end

% Main loop
%-----------

if opt.progress
    % Create progress bar.
    progress = ProgressBar('IRIS model.solve progress');
end

for iLoop = 1 : nLoop
    
    % Get exogenous data and compute deterministic trends if requested.
    g = G(:, :, min(iLoop, end));
    if opt.dtrends
        W = evalDtrends(this, [ ], g, iLoop);
    end
    
    if iLoop <= nAlt
        % Expansion needed to t+k.
        k = max(1, last) - 1;
        this = expand(this, k);
        Tf = this.solution{1}(1:nf, :, iLoop);
        Ta = this.solution{1}(nf+1:end, :, iLoop);
        R = this.solution{2}(:, :, iLoop);
        Rf = R(1:nf, 1:ne);
        Ra = R(nf+1:end, 1:ne);
        Kf = this.solution{3}(1:nf, :, iLoop);
        Ka = this.solution{3}(nf+1:end, :, iLoop);
        Z = this.solution{4}(:, :, iLoop);
        H = this.solution{5}(:, :, iLoop);
        D = this.solution{6}(:, :, iLoop);
        U = this.solution{7}(:, :, iLoop);
        Ut = U.';
        % Swapped system.
        if opt.meanonly
            [M, Ma] = myforecastswap(this, iLoop, ixExog, ixEndg, last);
        else
            [M, Ma, N, Na] = myforecastswap(this, iLoop, ixExog, ixEndg, last);
        end
        StdcorrA = [ ];
        StdcorrU = [ ];
        createStdCorr( );
    end
    
    % Solution not available.
    if ixNanSol(min(iLoop, end));
        continue
    end
    
    % Initial condition.
    a0 = aInit(:, 1, min(iLoop, end));
    x0 = xInit(:, 1, min(end, iLoop));
    if isempty(aInitMse) || isequal(opt.initcond, 'fixed')
        Pa0 = zeros(nb);
        Dxinit = zeros(nb, 1);
    else
        Pa0 = aInitMse(:, :, 1, min(iLoop, end));
        Dxinit = diag(xInitMse(:, :, min(iLoop, end)));
    end
    
    % Anticipated and unanticipated shocks.
    ea = eaInp(:, :, min(end, iLoop));
    eu = euInp(:, :, min(end, iLoop));
    
    if isSwap
        % Tunes on measurement variables.
        y = yInp(:, 1:last, min(end, iLoop));
        if opt.dtrends
            y = y - W(:, 1:last);
        end
        % Tunes on transition variables.
        x = xInp(:, 1:last, min(end, iLoop));
        x = x(ixXCurr, :);
    else
        y = nan(ny, last);
        x = nan(nXCurr, last);
    end
    
    % Pre-allocate mean arrays.
    xCurr = nan(nXCurr, nPer);
    
    % Pre-allocate variance arrays.
    if ~opt.meanonly
        Dy = nan(ny, nPer);
        DxCurr = nan(nXCurr, nPer);
        Du = nan(ne, nPer);
        De = nan(ne, nPer);
    end
    
    % Solve the swap system.
    if last > 0
        eu1 = eu(:, 1:last);
        ea1 = ea(:, 1:last);
        const = double(~opt.deviation);
        % inp := [const;a0;vec(eu);vec(ea)].
        inp = [ ...
            const ; ...
            a0(:) ; ...
            eu1(:) ; ...
            ea1(:) ; ...
            ];
        
        % outp := [y;x].
        outp = [ y(:) ; x(:) ];
        
        % Swap exogenised outputs and endogenised inputs.
        % rhs := [inp(~endi);outp(exi)].
        % lhs := [outp(~exi);inp(endi)].
        rhs = [ inp(~ixEndg) ; outp(ixExog) ];
        lhs = M*rhs;
        a = Ma*rhs;
        
        Prhs = [ ];
        if ~opt.meanonly || isCond
            % Prhs is the MSE/Cov matrix of the RHS in the swapped system.
            calcPrhs( );
        end

        Plhs = [ ];
        Pa = [ ];
        if ~opt.meanonly
            % Plhs is the cov matrix of the LHS in the swapped system.
            calcPlhsPa( );
        end
        
        if isCond
            Yd = Y(:, :, min(end, iLoop));
            Yd(~yAnchC) = NaN;
            if opt.dtrends
                Yd = Yd - W(:, 1:last);
            end
            Xd = X(:, :, min(end, iLoop));
            Xd(~xAnchC) = NaN;
            outp = [Yd(:);Xd(:)];
            z = M(ixCondNotExog, :);
            % Prediction error.
            pe = outp(ixCond) - lhs(ixCondNotExog);
            % Update mean forecast.
            upd = simulate.linear.updatemean(z, Prhs, pe);
            rhs = rhs + upd;
            lhs = lhs + M*upd;
            a = a + Ma*upd;
            if ~opt.meanonly
                % Update forecast MSE.
                z = N(ixCondNotExog, :);
                upd = simulate.linear.updatemse(z, Prhs);
                Prhs = Prhs - upd;
                Plhs = Plhs - N*upd*N.';
                Pa = Pa - Na*upd*Na.';
                Prhs = (Prhs+Prhs.')/2;
                Plhs = (Plhs+Plhs.')/2;
                Pa = (Pa+Pa.')/2;
            end
        end
        
        lhsRhs2Yxuea( );
        
    else
        eu = zeros(ne, last);
        ea = zeros(ne, last);
        a = a0;
        if ~opt.meanonly
            Pa = Pa0;
        end
    end
    
    % Forecast between `last+1` and `nper`.
    beyond( );
    
    % Free memory.
    a = [ ];
    Pa = [ ];
    
    % Add measurement detereministic trends.
    if opt.dtrends
        y = y + W;
    end
    
    % Store final results.
    assignOutp( );
    
    if opt.progress
        % Update progress bar.
        update(progress, iLoop/nLoop);
    end
end
% End of main loop.

% Report parameterisation with solutions not available.
chkNanSol( );

% Create output database from hdataobj.
returnOutp( );

return
    



    function chkInitCond( )
        if ~isempty(nanInit)
            utils.error('model:jforecast', ...
                'This initial condition is not available: ''%s''.', ...
                nanInit{:});
        end
    end




    function chkExogenised( )
        % Check for NaNs in exogenised variables, and check the number of
        % exogenised and endogenised data points.
        ix1 = [yAnchX;xAnchX];
        ix2 = [any(isnan(yInp), 3); ...
            any(isnan(xInp(ixXCurr, :, :)), 3)];
        inx = any(ix1 & ix2, 2);
        if any(inx)
            yVec = printSolutionVector(this, 'y');
            xVec = printSolutionVector(this, 'x');
            xVec = xVec(ixXCurr);
            yxVec = [yVec, xVec];
            % Some of the variables are exogenised to NaNs.
            utils.error('model:jforecast', ...
                'This variable is exogenised to NaN: ''%s''.', ...
                yxVec{inx});
        end
        % Check number of exogenised and endogenised data points.
        if nnzexog(opt.plan) ~= nnzendog(opt.plan)
            utils.warning('model:jforecast', ...
                ['The number of exogenised data points (%g) does not match ', ...
                'the number of endogenised data points (%g).'], ...
                nnzexog(opt.plan), nnzendog(opt.plan));
        end
    end 




    function chkOverlap( )
        isWarnOverlap = false;
        if any(Ea(:) ~= 0) && any(eaInp(:) ~= 0)
            eaInp = bsxfun(@plus, eaInp, Ea);
            isWarnOverlap = true;
        end
        if any(Eu(:) ~= 0) && any(euInp(:) ~= 0)
            euInp = bsxfun(@plus, euInp, Eu);
            isWarnOverlap = true;
        end        
        if isWarnOverlap
            utils.warning('model:jforecast', ...
                ['Both input data and conditioning data include ', ...
                'structural shocks, and they will be added up together.']);
        end
    end 




    function calcPrhs( )
        % Prhs is the MSE/Cov matrix of the RHS in the swapped system.
        Prhs = zeros(1+nb+2*ne*last);
        Prhs(1+(1:nb), 1+(1:nb)) = Pa0;
        Pu = covfun.stdcorr2cov(StdcorrU(:, 1:last), ne);
        Pe = covfun.stdcorr2cov(StdcorrA(:, 1:last), ne);
        pos = 1+nb+(1:ne);
        for i = 1 : last
            Prhs(pos, pos) = Pu(:, :, i);
            pos = pos + ne;
        end
        for i = 1 : last
            Prhs(pos, pos) = Pe(:, :, i);
            pos = pos + ne;
        end
        Prhs = Prhs(~ixEndg, ~ixEndg);
        % Add zeros for the std errors of exogenised data points.
        if any(ixExog)
            Prhs = blkdiag(Prhs, zeros(sum(ixExog)));
        end
    end 




    function calcPlhsPa( )
        Plhs = N*Prhs*N.';
        Pa = Na*Prhs*Na.';
        Plhs = (Plhs+Plhs.')/2;
        Pa = (Pa+Pa.')/2;
    end 




    function lhsRhs2Yxuea( )
        outp = zeros((ny+nXCurr)*last, 1);
        inp = zeros((ne+ne)*last, 1);
        outp(~ixExog) = lhs(1:sum(~ixExog));
        outp(ixExog) = rhs(sum(~ixEndg)+1:end);
        inp(~ixEndg) = rhs(1:sum(~ixEndg));
        inp(ixEndg) = lhs(sum(~ixExog)+1:end);
        
        y = reshape(outp(1:ny*last), [ny, last]);
        outp(1:ny*last) = [ ];
        xCurr(:, 1:last) = reshape(outp, [nXCurr, last]);
        outp(1:nXCurr*last) = [ ];
        
        inp(1) = [ ];
        x0 = U*inp(1:nb);
        inp(1:nb) = [ ];
        eu = reshape(inp(1:ne*last), [ne, last]);
        inp(1:ne*last) = [ ];
        ea = reshape(inp(1:ne*last), [ne, last]);
        inp(1:ne*last) = [ ];
        
        if opt.meanonly
            return
        end
        
        Poutp = zeros((ny+nXCurr)*last);
        Pinp = zeros((ne+ne)*last);
        Poutp(~ixExog, ~ixExog) = Plhs(1:sum(~ixExog), 1:sum(~ixExog));
        Poutp(ixExog, ixExog) = Prhs(sum(~ixEndg)+1:end, sum(~ixEndg)+1:end);
        Pinp(~ixEndg, ~ixEndg) = Prhs(1:sum(~ixEndg), 1:sum(~ixEndg));
        Pinp(ixEndg, ixEndg) = Plhs(sum(~ixExog)+1:end, sum(~ixExog)+1:end);
        
        if ny > 0
            pos = 1 : ny;
            for t = 1 : last
                Dy(:, t) = diag(Poutp(pos, pos));
                pos = pos + ny;
            end
            Poutp(1:ny*last, :) = [ ];
            Poutp(:, 1:ny*last) = [ ];
        end
        
        pos = 1 : nXCurr;
        for t = 1 : last
            DxCurr(:, t) = diag(Poutp(pos, pos));
            pos = pos + nXCurr;
        end
        % Poutp(1:nxcurr*last, :) = [ ];
        % Poutp(:, 1:nxcurr*last) = [ ];
        
        Pinp(1, :) = [ ];
        Pinp(:, 1) = [ ];
        Pxinit = U*Pinp(1:nb, 1:nb)*Ut;
        Dxinit = diag(Pxinit);
        Pinp(1:nb, :) = [ ];
        Pinp(:, 1:nb) = [ ];
        
        if ne > 0
            pos = 1 : ne;
            for t = 1 : last
                Du(:, t) = diag(Pinp(pos, pos));
                pos = pos + ne;
            end
            Pinp(1:ne*last, :) = [ ];
            Pinp(:, 1:ne*last) = [ ];
            pos = 1 : ne;
            for t = 1 : last
                De(:, t) = diag(Pinp(pos, pos));
                pos = pos + ne;
            end
        end
        % Pinput(1:ne*last, :) = [ ];
        % Pinput(:, 1:ne*last) = [ ];
    end 




    function beyond( )
        % beyond  Simulate from `last+1` to `nPer`. 
        
        % When expanding the vectors we must use `1:end` and not of just `:` in 1st
        % dimension because of a bug in Matlab causing unexpected behaviour when
        % the original vector is empty.
        xCurr(1:end, last+1:nPer) = 0;
        y(1:end, last+1:nPer) = 0;
        ea(1:end, last+1:nPer) = 0;
        eu(1:end, last+1:nPer) = 0;        
        UCurr = U(ixXbCurr, :);
        TfCurr = Tf(ixXfCurr, :);
        KfCurr = Kf(ixXfCurr, :);
        for t = last+1 : nPer
            xfCurr = TfCurr*a;
            a = Ta*a;
            if ~opt.deviation
                xfCurr = xfCurr + KfCurr;
                a = a + Ka;
            end
            xCurr(:, t) = [xfCurr;UCurr*a];
            if ny > 0
                y(:, t) = Z*a;
                if ~opt.deviation
                    y(:, t) = y(:, t) + D;
                end
            end
        end
        
        if opt.meanonly
            return
        end
        
        Du(1:end, last+1:nPer) = StdcorrU(1:ne, last+1:nPer).^2;
        De(1:end, last+1:nPer) = StdcorrA(1:ne, last+1:nPer).^2;
        RfCurr = Rf(ixXfCurr, :);
        for t = last+1 : nPer
            Pue = covfun.stdcorr2cov(StdcorrU(:, t), ne) ...
                + covfun.stdcorr2cov(StdcorrA(:, t), ne);
            PxfCurr = TfCurr*Pa*TfCurr.' + RfCurr*Pue*RfCurr.';
            Pa = Ta*Pa*Ta.' + Ra*Pue*Ra.';
            PxbCurr = UCurr*Pa*UCurr.';
            DxCurr(:, t) = [diag(PxfCurr);diag(PxbCurr)];
            if ny > 0
                Py = Z*Pa*Z.' + H*Pue*H.';
                Dy(:, t) = diag(Py);
            end
        end
    end 



    
    function chkNanSol( )
        % Report parameterisations with solutions not available.
        if any(ixNanSol)
            utils.warning('model:jforecast', ...
                'Solution(s) not available %s.', ...
                exception.Base.alt2str(ixNanSol) );
        end
    end



    
    function createStdCorr( )
        % TODO: use `combineStdCorr` here.
        % Combine `stdcorr` from the current parameterisation and the
        % `stdcorr` supplied through the tune database.
        stdcorrReal = this.Variant{iLoop}.StdCorr(1, :).';
        stdcorrReal = stdcorrReal(:, ones(1, nPer));
        ixStdcorrReal = ~isnan(opt.stdcorrreal);
        if any(ixStdcorrReal(:))
            stdcorrReal(ixStdcorrReal) = ...
                opt.stdcorrreal(ixStdcorrReal);
        end
        
        stdcorrImag = this.Variant{iLoop}.StdCorr.';
        stdcorrImag = stdcorrImag(:, ones(1, nPer));
        ixStdcorrImag = ~isnan(opt.stdcorrimag);
        if any(ixStdcorrImag(:))
            stdcorrImag(ixStdcorrImag) = ...
                opt.stdcorrimag(ixStdcorrImag);
        end
        
        % Set the std devs of the endogenised shocks to zero. Otherwise an
        % anticipated endogenised shock would have a non-zero unanticipated
        % std dev, and vice versa.
        if isSwap
            temp = stdcorrReal(1:ne, 1:last);
            temp(eaAnchX) = 0;
            temp(euAnchX) = 0;
            stdcorrReal(1:ne, 1:last) = temp;
            temp = stdcorrImag(1:ne, 1:last);
            temp(eaAnchX) = 0;
            temp(euAnchX) = 0;
            stdcorrImag(1:ne, 1:last) = temp;
        end
        
        if opt.anticipate
            StdcorrA = stdcorrReal;
            StdcorrU = stdcorrImag;
        else
            StdcorrA = stdcorrImag;
            StdcorrU = stdcorrReal;
        end            
    end 




    function assignOutp( )
        % Final point forecast.
        outpY = [nan(ny, 1), y];
        
        outpX = nan(nxx, nXPer);
        outpX(ixXCurr, 2:end) = xCurr;
        outpX(nf+1:end, 1) = x0;
        
        if opt.anticipate
            realOutpE = ea;
            imagOutpE = eu;
        else
            realOutpE = eu;
            imagOutpE = ea;
        end
        if all(imagOutpE(:) == 0 | isnan(imagOutpE(:)))
            outpE = [nan(ne, 1), realOutpE];
        else
            outpE = [nan(ne, 1)*(1+1i), complex(realOutpE, imagOutpE)];
        end
        
        outpG = [nan(ng, 1), g];
        
        hdataassign(hData.mean, iLoop, ...
            { outpY, outpX, outpE, [ ], outpG });
        
        % Final std forecast.
        if ~opt.meanonly
            outpDy = [ nan(ny, 1), Dy ];
            outpDx = nan(nxx, nPer);
            outpDx(ixXCurr, :) = DxCurr;
            outpDx = [ [nan(nf, 1);Dxinit], outpDx ];
            if opt.anticipate
                outpDe = De + 1i*Du;
            else
                outpDe = Du + 1i*De;
            end
            outpDe = [ nan(ne, 1), outpDe ];
            outpDg = [ nan(ng, 1), zeros(size(g)) ];
            
            hdataassign(hData.std, iLoop, ...
                { outpDy, outpDx, outpDe, [ ], outpDg });
        end
    end 




    function returnOutp( )
        outp = struct( );
        if opt.meanonly
            outp = hdata2tseries(hData.mean);
        else
            outp.mean = hdata2tseries(hData.mean);
            outp.std = hdata2tseries(hData.std);
        end
    end
end
