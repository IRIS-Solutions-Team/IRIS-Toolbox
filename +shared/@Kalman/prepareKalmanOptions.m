function [opt, timeVarying] = prepareKalmanOptions(this, range, varargin)
% prepareKalmanOptions  Prepare Kalman filter options
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Kalman.prepareKalmanOptions');
    addParameter(pp, 'Anticipate', false, @validate.logicalScalar);
    addParameter(pp, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    addParameter(pp, 'OutputDataAssignFunc', @hdataassign, @(x) isa(x, 'function_handle'));
    addParameter(pp, {'CheckFmse', 'ChkFmse'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Condition', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x));
    addParameter(pp, 'FmseCondTol', eps( ), @(x) isnumeric(x) && isscalar(x) && x>0 && x<1);
    addParameter(pp, {'ReturnCont', 'Contributions'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Rolling', false, @(x) isequal(x, false) || isa(x, 'DateWrapper'));
    addParameter(pp, {'Init', 'InitCond'}, 'Steady', @locallyValidateInitCond);
    addParameter(pp, {'InitUnitRoot', 'InitUnit', 'InitMeanUnit'}, 'FixedUnknown', @(x) isstruct(x) || (ischar(x) && any(strcmpi(x, {'FixedUnknown', 'ApproxDiffuse'}))));
    addParameter(pp, 'LastSmooth', Inf, @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
    addParameter(pp, 'OutOfLik', { }, @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(pp, {'ObjFuncContributions', 'ObjDecomp'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, {'ObjFunc', 'Objective'}, 'loglik', @(x) ischar(x) && any(strcmpi(x, {'loglik', 'mloglik', '-loglik', 'prederr'})));
    addParameter(pp, {'ObjFuncRange', 'ObjectiveSample'}, @all, @(x) isnumeric(x) || isequal(x, @all));
    addParameter(pp, {'Plan', 'Scenario'}, [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x));
    addParameter(pp, 'Progress', false, @validate.logicalScalar);
    addParameter(pp, 'Relative', true, @validate.logicalScalar);
    addParameter(pp, {'Override', 'TimeVarying', 'Vary', 'Std'}, [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, 'Multiply', [ ], @(x) isempty(x) || isstruct(x));
    addParameter(pp, 'Simulate', false, @(x) isequal(x, false) || validate.nestedOptions(x));
    addParameter(pp, 'Weighting', [ ], @isnumeric);
    addParameter(pp, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(pp, 'ReturnStd', true, @validate.logicalScalar);
    addParameter(pp, 'ReturnMSE', true, @validate.logicalScalar);
    addDeviationOptions(pp, false);
end  
parse(pp, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

range = double(range);
startRange = range(1);
endRange = range(end);
range = dater.colon(startRange, endRange);
numPeriods = round(endRange - startRange + 1);
[ny, ~, nb, ~, ~, ~, nz] = sizeSolution(this);


%
% Resolve Override, creating time varying LinearSystem object if necessary
%
timeVarying = hereResolveTimeVarying( );


%
% Anticipation status of in-sample shocks
%
if opt.Anticipate
    opt.AnticipatedFunc = @real;
    opt.UnanticipatedFunc = @imag;
else
    opt.AnticipatedFunc = @imag;
    opt.UnanticipatedFunc = @real;
end


%
% Conditioning upon measurement variables
%
if isempty(opt.Condition) || nz>0
    opt.Condition = [ ];
else
    [~, opt.Condition] = userSelection2Index(this.Quantity, opt.Condition, TYPE(1));
end


%
% Out-of-lik parameters
%
if isempty(opt.OutOfLik)
    opt.OutOfLik = [ ];
else
    if ischar(opt.OutOfLik)
        opt.OutOfLik = regexp(opt.OutOfLik, '\w+', 'match');
    end
    opt.OutOfLik = opt.OutOfLik(:)';
    ell = lookup(this.Quantity, opt.OutOfLik, TYPE(4));
    pos = ell.PosName;
    inxNaN = isnan(pos);
    if any(inxNaN)
        throw( exception.Base('Model:InvalidName', 'error'), ...
               'parameter ', opt.OutOfLik{inxNaN} ); %#ok<GTARG>
    end
    opt.OutOfLik = pos;
end
opt.OutOfLik = reshape(opt.OutOfLik, 1, [ ]);
if numel(opt.OutOfLik)>0 && ~opt.DTrends
    thisError  = [ 
        "Model:CannotEstimateOutOfLik"
        "Cannot estimate out-of-likelihood parameters with the option DTrends=false"
    ];
    throw(exception.Base(thisError, 'error'));
end

%
% Time-varying std and corr
% * --clip means trailing NaNs will be removed
% * --presample means one presample period will be added
%
opt.OverrideStdcorr = [ ];
opt.MultiplyStd = [ ];
if ~isempty(opt.Override) || ~isempty(opt.Multiply)
    [opt.OverrideStdcorr, ~, opt.MultiplyStd] = ...
        varyStdCorr(this, range, opt.Override, opt.Multiply, '--clip', '--presample');
end


%
% Override the means of shocks
%
temp = [ ];
if ~isempty(opt.Override) && validate.databank(opt.Override)
    temp = datarequest('e', this, opt.Override, range);
    if all(temp(:)==0 | isnan(temp(:)))
        temp = [ ];
    end
end
opt.OverrideMean = temp;


% 
% Select the objective function
%
switch lower(opt.ObjFunc)
    case {'prederr'}
        % Weighted prediction errors
        opt.ObjFunc = 2;
        if isempty(opt.Weighting)
            opt.Weighting = sparse(eye(ny));
        elseif numel(opt.Weighting)==1
            opt.Weighting = sparse(eye(ny)*opt.Weighting);
        elseif any( size(opt.Weighting)==1 )
            opt.Weighting = sparse(diag(opt.Weighting(:)));
        end
        if ndims(opt.Weighting) > 2 ...
                || any( size(opt.Weighting)~=ny ) %#ok<ISMAT>
                thisError = { 'Model:InvalidPredErrMatrixSize'
                              'Size of prediction error weighting matrix fails to match number of observables' };
                throw(exception.Base(thisError, 'error'));
        end
    case {'loglik', 'mloglik', '-loglik'}
        % Minus log likelihood
        opt.ObjFunc = 1;
    otherwise
        thisError = { 'Model:UnknownObjFunction'
                      'Unknown objective function: %s ' };
        throw( exception.Base(thisError, 'error'), ...
               opt.ObjFunc );
end


%
% Range on which the objective function will be evaluated. The
% `'ObjFuncRange='` option gives the range from which sample information will
% be used to calculate the objective function and estimate the out-of-lik
% parameters
%
if isequal(opt.ObjFuncRange, @all)
    opt.ObjFuncRange = true(1, numPeriods);
else
    objFuncRange = double(opt.ObjFuncRange);
    firstColumn = max(1, round(objFuncRange(1) - range(1) + 1));
    lastColumn = min(numPeriods, round(objFuncRange(end) - range(1) + 1));
    opt.ObjFuncRange = false(1, numPeriods);
    opt.ObjFuncRange(firstColumn : lastColumn) = true;
end


%
% Initial condition
%
if iscell(opt.Init)
    % Do nothing
elseif isstruct(opt.Init)
    [xbInitMean, listMissingMeanInit, xbInitMse, listMissingMSEInit] = ...
        datarequest('xbInit', this, opt.Init, range);
    if isempty(xbInitMse)
        xbInitMse = zeros(numel(xbInitMean));
    end
    hereCheckNaNInit( );
    opt.Init = {xbInitMean, xbInitMse};
end


%
% Initial condition for unit root components
%
if isstruct(opt.InitUnitRoot)
    [xbInitMean, listMissingMeanInit] = ...
        datarequest('xbInit', this, opt.InitUnitRoot, range);
    listMissingMSEInit = cell.empty(1, 0);
    hereCheckNaNInit( );
    opt.InitUnitRoot = xbInitMean;
end

% Last backward smoothing period. The option  lastsmooth will not be
% adjusted after we add one pre-sample init condition in `kalman`. This
% way, one extra period before user-requested lastsmooth will smoothed, 
% which can be then used in `simulate` or `jforecast`.
if isempty(opt.LastSmooth) || isequal(opt.LastSmooth, Inf)
    opt.LastSmooth = 1;
else
    opt.LastSmooth = round(opt.LastSmooth - range(1)) + 1;
    if opt.LastSmooth>numPeriods
        opt.LastSmooth = numPeriods;
    elseif opt.LastSmooth<1
        opt.LastSmooth = 1;
    end
end

opt.RollingColumns = [ ];
if ~isequal(opt.Rolling, false)
    opt.RollingColumns = rnglen(range(1), opt.Rolling);
    hereCheckRollingColumns( );
end

if ~isequal(opt.Simulate, false)
    herePrepareSimulateSystemProperty( );
end

return


    function timeVarying = hereResolveTimeVarying( )
        timeVarying = [ ];
        if ~isa(this, 'Model')
            return
        end
        if isempty(opt.Override) || ~isstruct(opt.Override) || isempty(fieldnames(opt.Override))
            return
        end
        argin = struct( ...
            'Variant', 1, ...
            'FilterRange', range, ...
            'Override', opt.Override, ...
            'Multiply', opt.Multiply, ...
            'BreakUnlessTimeVarying', true ...
        );
        [timeVarying, initCond] = prepareLinearSystem(this, argin);
        if ~isempty(timeVarying)
            opt.Override = [ ];
            opt.Multiply = [ ];
            opt.Init = initCond;
        end
    end%




    function hereCheckNaNInit( )
        if ~isempty(listMissingMeanInit)
            thisError = { 'Model:MissingMeanInitial'
                          'The value for this mean initial condition is missing from input databank: %s ' };
            throw( exception.Base(thisError, 'error'), ...
                   listMissingMeanInit{:} );
        end
        if ~isempty(listMissingMSEInit)
            thisError = { 'Model:MissingMeanInitial'
                          'The value for this MSE initial condition is missing from input databank: %s ' };
            throw( exception.Base(thisError, 'error'), ...
                   listMissingMSEInit{:} );
        end        
    end%




    function hereCheckRollingColumns( )
        x = opt.RollingColumns;
        assert( all(round(x)==x) && all(x>=1) && all(x<=numPeriods), ...
                'Model:Filter:IllegalRolling', ...
                'Illegal dates specified in option Rolling=' );
    end%




    function herePrepareSimulateSystemProperty( )
        opt.Simulate = simulate( ...
            this, "asynchronous", @auto, ...
            opt.Simulate{:}, "SystemProperty=", "S" ...
        );
    end%
end%


%
% Local Validators
%


function flag = locallyValidateInitCond(x)
    if validate.databank(x)
        flag = true;
        return
    end
    if iscell(x) && numel(x)>=1 && numel(x)<=3 && all(cellfun(@isnumeric, x))
        flag = true;
        return
    end
    if validate.anyString(x, 'Asymptotic', 'Stochastic', 'Steady', 'Fixed', 'FixedUnknown')
        flag = true;
        return
    end
    flag = false;
end%

