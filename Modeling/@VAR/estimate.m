function [this, outputData, fitted, Rr, count] = estimate(this, inputData, range, varargin)
% estimate  Estimate reduced-form VAR model
%
%
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('VAR.estimate');
    parser.addRequired('varModel', @(x) isa(x, 'VAR'));
    parser.addRequired('inputData', @(x) myisvalidinpdata(this, x));
    parser.addRequired('range', @DateWrapper.validateProperRangeInput);
    parser.addParameter('Diff', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Order', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('Cointeg', [ ], @isnumeric);
    parser.addParameter('Comment', '', @(x) ischar(x) || isa(x, 'string') || isequal(x, Inf));
    parser.addParameter({'Constraints', 'Constraint'}, '', @(x) ischar(x) || isa(x, 'string') || iscellstr(x) || isnumeric(x));
    parser.addParameter({'Intercept', 'Constant', 'Const', 'Constants'}, true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'CovParameters', 'CovParameter', 'CovParam'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('EqtnByEqtn', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Schur', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'StartDate', 'Start'}, 'Presample', @(x) any(strcmpi(x, {'Presample', 'Fit', 'Fitted'})));
    parser.addParameter('TimeWeights', [ ], @(x) isempty(x) || isa(x, 'tseries'));
    parser.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
    % Parameter constraints
    parser.addParameter('A', [ ], @isnumeric);
    parser.addParameter('C', [ ], @isnumeric);    
    parser.addParameter('G', [ ], @isnumeric);
    parser.addParameter('J', [ ], @isnumeric);
    parser.addParameter('Mean', [ ], @(x) isempty(x) || isnumeric(x));
    parser.addParameter('MaxIter', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('Tolerance', 1e-5, @(x) isnumeric(x) && isscalar(x) && x>0);
    % Prior dummy observations
    parser.addParameter({'PriorDummies', 'BVAR'}, [ ], @(x) isempty(x) || isa(x, 'BVAR.bvarobj'));
    parser.addParameter({'Standardize', 'Stdize'}, false, @(x) isequal(x, true) || isequal(x, false));
    % Panel VAR
    parser.addParameter({'FixedEff', 'FixedEffect'}, true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('GroupWeights', [ ], @(x) isempty(x) || isnumeric(x));
    parser.addParameter('GroupSpec', false, @(x) islogicalscalar(x) || iscellstr(x) || ischar(x));
end
parser.parse(this, inputData, range, varargin{:});
opt = parser.Options;

if isempty(this.NamesEndogenous)
    throw( exception.Base('VAR:CANNOT_ESTIMATE_EMPTY_VAR', 'error') );
end

%--------------------------------------------------------------------------

p = opt.Order;
numGroups = max(1, length(this.GroupNames));
kx = length(this.NamesExogenous);
inxGroupSpec = resolveGroupSpec( );

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
this = myprealloc(this, numEndogenous, p, numExtendedPeriods, numRuns, numCointeg);

% Create command-window progress bar.
if opt.Progress
    progress = ProgressBar('IRIS VAR.estimate progress');
end

% __Main Loop__
s = struct( );
s.Rr = this.Rr;
s.ci = ci;
s.order = p;
% Weighted GLSQ; the function is different for VARs and panel VARs, because
% Panel VARs possibly combine weights on time periods and weights on groups.
s.w = myglsqweights(this, opt);

for iLoop = 1 : numRuns
    s.y0 = y0(:, :, min(iLoop, end));
    s.y1 = y1(:, :, min(iLoop, end));
    s.k0 = k0(:, :, min(iLoop, end));
    s.x0 = x0(:, :, min(iLoop, end));
    s.g1 = g1(:, :, min(iLoop, end));
    
    % Run generalised least squares.
    s = VAR.myglsq(s, opt);

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
            [~, consec] = DateWrapper.reportConsecutive(missing);
            utils.warning('VAR:estimate', ...
                ['These periods have been not fitted ', ...
                'because of missing observations: %s '], ...
                consec{:});
        end
    end 


    function organizeOutpData( )
        lsyxe = [this.NamesEndogenous, this.NamesExogenous, this.NamesErrors];
        if ispanel(this)
            % _Panel VAR_
            % `numExogenous` is #row in the array `x`. In panel VARs with fixed effect, each
            % group has its own block of exogenous variables, so that the total row
            % count is #exogenous variables times #groups. The true number of exogenous
            % variables is therefore `numExogenous/numGroups`.
            numGroups = length(this.GroupNames);
            outputData = struct( );
            for iiGroup = 1 : numGroups
                yxe = [y0(:, 1:numExtendedPeriods, :); inputExogenous{iiGroup}; e0(:, 1:numExtendedPeriods, :)];
                name = this.GroupNames{iiGroup};
                outputData.(name) = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
                y0(:, 1:numExtendedPeriods+p, :) = [ ];
                e0(:, 1:numExtendedPeriods+p, :) = [ ];
            end
        else
            % _Plain VAR_
            % Get columns 1:numExtendedPeriods from y0 and e0 because they still include the NaNs at
            % the end used as group separators.
            yxe = [y0(:, 1:numExtendedPeriods, :); inputExogenous{1}(:, 1:numExtendedPeriods, :); e0(:, 1:numExtendedPeriods, :)];
            outputData = inputData * this.NamesExogenous;
            outputData = myoutpdata(this, this.Range, yxe, [ ], lsyxe);
        end
        y0 = [ ];
        x0 = [ ];
        e0 = [ ];
    end 


    function inxGroupSpec = resolveGroupSpec( )
        inxGroupSpec = false(1, 1+kx);
        if ~ispanel(this) || numGroups==1 || ...
                ( isequal(opt.FixedEff, false) && isequal(opt.GroupSpec, false) )
            return
        end
        inxGroupSpec(1) = opt.FixedEff;
        if islogicalscalar(opt.GroupSpec)
            inxGroupSpec(2:end) = opt.GroupSpec;
            return
        end
        if ischar(opt.GroupSpec)
            opt.GroupSpec = regexp(opt.GroupSpec, '\w+', 'match');
        end
        for ii = 1 : kx
            name = this.NamesExogenous{ii};
            inxGroupSpec(1+ii) = any(strcmpi(opt.GroupSpec, name));
        end
    end
end
