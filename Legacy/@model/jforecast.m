function outp = jforecast(this, inp, range, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.jforecast');
    pp.addRequired('SolvedModel', @(x) isa(x, 'model') && length(x)>=1 && ~any(isnan(x, 'solution')));
    pp.addRequired('InputData', @(x) validate.databank(x) || iscell(x));
    pp.addRequired('Range', @validate.date);

    pp.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('CurrentOnly', true, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('InitCond', 'data', @(x) isnumeric(x) || (ischar(x) && any(strcmpi(x, {'data', 'fixed'}))));
    pp.addParameter('InitCondMSE', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && size(x, 1)==size(x, 2)));
    pp.addParameter('MeanOnly', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Precision', 'double', @(x) any(strcmpi(x, {'double', 'single'})));
    pp.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Plan', [ ], @(x) isequal(x, [ ]) || isa(x, 'plan'));
    pp.addParameter('StdScale', complex(1, 0), @(x) (isnumeric(x) && isscalar(x) && real(x)>=0 && imag(x)>=0 && abs(abs(x)-1)<1e-12) || strcmpi(x, 'normalize'));
    pp.addParameter({'Override', 'TimeVarying', 'Vary', 'Std'}, [ ], @(x) isempty(x) || validate.databank(x));
    pp.addParameter('Multiply', [ ], @(x) isempty(x) || validate.databank(x));

    pp.addParameter('Deviation', false, @validate.logicaScalar);
    pp.addParameter('EvalTrends', logical.empty(1, 0));
end
opt = pp.parse(this, inp, range, varargin{:});

if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end

range = double(range);
range = range(1) : range(end);

% Conditioning
isCond = isa(opt.Plan, 'plan') && ~isempty(opt.Plan, 'cond');

% Exogenizing
isSwap = isa(opt.Plan, 'plan') && ~isempty(opt.Plan, 'tunes');

% TODO: Remove 'missing', 'contributions' options from jforecast,
% 'anticipate' scalar.

%--------------------------------------------------------------------------

[ny, nxx, nb, nf, ne, ng] = sizeSolution(this.Vector);

nAlt = length(this);
nPer = length(range);
xRange = range(1)-1 : range(end);
nXPer = length(xRange);

% Current-dated variables in the original state vector.
if opt.CurrentOnly
    ixXCurr = imag(this.Vector.Solution{2})==0;
else
    ixXCurr = true(size(this.Vector.Solution{2}));
end
nXCurr = sum(ixXCurr);
ixXfCurr = ixXCurr(1:nf);
ixXbCurr = ixXCurr(nf+1:end);

% Get initial condition for the xb vector, and check for missing initial
% conditions
[xbInit, listOfNaNInitials, xbInitMse] = datarequest('xbinit', this, inp, range);
% TODO
%{
if ~isequal(opt.InitCondMSE, @auto)
    if isequal(opt.InitCondMSE, 0)
        xbInitMse = zeros(nb);
    elseif size(opt.InitCondMSE, 1)==nb && size(opt.InitCondMSE, 2)==nb
        xbInitMse = opt.InitCondMSE;
    else
        error( 'model:jforecast', ...
               'Invalid size of matrix in option InitCondMSE.' );
    end
end
%}
checkInitCond( );

if opt.Anticipate
    fnAn = @real;
    fnUn = @imag;
else
    fnAn = @imag;
    fnUn = @real;
end

% Get input data for y, current dates of [xf;xb], and e. The size of all
% data is equalized in 3rd dimensin in the `datarequest` function.
[inpY, inpX, inpE] = datarequest('yxe', this, inp, range);
nData = size(inpX, 3);
inpEa = fnAn(inpE);
inpEu = fnUn(inpE);

% Get exogenous variables includig ttrend.
G = datarequest('g', this, inp, range);

% Determine the total number of cycles.
numOfRuns = max([nAlt, size(xbInit, 3), size(xbInitMse, 4), nData, size(G, 3)]);

lastOrZeroFunc = @(x) max([0, find(any(x, 1), 1, 'last')]);

if isSwap || isCond
    % Anchors for exogenized `AnchX` and conditioning `AnchC` variables.
    [yAnchX, xAnchX, eaAnchX, euAnchX, yAnchC, xAnchC] = ...
        myanchors(this, opt.Plan, range, opt.Anticipate);
end

if isSwap
    % Load positions (anchors) of exogenized and endogenized data points.
    xAnchX = xAnchX(ixXCurr, :);
    % Check for NaNs in exogenized variables, and check the number of
    % exogenized and endogenized data points.
    checkExogenizedForNaN( );
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
    % Load conditioning data
    Y = inpY;
    X = inpX;
    xAnchC = xAnchC(ixXCurr, :);
    X = X(ixXCurr, :, :);
    lastYAnchC = lastOrZeroFunc(yAnchC);
    lastXAnchC = lastOrZeroFunc(xAnchC);
    isCond = lastYAnchC > 0 || lastXAnchC > 0;
else
    lastYAnchC = 0;
    lastXAnchC = 0;
end

lastEa = lastOrZeroFunc(any(inpEa~=0, 3));
lastEu = lastOrZeroFunc(any(inpEu~=0, 3));

last = max([lastXAnchX, lastYAnchX, ...
    lastEa, lastEaAnchX, lastEu, lastEuAnchX, ...
    lastYAnchC, lastXAnchC]);

if isSwap
    yAnchX = yAnchX(:, 1:last);
    xAnchX = xAnchX(:, 1:last);
    eaAnchX = eaAnchX(:, 1:last);
    euAnchX = euAnchX(:, 1:last);
    % Indices of exogenized data points and endogenized shocks.
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
    % exogenized positions.
    ixCondNotExog = ixCond(~ixExog);
end

% Index of parameterisation with solutions not available.
[~, inxOfNaNSolutions] = isnan(this, 'solution');

% Create and initialize output hdataobj.
hData = struct( );
hData.mean = hdataobj(this, xRange, numOfRuns, ...
    'Precision', opt.Precision);
if ~opt.MeanOnly
    hData.std = hdataobj(this, xRange, numOfRuns, ...
        'IsVar2Std', true, ...
        'Precision', opt.Precision);
end

if opt.Progress
    % Create progress bar
    progress = ProgressBar('[IrisToolbox] @Model/solve Progress');
end


% /////////////////////////////////////////////////////////////////////////
for iLoop = 1 : numOfRuns

    % Get exogenous data and compute deterministic trends if requested.
    g = G(:, :, min(iLoop, end));
    if opt.EvalTrends
        W = evalTrendEquations(this, [ ], g, iLoop);
    end

    if iLoop<=nAlt
        % Expansion needed to t+k.
        k = max(1, last) - 1;
        this = expand(this, k);
        keepExpansion = true;
        triangular = false;
        [T, R, K, Z, H, D] = getSolutionMatrices(this, iLoop, keepExpansion, triangular);
        Tf = T(1:nf, :);
        Tb = T(nf+1:end, :);
        Rf = R(1:nf, 1:ne);
        Ra = R(nf+1:end, 1:ne);
        Kf = K(1:nf, :);
        Ka = K(nf+1:end, :);
        % Swapped system
        if opt.MeanOnly
            [M, Mxb] = swapForecast(this, iLoop, ixExog, ixEndg, last);
        else
            [M, Mxb, N, Nxb] = swapForecast(this, iLoop, ixExog, ixEndg, last);
        end
        [sxAn, sxUn] = createStdCorr( );
    end

    % Solution not available.
    if inxOfNaNSolutions(min(iLoop, end));
        continue
    end

    % Initial condition
    xb0 = xbInit(:, 1, min(end, iLoop));
    if isempty(xbInitMse) || all(strcmpi(opt.InitCond, 'fixed'))
        Pxb0 = zeros(nb);
        Dxinit = zeros(nb, 1);
    else
        Pxb0 = xbInitMse(:, :, 1, min(iLoop, end));
        Dxinit = diag(Pxb0);
    end

    % Anticipated and unanticipated shocks.
    ea = inpEa(:, :, min(end, iLoop));
    eu = inpEu(:, :, min(end, iLoop));

    if isSwap
        % Tunes on measurement variables.
        y = inpY(:, 1:last, min(end, iLoop));
        if opt.EvalTrends
            y = y - W(:, 1:last);
        end
        % Tunes on transition variables.
        x = inpX(:, 1:last, min(end, iLoop));
        x = x(ixXCurr, :);
    else
        y = nan(ny, last);
        x = nan(nXCurr, last);
    end

    % Pre-allocate mean arrays.
    xCurr = nan(nXCurr, nPer);

    % Pre-allocate variance arrays.
    if ~opt.MeanOnly
        Dy = nan(ny, nPer);
        DxCurr = nan(nXCurr, nPer);
        Du = nan(ne, nPer);
        De = nan(ne, nPer);
    end

    % Solve the swap system.
    if last > 0
        eu1 = eu(:, 1:last);
        ea1 = ea(:, 1:last);
        const = double(~opt.Deviation);
        % inp := [ const; xb0; vec(eu); vec(ea) ]
        inp = [ const
                xb0(:)
                eu1(:)
                ea1(:) ];

        % outp := [y;x].
        outp = [ y(:) ; x(:) ];

        % Swap exogenized outputs and endogenized inputs.
        % rhs := [inp(~endi);outp(exi)].
        % lhs := [outp(~exi);inp(endi)].
        rhs = [ inp(~ixEndg) ; outp(ixExog) ];
        lhs = M*rhs;
        xb = Mxb*rhs;

        Prhs = [ ];
        if ~opt.MeanOnly || isCond
            % Prhs is the MSE/Cov matrix of the RHS in the swapped system.
            calcPrhs( );
        end

        Plhs = [ ];
        Pxb = [ ];
        if ~opt.MeanOnly
            % Plhs is the cov matrix of the LHS in the swapped system.
            calcPlhsPa( );
        end

        if isCond
            Yd = Y(:, :, min(end, iLoop));
            Yd(~yAnchC) = NaN;
            if opt.EvalTrends
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
            xb = xb + Mxb*upd;
            if ~opt.MeanOnly
                % Update forecast MSE.
                z = N(ixCondNotExog, :);
                upd = simulate.linear.updatemse(z, Prhs);
                Prhs = Prhs - upd;
                Plhs = Plhs - N*upd*N.';
                Pxb = Pxb - Nxb*upd*Nxb.';
                Prhs = (Prhs + Prhs')/2;
                Plhs = (Plhs + Plhs')/2;
                Pxb = (Pxb + Pxb')/2;
            end
        end

        lhsRhs2Yxuea( );

    else
        eu = zeros(ne, last);
        ea = zeros(ne, last);
        xb = xb0;
        if ~opt.MeanOnly
            Pxb = Pxb0;
        end
    end

    % Forecast between `last+1` and `nper`.
    beyond( );

    % Free memory.
    xb = [ ];
    Pxb = [ ];

    % Add measurement detereministic trends.
    if opt.EvalTrends
        y = y + W;
    end

    % Store final results.
    assignOutp( );

    if opt.Progress
        % Update progress bar.
        update(progress, iLoop/numOfRuns);
    end
end
% /////////////////////////////////////////////////////////////////////////


% Report parameterisation with solutions not available.
checkNaNSolutions( );

% Create output database from hdataobj.
returnOutp( );

return

    function checkInitCond( )
        if ~isempty(listOfNaNInitials)
            throw( exception.Base('Model:MissingInitCond', 'error'), ...
                   listOfNaNInitials{:} );
        end
    end%




    function checkExogenizedForNaN( )
        % Check for NaNs in exogenized variables, and check the number of
        % exogenized and endogenized data points.
        ix1 = [ yAnchX
                xAnchX ];
        ix2 = [ any(isnan(inpY), 3)
                any(isnan(inpX(ixXCurr, :, :)), 3) ];
        inx = any(ix1 & ix2, 2);
        if any(inx)
            yVec = printSolutionVector(this, 'y');
            xVec = printSolutionVector(this, 'x');
            xVec = xVec(ixXCurr);
            yxVec = [yVec, xVec];
            % Some of the variables are exogenized to NaNs.
            throw( exception.Base('Model:MissingExogenized', 'error'), ...
                   yxVec{inx} );
        end
        % Check number of exogenized and endogenized data points.
        if nnzexog(opt.Plan)~=nnzendog(opt.Plan)
            WARNING_MISMATCH_EXOG_ENDOG = { 'Model:MismatchExogenizedEndogenized'
                                             [ 'Number of exogenized data points (%g) fails to match ', ...
                                               'number of endogenized data points (%g)' ] };
            throw( exception.Base(WARNING_MISMATCH_EXOG_ENDOG, 'warning'), ...
                   nnzexog(opt.Plan), nnzendog(opt.Plan) );
        end
    end%




    function calcPrhs( )
        % Prhs is the MSE/Cov matrix of the RHS in the swapped system.
        Prhs = zeros(1+nb+2*ne*last);
        Prhs(1+(1:nb), 1+(1:nb)) = Pxb0;
        Pu = covfun.stdcorr2cov(sxUn(:, 1:last), ne);
        Pe = covfun.stdcorr2cov(sxAn(:, 1:last), ne);
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
        % Add zeros for the std errors of exogenized data points.
        if any(ixExog)
            Prhs = blkdiag(Prhs, zeros(sum(ixExog)));
        end
    end




    function calcPlhsPa( )
        Plhs = N*Prhs*N.';
        Pxb = Nxb*Prhs*Nxb.';
        Plhs = (Plhs + Plhs')/2;
        Pxb = (Pxb + Pxb')/2;
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
        xb0 = inp(1:nb);
        inp(1:nb) = [ ];
        eu = reshape(inp(1:ne*last), [ne, last]);
        inp(1:ne*last) = [ ];
        ea = reshape(inp(1:ne*last), [ne, last]);
        inp(1:ne*last) = [ ];

        if opt.MeanOnly
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
        Dxinit = diag(Pinp(1:nb, 1:nb));
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
        TfCurr = Tf(ixXfCurr, :);
        KfCurr = Kf(ixXfCurr, :);
        for t = last+1 : nPer
            xfCurr = TfCurr*xb;
            xb = Tb*xb;
            if ~opt.Deviation
                xfCurr = xfCurr + KfCurr;
                xb = xb + Ka;
            end
            xCurr(:, t) = [ xfCurr
                            xb(ixXbCurr, :) ];
            if ny>0
                y(:, t) = Z*xb;
                if ~opt.Deviation
                    y(:, t) = y(:, t) + D;
                end
            end
        end

        if opt.MeanOnly
            return
        end

        Du(1:end, last+1:nPer) = sxUn(1:ne, last+1:nPer).^2;
        De(1:end, last+1:nPer) = sxAn(1:ne, last+1:nPer).^2;
        RfCurr = Rf(ixXfCurr, :);
        for t = last+1 : nPer
            Pue = covfun.stdcorr2cov(sxUn(:, t), ne) ...
                + covfun.stdcorr2cov(sxAn(:, t), ne);
            PxfCurr = TfCurr*Pxb*TfCurr.' + RfCurr*Pue*RfCurr.';
            Pxb = Tb*Pxb*Tb.' + Ra*Pue*Ra.';
            PxbCurr = Pxb(ixXbCurr, ixXbCurr);
            DxCurr(:, t) = [diag(PxfCurr);diag(PxbCurr)];
            if ny > 0
                Py = Z*Pxb*Z.' + H*Pue*H.';
                Dy(:, t) = diag(Py);
            end
        end
    end%




    function checkNaNSolutions( )
        if any(inxOfNaNSolutions)
            throw( exception.Base('Model:SolutionNotAvailable', 'warning'), ...
                   exception.Base.alt2str(inxOfNaNSolutions) );
        end
    end%




    function varargout = createStdCorr( )
        % TODO: use `combineStdCorr` here
        % Combine sx from the current parameterisation and
        % sx supplied in Override= or cond
        optionsHere = struct('Clip', false, 'Presample', false);
        [overrideStdCorrReal, overrideStdCorrImag] ...
            = varyStdCorr(this, range, opt.Override, opt.Multiply, optionsHere);

        stdCorrReal = this.Variant.StdCorr(:, :, iLoop);
        stdCorrReal = repmat(stdCorrReal(:), 1, nPer);
        inxOfNaN = isnan(overrideStdCorrReal);
        if ~all(inxOfNaN(:))
            stdCorrReal(~inxOfNaN) = overrideStdCorrReal(~inxOfNaN);
        end

        stdCorrImag = this.Variant.StdCorr(:, :, iLoop);
        stdCorrImag = repmat(stdCorrImag(:), 1, nPer);
        inxOfNaN = isnan(overrideStdCorrImag);
        if ~all(inxOfNaN(:))
            stdCorrImag(~inxOfNaN) = overrideStdCorrImag(~inxOfNaN);
        end

        % Set the stdevs of endogenized shocks to zero. Otherwise an
        % anticipated endogenized shock would have a non-zero unanticipated
        % stdev, and vice versa.
        if isSwap
            temp = stdCorrReal(1:ne, 1:last);
            temp(eaAnchX) = 0;
            temp(euAnchX) = 0;
            stdCorrReal(1:ne, 1:last) = temp;
            temp = stdCorrImag(1:ne, 1:last);
            temp(eaAnchX) = 0;
            temp(euAnchX) = 0;
            stdCorrImag(1:ne, 1:last) = temp;
        end

        scale = opt.StdScale;
        if strcmpi(scale, 'normalize')
            scale = complex(1/sqrt(2), 1/sqrt(2));
        end
        stdCorrReal = stdCorrReal * real(scale);
        stdCorrImag = stdCorrImag * imag(scale);

        if opt.Anticipate
            varargout = { stdCorrReal, stdCorrImag };
        else
            varargout = { stdCorrImag, stdCorrReal };
        end
    end




    function assignOutp( )
        % Final point forecast.
        outpY = [nan(ny, 1), y];

        outpX = nan(nxx, nXPer);
        outpX(ixXCurr, 2:end) = xCurr;
        outpX(nf+1:end, 1) = xb0;

        if opt.Anticipate
            realOutpE = ea;
            imagOutpE = eu;
        else
            realOutpE = eu;
            imagOutpE = ea;
        end
        if all(imagOutpE(:)==0 | isnan(imagOutpE(:)))
            outpE = [nan(ne, 1), realOutpE];
        else
            outpE = [nan(ne, 1)*(1+1i), complex(realOutpE, imagOutpE)];
        end

        outpG = [nan(ng, 1), g];

        hdataassign(hData.mean, iLoop, ...
            { outpY, outpX, outpE, [ ], outpG });

        % Final std forecast.
        if ~opt.MeanOnly
            outpDy = [ nan(ny, 1), Dy ];
            outpDx = nan(nxx, nPer);
            outpDx(ixXCurr, :) = DxCurr;
            outpDx = [ [nan(nf, 1); Dxinit], outpDx ];
            if opt.Anticipate
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
        if opt.MeanOnly
            outp = hdata2tseries(hData.mean);
        else
            outp.mean = hdata2tseries(hData.mean);
            outp.std = hdata2tseries(hData.std);
        end
    end
end
