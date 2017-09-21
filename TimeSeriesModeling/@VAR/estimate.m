function [this, outp, fitted, Rr, count] = estimate(this, inp, range, varargin)
% estimate  Estimate a reduced-form VAR or BVAR.
%
%
% Syntax
% =======
%
%     [V,VData,Fitted] = estimate(V,Inp,Range,...)
%
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Empty VAR object.
%
% * `Inp` [ struct ] - Input database.
%
% * `Range` [ numeric ] - Estimation range, including `P` pre-sample
% periods, where `P` is the order of the VAR.
%
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Estimated reduced-form VAR object.
%
% * `VData` [ struct ] - Output database with the endogenous
% variables and the estimated residuals.
%
% * `Fitted` [ numeric ] - Dates for which fitted values have been
% calculated.
%
%
% Options
% ========
%
% * `'A='` [ numeric | *empty* ] - Restrictions on the individual values in
% the transition matrix, `A`.
%
% * `'BVAR='` [ numeric ] - Prior dummy observations for estimating a BVAR;
% construct the dummy observations using the one of the `BVAR` functions.
%
% * `'C='` [ numeric | *empty* ] - Restrictions on the individual values in
% the constant vector, `C`.
%
% * `'J='` [ numeric | *empty* ] - Restrictions on the individual values in
% the coefficient matrix in front of exogenous inputs, `J`.
%
% * `'diff='` [ `true` | *`false`* ] - Difference the series before
% estimating the VAR; integrate the series back afterwards.
%
% * `'G='` [ numeric | *empty* ] - Restrictions on the individual values in
% the coefficient matrix in front of the co-integrating vector, `G`.
%
% * `'cointeg='` [ numeric | *empty* ] - Co-integrating vectors (in rows)
% that will be imposed on the estimated VAR.
%
% * `'comment='` [ char | `Inf` ] - Assign comment to the estimated VAR
% object; `Inf` means the existing comment will be preserved.
%
% * `'constraints='` [ char | cellstr ] - General linear constraints on the
% VAR parameters.
%
% * `'constant='` [ *`true`* | `false` ] - Include a constant vector in the
% VAR.
%
% * `'covParam='` [ `true` | *`false`* ] - Calculate and store the
% covariance matrix of estimated parameters.
%
% * `'eqtnByEqtn='` [ `true` | *`false`* ] - Estimate the VAR equation by
% equation.
%
% * `'maxIter='` [ numeric | *`1`* ] - Maximum number of iterations when
% generalised least squares algorithm is involved.
%
% * `'mean='` [ numeric | *empty* ] - Impose a particular asymptotic mean
% on the VAR process.
%
% * `'order='` [ numeric | *`1`* ] - Order of the VAR.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'schur='` [ *`true`* | `false` ] - Calculate triangular (Schur)
% representation of the estimated VAR straight away.
%
% * `'stdize='` [ `true` | *`false`* ] - Adjust the prior dummy
% observations by the std dev of the observations.
%
% * `'timeWeights=`' [ tseries | empty ] - Time series of weights applied
% to individual periods in the estimation range.
%
% * `'tolerance='` [ numeric | *`1e-5`* ] - Convergence tolerance when
% generalised least squares algorithm is involved.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
%
% Options for panel VAR
% ======================
%
% * `'fixedEff='` [ *`true`* | `false` | cellstr ] - Allow for fixed
% effect.
%
% * `'groupSpec='` [ `true` | *`false`* | cellstr ] - Allow for
% group-specific coefficients at exogenous regressors. Values `true` or
% `false` apply to all exogenous regressors en bloc. To allow for
% group-specific coefficients at selected regressors only, assign a list of
% names of exogenous regressors.
%
% * `'groupWeights='` [ numeric | *empty* ] - A 1-by-NGrp vector of weights
% applied to groups in panel estimation, where NGrp is the number of
% groups; the weights will be rescaled so as to sum up to `1`.
%
%
% Description
% ============
%
%
% Estimating a panel VAR
% -----------------------
%
% Panel VAR objects are created by calling the function [`VAR`](VAR/VAR)
% with two input arguments: the list of variables, and the list of group
% names. To estimate a panel VAR, the input data, `Inp`, must be organised
% a super-database with sub-databases for each group, and time series for
% each variables within each group:
%
%     d.Group1_Name.Var1_Name
%     d.Group1_Name.Var2_Name
%     ...
%     d.Group2_Name.Var1_Name
%     d.Group2_Name.Var2_Name
%     ...
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V', @(x) isa(x, 'VAR'));
pp.addRequired('Inp',@(x) myisvalidinpdata(this, x));
pp.addRequired('Range', @isnumeric);
pp.parse(this, inp, range);

