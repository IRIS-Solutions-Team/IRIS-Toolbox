% estimate  Estimate reduced-form VAR model
%{
% __Syntax__
%
%     [varModel, VData, Fitted] = estimate(varModel, inputData, range, ...)
%
%
% __Input Arguments__
%
% * `varModel` [ VAR ] - VAR model object.
%
% * `inputData` [ struct ] - Input databank.
%
% * `range` [ numeric ] - Estimation range, including `P` pre-sample
% periods, where `P` is the order of the VAR.
%
%
% __Output Arguments__
%
% * `varModel` [ VAR ] - Estimated reduced-form VAR object.
%
% * `VData` [ struct ] - Output database with the endogenous
% variables and the estimated residuals.
%
% * `Fitted` [ numeric ] - Dates for which fitted values have been
% calculated.
%
%
% __Options__
%
% * `Diff=false` [ `true` | `false` ] - Difference the series before
%  estimating the VAR; integrate the series back afterwards.
%
% * `Cointeg=[ ]` [ numeric | empty ] - Co-integrating vectors (in rows)
%  that will be imposed on the estimated VAR.
%
% * `Comment=Inf` [ char | `Inf` ] - Assign comment to the estimated VAR
% object; `Inf` means the existing comment will be preserved.
%
% * `Intercept=true` [ `true` | `false` ] - Include an intercept in the
% VAR equations.
%
% * `CovParam=false` [ `true` | `false` ] - Calculate and store the
%  covariance matrix of estimated parameters.
%
% * `EqtnByEqtn=false` [ `true` | `false` ] - Estimate the VAR equation by
%  equation.
%
% * `Order=1` [ numeric ] - Order of the VAR (number of lags of endogenous
% variables included on the RHS).
%
% * `Progress=false` [ `true` | `false` ] - Display progress bar in the
% command window.
%
% * `Schur=true` [ `true` | `false` ] - Calculate triangular (Schur)
% representation of the estimated VAR immediately.
%
% * `TimeWeights=[ ]` [ tseries | empty ] - Time series with weights
% applied to individual periods in the estimation range.
%
% * `Warning=true` [ `true` | `false` ] - Display warnings produced by this
% function.
%
%
% _Options for Parameter Constraints_
%
% * `A=[ ]` [ numeric | empty ] - Restrictions on the individual values in
% the transition matrix, `A`.
%
% * `C=[ ]` [ numeric | empty ] - Restrictions on the individual values in
% the constant vector, `C`.
%
% * `Constraints=''` [ char | cellstr | empty ] - General linear
% constraints on the VAR parameters.
%
% * `J=[ ]` [ numeric | empty ] - Restrictions on the individual values in
% the coefficient matrix in front of exogenous inputs, `J`.
%
% * `G=[ ]` [ numeric | empty ] - Restrictions on the individual values in
% the coefficient matrix in front of the co-integrating vector, `G`.
%
% * `MaxIter=1` [ numeric ] - Maximum number of iterations when generalized
%  least squares algorithm is used (estimation with parameter constraints).
%
%  `Mean=[ ]` [ numeric | empty ] - Impose a particular asymptotic mean
% on the VAR process.
%
% * `Tolerance=1e-5` [ numeric ] - Convergence tolerance when generalized
% least squares algorithm is used.
%
%
% _Options for Prior Dummy Observations_
%
% * `PriorDummies=[ ]` [ numeric | empty ] - Prior dummy observations for
% estimating a quasi-Bayesian VAR; construct the dummy observations using
% the one of the `BVAR` functions.
%
% * `Standardize=false` [ `true` | `false` ] - Adjust the prior dummy
% observations by the std dev of the observations.
%
%
% _Options for Panel VAR_
%
% * `FixedEff=true` [ `true` | `false` | cellstr ] - Allow for fixed
% effect.
%
% * `GroupSpec=false` [ `true` | `false` | cellstr ] - Allow for
% group-specific coefficients at exogenous regressors. Values `true` or
% `false` apply to all exogenous regressors en bloc. To allow for
% group-specific coefficients at selected regressors only, assign a list of
% names of exogenous regressors.
%
% * `GroupWeights=[ ]` [ numeric | empty ] - A 1-by-NGrp vector of weights
% applied to groups in panel estimation, where NGrp is the number of
% groups; the weights will be rescaled to add up to `1`.
%
%
% __Description__
%
%
% _Estimating a Panel VAR_
%
% Panel VAR objects are created by calling the function [`VAR`](VAR/VAR)
% with two input arguments: the list of variables, and the list of group
% names. To estimate a panel VAR, the input data, `inputData`, must be organised
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
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


function [this, outputData, fitted, Rr, count] = estimate(this, inputData, range, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    addRequired(ip, 'varModel', @(x) isa(x, 'VAR'));
    addRequired(ip, 'inputData', @validate.databank);
    addRequired(ip, 'range', @validate.properRange);

    addParameter(ip, 'Diff', false, @validate.logicalScalar);
    addParameter(ip, 'Order', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x, 0, intmax( )));
    addParameter(ip, 'Cointeg', [ ], @isnumeric);
    addParameter(ip, 'Comment', '', @(x) ischar(x) || isa(x, 'string') || isequal(x, Inf));
    addParameter(ip, {'Constraints', 'Constraint'}, '', @(x) ischar(x) || isa(x, 'string') || iscellstr(x) || isnumeric(x));
    addParameter(ip, {'Intercept', 'Constant', 'Const', 'Constants'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    addParameter(ip, {'CovParameters', 'CovParameter', 'CovParam'}, false, @validate.logicalScalar);
    addParameter(ip, 'EqtnByEqtn', false, @validate.logicalScalar);
    addParameter(ip, 'Progress', false, @validate.logicalScalar);
    addParameter(ip, 'Schur', true, @validate.logicalScalar);
    addParameter(ip, {'StartDate', 'Start'}, 'Presample', @(x) validate.anyString(x, 'Presample', 'Fit', 'Fitted'));
    addParameter(ip, 'TimeWeights', [ ], @(x) isempty(x) || isa(x, 'Series | update'));
    addParameter(ip, 'Warning', true, @validate.logicalScalar);
    addParameter(ip, 'SmallSampleCorrection', false, @validate.logicalScalar);

    addParameter(ip, 'A', [ ], @isnumeric);
    addParameter(ip, 'C', [ ], @isnumeric);
    addParameter(ip, 'G', [ ], @isnumeric);
    addParameter(ip, 'J', [ ], @isnumeric);
    addParameter(ip, 'Mean', [ ], @(x) isempty(x) || isnumeric(x));
    addParameter(ip, 'MaxIter', 1, @(x) validate.roundScalar(x, 0, Inf));
    addParameter(ip, 'Tolerance', 1e-5, @(x) validate.numericScalar(x, eps( ), Inf));

    addParameter(ip, 'Dummy', {}, @(x) iscell(x) || isa(x, 'dummy.Base'));
    addParameter(ip, {'LegacyDummy', 'PriorDummies', 'BVAR'}, [], @(x) isempty(x) || isa(x, 'BVAR.DummyWrapper'));

    addParameter(ip, {'Standardize', 'Stdize'}, false, @validate.logicalScalar);

    addParameter(ip, {'FixedEff', 'FixedEffect'}, true, @validate.logicalScalar);
    addParameter(ip, 'GroupWeights', [ ], @(x) isempty(x) || isnumeric(x));
    addParameter(ip, 'GroupSpec', false, @(x) validate.logicalScalar(x) || isstring(x) || iscellstr(x) || ischar(x));
end
parse(ip, this, inputData, range, varargin{:});
opt = ip.Results;


if isempty(this.EndogenousNames)
    throw( exception.Base('VAR:CANNOT_ESTIMATE_EMPTY_VAR', 'error') );
end

p = here_resolveOrder( );
this.Order = p;
opt.Order = p;

isIntercept = here_resolveIntercept( );
this.Intercept = isIntercept;
opt.Intercept = isIntercept;

kx = this.NumExogenous;
inxGroupSpec = resolveGroupSpec();

if ~isempty(opt.A) && p>1 && size(opt.A, 3)==1
    opt.A = repmat(opt.A, 1, 1, p);
end


% Get input data for estimation and determine extended range (including
% pre-sample)
[inputEndogenous, inputExogenous, extendedRange] = getEstimationData(this, inputData, range, p, opt.StartDate);

% Create components of the LHS and RHS data. Panel VARs create data by
% concatenting individual groups next to each other separated by a total of
% p extra NaNs.
if ~isempty(opt.Cointeg)
    opt.Diff = true;
end
[y0, k0, x0, y1, g1, ci] = stackData(this, inputEndogenous, inputExogenous, inxGroupSpec, opt);

this.Range = extendedRange;
numExtendedPeriods = length(extendedRange);

numCointeg = size(g1, 1);
numIntercepts = size(k0, 1);
numEndogenous = size(y0, 1);
numExogenous = size(x0, 1); % Total number of rows in x0 depends on kx and ixFixedEff.
numDataSets = size(y0, 3);

if ~isempty(opt.Mean)
    if length(opt.Mean)==1
        opt.Mean = opt.Mean(ones(numEndogenous, 1));
    else
        opt.Mean = opt.Mean(:);
    end
end

if ~isempty(opt.Mean)
    opt.Intercept = false;
    this.Intercept = false;
end

% Read parameter restrictions, and set up their hyperparameter form.
% They are organised as follows:
% * Rr = [R, r],
% * beta = R*gamma + r.
this.Rr = VAR.restrict(numEndogenous, numIntercepts, numExogenous, numCointeg, opt);

% Get the number of hyperparameters.
if isempty(this.Rr)
    % Unrestricted VAR.
    if ~opt.Diff
        % Level VAR
        this.NHyper = numEndogenous*(numIntercepts+numExogenous+p*numEndogenous+numCointeg);
    else
        % Difference VAR or VEC
        this.NHyper = numEndogenous*(numIntercepts+numExogenous+(p-1)*numEndogenous+numCointeg);
    end
else
    % Parameter restrictions in the hyperparameter form:
    % beta = R*gamma + r;
    % The number of hyperparams is given by the number of columns of R.
    % The Rr matrix is [R, r], so we need to subtract 1.
    this.NHyper = size(this.Rr, 2) - 1;
end

numRuns = numDataSets;

% Estimate reduced-form VAR parameters. The size of coefficient matrices
% will always be determined by p whether this is a~level VAR or
% a~difference VAR.
e0 = nan(numEndogenous, size(y0, 2), numRuns);
fitted = cell(1, numRuns);
count = zeros(1, numRuns);

% Pre-allocate VAR matrices.
this = preallocate(this, numEndogenous, p, numExtendedPeriods, numRuns, numCointeg);

% Create command-window progress bar
if opt.Progress
    progress = ProgressBar('[IrisToolbox] @VAR/estimate Progress');
end

% __Main Loop__
s = struct( );
s.Rr = this.Rr;
s.ci = ci;
s.order = p;
% Weighted GLSQ; the function is different for VARs and panel VARs, because
% Panel VARs possibly combine weights on time periods and weights on groups.
s.w = prepareLsqWeights(this, opt);

for iLoop = 1 : numRuns
    s.y0 = y0(:, :, min(iLoop, end));
    s.y1 = y1(:, :, min(iLoop, end));
    s.k0 = k0(:, :, min(iLoop, end));
    s.x0 = x0(:, :, min(iLoop, end));
    s.g1 = g1(:, :, min(iLoop, end));


    % Evaluate prior dummy observation matrices
    dummyStruct = dummy.Base.evalCollection(opt.Dummy, this);
    if isempty(opt.Dummy) && isa(opt.LegacyDummy, 'BVAR.DummyWrapper')
        dummyStruct = local_evalLegacyDummy(this, dummyStruct, opt.LegacyDummy);
    end


    % Run generalised least squares
    s = VAR.generalizedLsq(s, dummyStruct, opt);


    % Assign estimated coefficient matrices to the VAR object.
    [this, fitted{iLoop}] = assignEst(this, s, inxGroupSpec, iLoop, opt);

    e0(:, :, iLoop) = s.resid;
    count(iLoop) = s.count;

    if opt.Progress
        update(progress, iLoop/numRuns);
    end
end

% Calculate triangular representation.
if opt.Schur
    this = schur(this);
end

% Populate information criteria AIC and SBC.
this = infocrit(this);

% Expand output data to match the size of residuals if necessary.
n = size(y0, 3);
if n<numRuns
    y0(:, :, end+1:numRuns) = repmat(y0, 1, 1, numRuns-n);
    if numExogenous>0
        x0(:, :, end+1:numRuns) = repmat(x0, 1, 1, numRuns-n);
    end
end

% Report observations that could not be fitted.
chkObsNotFitted( );

if nargout>1
    organizeOutpData( );
end

if nargout>2
    Rr = this.Rr;
end

if ~isequal(opt.Comment, Inf)
    this = comment(this, opt.Comment);
end

return


    function chkObsNotFitted( )
        allFitted = all(all(this.IxFitted, 1), 3);
        if opt.Warning && any(~allFitted(p+1:end))
            missing = this.Range(p+1:end);
            missing = missing(~allFitted(p+1:end));
            [~, s] = dater.reportConsecutive(missing);
            utils.warning('VAR:estimate', ...
                ['These periods have been not fitted ', ...
                'because of missing observations: %s '], ...
                join(s, " "));
        end
    end


    function organizeOutpData( )
        lsyxe = [this.EndogenousNames, this.ExogenousNames, this.ResidualNames];
        if this.IsPanel
            % _Panel VAR_
            % `numExogenous` is #row in the array `x`. In panel VARs with fixed effect, each
            % group has its own block of exogenous variables, so that the total row
            % count is #exogenous variables times #groups. The true number of exogenous
            % variables is therefore `numExogenous/numGroups`.
            outputData = struct( );
            for iiGroup = 1 : this.NumGroups
                yxe = [y0(:, 1:numExtendedPeriods, :); inputExogenous{iiGroup}; e0(:, 1:numExtendedPeriods, :)];
                name = this.GroupNames(iiGroup);
                outputData.(name) = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
                y0(:, 1:numExtendedPeriods+p, :) = [ ];
                e0(:, 1:numExtendedPeriods+p, :) = [ ];
            end
        else
            % _Plain VAR_
            % Get columns 1:numExtendedPeriods from y0 and e0 because they still include the NaNs at
            % the end used as group separators.
            yxe = [y0(:, 1:numExtendedPeriods, :); inputExogenous{1}(:, 1:numExtendedPeriods, :); e0(:, 1:numExtendedPeriods, :)];
            outputData = databank.copy(inputData, "SourceNames", this.ExogenousNames);
            outputData = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
        end
        y0 = [ ];
        x0 = [ ];
        e0 = [ ];
    end


    function inxGroupSpec = resolveGroupSpec( )
        islogicalscalar = @(x) islogical(x) && isscalar(x);
        inxGroupSpec = false(1, 1+kx);
        if ~this.IsPanel || this.NumGroups==1 || ...
                ( isequal(opt.FixedEff, false) && isequal(opt.GroupSpec, false) )
            return
        end
        inxGroupSpec(1) = opt.FixedEff;
        if islogicalscalar(opt.GroupSpec)
            inxGroupSpec(2:end) = opt.GroupSpec;
            return
        end
        if isstring(opt.GroupSpec) || ischar(opt.GroupSpec)
            opt.GroupSpec = regexp(opt.GroupSpec, '\w+', 'match');
        end
        for ii = 1 : kx
            name = this.ExogenousNames(ii);
            inxGroupSpec(1+ii) = any(strcmpi(opt.GroupSpec, name));
        end
    end%


    function order = here_resolveOrder( )
        if isequal(opt.Order, @auto)
            order = this.Order;
        else
            order = opt.Order;
        end
    end%


    function isIntercept = here_resolveIntercept( )
        if isequal(opt.Intercept, @auto)
            isIntercept = this.Intercept;
        else
            isIntercept = opt.Intercept;
        end
    end%
end%


%
% Local functions
%

function dummyStruct = local_evalLegacyDummy(this, dummyStruct, legacyDummyInput)
    %(
    numY = numel(this.EndogenousNames);
    numK = nnz(this.Intercept);
    numX = numel(this.ExogenousNames);
    numG = NaN;
    order = this.Order;

    dummyStruct.Y = legacyDummyInput.y0(numY, order, numG, numK); 
    dummyStruct.K = legacyDummyInput.k0(numY, order, numG, numK); 
    dummyStruct.Z = legacyDummyInput.y1(numY, order, numG, numK); 
    dummyStruct.NumDummyColumns = size(dummyStruct.Y, 2); 
    dummyStruct.X = zeros(numX, dummyStruct.NumDummyColumns); 
    %)
end%