if isempty(this.YNames)
    throw( exception.Base('VAR:CANNOT_ESTIMATE_EMPTY_VAR', 'error') );
end

% Pass and validate options.
opt = passvalopt('VAR.estimate',varargin{:});

%--------------------------------------------------------------------------

p = opt.order;
nGrp = max(1, length(this.GroupNames));
kx = length(this.XNames);
ixGroupSpec = resolveGroupSpec( );

% Get input data for estimation; the user range is supposed to **include**
% the pre-sample initial condition.
[inpy, inpx, xRange] = getEstimationData(this, inp, range, p);

% Create components of the LHS and RHS data. Panel VARs create data by
% concatenting individual groups next to each other separated by a total of
% p extra NaNs.
if ~isempty(opt.cointeg)
    opt.diff = true;
end
[y0, k0, x0, y1, g1, ci] = stackData(this, inpy, inpx, ixGroupSpec, opt);

this.Range = xRange;
nXPer = length(xRange);

ng = size(g1, 1);
nk = size(k0, 1);
ny = size(y0, 1);
nx = size(x0, 1); % Total number of rows in x0 depends on kx and ixFixedEff.
nData = size(y0, 3);

if ~isempty(opt.mean)
    if length(opt.mean)==1
        opt.mean = opt.mean(ones(ny, 1));
    else
        opt.mean = opt.mean(:);
    end
end

if ~isempty(opt.mean)
    opt.constant = false;
end

% Read parameter restrictions, and set up their hyperparameter form.
% They are organised as follows:
% * Rr = [R,r],
% * beta = R*gamma + r.
this.Rr = VAR.restrict(ny, nk, nx, ng, opt);

% Get the number of hyperparameters.
if isempty(this.Rr)
    % Unrestricted VAR.
    if ~opt.diff
        % Level VAR.
        this.NHyper = ny*(nk+nx+p*ny+ng);
    else
        % Difference VAR or VEC.
        this.NHyper = ny*(nk+nx+(p-1)*ny+ng);
    end
else
    % Parameter restrictions in the hyperparameter form:
    % beta = R*gamma + r;
    % The number of hyperparams is given by the number of columns of R.
    % The Rr matrix is [R,r], so we need to subtract 1.
    this.NHyper = size(this.Rr,2) - 1;
end

nLoop = nData;

% Estimate reduced-form VAR parameters. The size of coefficient matrices
% will always be determined by p whether this is a~level VAR or
% a~difference VAR.
e0 = nan(ny, size(y0, 2), nLoop);
fitted = cell(1, nLoop);
count = zeros(1, nLoop);

% Pre-allocate VAR matrices.
this = myprealloc(this, ny, p, nXPer, nLoop, ng);

% Create command-window progress bar.
if opt.progress
    progress = ProgressBar('IRIS VAR.estimate progress');
end

% Main loop
%-----------
s = struct( );
s.Rr = this.Rr;
s.ci = ci;
s.order = p;
% Weighted GLSQ; the function is different for VARs and panel VARs, becuase
% Panel VARs possibly combine weights on time periods and weights on groups.
s.w = myglsqweights(this, opt);

for iLoop = 1 : nLoop
    s.y0 = y0(:, :, min(iLoop, end));
    s.y1 = y1(:, :, min(iLoop, end));
    s.k0 = k0(:, :, min(iLoop, end));
    s.x0 = x0(:, :, min(iLoop, end));
    s.g1 = g1(:, :, min(iLoop, end));
    
    % Run generalised least squares.
    s = VAR.myglsq(s,opt);

    % Assign estimated coefficient matrices to the VAR object.
    [this, fitted{iLoop}] = assignEst(this, s, ixGroupSpec, iLoop, opt);
    
    e0(:, :, iLoop) = s.resid;
    count(iLoop) = s.count;

    if opt.progress
        update(progress, iLoop/nLoop);
    end 
end

% Calculate triangular representation.
if opt.schur
    this = schur(this);
end

% Populate information criteria AIC and SBC.
this = infocrit(this);

% Expand output data to match the size of residuals if necessary.
n = size(y0, 3);
if n<nLoop
    y0(:, :, end+1:nLoop) = repmat(y0, 1, 1, nLoop-n);
    if nx>0
        x0(:, :, end+1:nLoop) = repmat(x0, 1, 1, nLoop-n);
    end
end

% Report observations that could not be fitted.
chkObsNotFitted( );

if nargout > 1
    organizeOutpData( );
end

if nargout > 2
    Rr = this.Rr;
end

if ~isequal(opt.comment,Inf)
    this = comment(this, opt.comment);
end

return




    function chkObsNotFitted( )
        allFitted = all(all(this.IxFitted, 1),3);
        if opt.warning && any(~allFitted(p+1:end))
            missing = this.Range(p+1:end);
            missing = missing(~allFitted(p+1:end));
            [~,consec] = datconsecutive(missing);
            utils.warning('VAR:estimate', ...
                ['These periods not fitted ', ...
                'because of missing observations: %s.'], ...
                consec{:});
        end
    end 




    function organizeOutpData( )
        lsyxe = [this.YNames, this.XNames, this.ENames];
        if ispanel(this)
            % Panel VAR
            %-----------
            % `nx` is #row in the array `x`. In panel VARs with fixed effect, each
            % group has its own block of exogenous variables, so that the total row
            % count is #exogenous variables times #groups. The true number of exogenous
            % variables is therefore `nx/nGrp`.
            nGrp = length(this.GroupNames);
            outp = struct( );
            for iiGrp = 1 : nGrp
                yxe = [y0(:, 1:nXPer, :); inpx{iiGrp}; e0(:, 1:nXPer, :)];
                name = this.GroupNames{iiGrp};
                outp.(name) = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
                y0(:, 1:nXPer+p,:) = [ ];
                e0(:, 1:nXPer+p,:) = [ ];
            end
        else
            % Non-panel VAR
            %---------------
            % Get columns 1:nXPer from y0 and e0 because they still include the NaNs at
            % the end used as group separators.
            yxe = [y0(:, 1:nXPer, :); inpx{1}(:, 1:nXPer, :); e0(:, 1:nXPer, :)];
            outp = inp * this.XNames;
            outp = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
        end
        y0 = [ ];
        x0 = [ ];
        e0 = [ ];
    end 




    function ixGroupSpec = resolveGroupSpec( )
        ixGroupSpec = false(1, 1+kx);
        if ~ispanel(this) || nGrp==1 || ...
                ( isequal(opt.fixedeff, false) && isequal(opt.groupspec, false) )
            return
        end
        ixGroupSpec(1) = opt.fixedeff;
        if islogicalscalar(opt.groupspec)
            ixGroupSpec(2:end) = opt.groupspec;
            return
        end
        if ischar(opt.groupspec)
            opt.groupspec = regexp(opt.groupspec, '\w+', 'match');
        end
        for ii = 1 : kx
            name = this.XNames{ii};
            ixGroupSpec(1+ii) = any(strcmpi(opt.groupspec, name));
        end
    end
end
