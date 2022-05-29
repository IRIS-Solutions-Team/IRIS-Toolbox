% prepareKalmanOptions  Prepare Kalman filter options
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team
%
function [opt, timeVarying] = prepareKalmanOptions(this, range, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('@Kalman.prepareKalmanOptions');

    addParameter(ip, 'MatrixFormat', 'namedmat', @validate.matrixFormat);
    addParameter(ip, {'OutputData', 'Data', 'Output'}, 'smooth', @(x) isstring(x) || ischar(x));
    addParameter(ip, 'InternalAssignFunc', @hdataassign, @(x) isa(x, 'function_handle'));
    addParameter(ip, 'DiffuseScale', iris.mixin.Kalman.DIFFUSE_SCALE);

    addParameter(ip, 'Anticipate', false, @validate.logicalScalar);
    addParameter(ip, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    addParameter(ip, 'Contributions', false, @(x) isequal(x, true) || isequal(x, false));

    addParameter(ip, {'CheckFmse', 'ChkFmse'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'FmseCondTol', eps( ), @(x) isnumeric(x) && isscalar(x) && x>0 && x<1);

    addParameter(ip, 'Condition', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x));

    addParameter(ip, {'Initials', 'Init', 'InitCond'}, 'Steady', @locallyValidateInitCond);
    addParameter(ip, {'UnitRootInitials', 'InitUnitRoot', 'InitUnit', 'InitMeanUnit'}, 'fixedUnknown', @(x) isstruct(x) || ((ischar(x) || isstring(x)) && ismember(lower(string(x)), lower(["fixedUnknown", "approxDiffuse"]))));

    addParameter(ip, 'LastSmooth', Inf, @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
    addParameter(ip, {'Outlik', 'OutOfLik'}, { }, @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(ip, {'ReturnObjFuncContribs', 'ObjDecomp'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, {'ObjFunc', 'Objective'}, 'loglik', @(x) ischar(x) && any(strcmpi(x, {'loglik', 'mloglik', '-loglik', 'prederr'})));
    addParameter(ip, {'ObjFuncRange', 'ObjectiveSample'}, @all, @(x) isnumeric(x) || isequal(x, @all));
    addParameter(ip, {'Plan', 'Scenario'}, [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x));
    addParameter(ip, 'Deviation', false, @validate.logicalScalar);
    addParameter(ip, {'EvalTrends', 'DTrends', 'DTrend'}, logical.empty(1, 0));
    addParameter(ip, 'Progress', false, @validate.logicalScalar);
    addParameter(ip, 'Relative', true, @validate.logicalScalar);
    addParameter(ip, {'Override', 'TimeVarying', 'Vary', 'Std'}, [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(ip, 'Multiply', [ ], @(x) isempty(x) || isstruct(x));
    addParameter(ip, 'Simulate', false, @(x) isequal(x, false) || validate.nestedOptions(x));
    addParameter(ip, 'Weighting', [ ], @isnumeric);
    addParameter(ip, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(ip, 'ReturnStd', true, @validate.logicalScalar);
    addParameter(ip, 'ReturnMse', true, @validate.logicalScalar);
end  
opt = parse(ip, varargin{:});

if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end

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
    [~, opt.Condition] = userSelection2Index(this.Quantity, opt.Condition, 1);
end


%
% Out-of-lik parameters
%
if isempty(opt.Outlik)
    opt.Outlik = [ ];
else
    if ischar(opt.Outlik)
        opt.Outlik = regexp(opt.Outlik, '\w+', 'match');
    end
    opt.Outlik = opt.Outlik(:)';
    ell = lookup(this.Quantity, cellstr(opt.Outlik), 4);
    pos = ell.PosName;
    inxNaN = isnan(pos);
    if any(inxNaN)
        throw( exception.Base('Model:InvalidName', 'error'), ...
               'parameter ', opt.Outlik{inxNaN} ); %#ok<GTARG>
    end
    opt.Outlik = pos;
end
opt.Outlik = reshape(opt.Outlik, 1, [ ]);
if numel(opt.Outlik)>0 && ~opt.EvalTrends
    thisError  = [ 
        "Model:CannotEstimateOutlik"
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
    optionsHere = struct('Clip', true, 'Presample', true);
    [opt.OverrideStdcorr, ~, opt.MultiplyStd] = ...
        varyStdCorr(this, range, opt.Override, opt.Multiply, optionsHere);
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
if iscell(opt.Initials)
    % Do nothing
elseif isstruct(opt.Initials)
    [xbInitMean, listMissingMeanInit, xbInitMse, listMissingMSEInit] = ...
        datarequest('xbInit', this, opt.Initials, range);
    if isempty(xbInitMse)
        xbInitMse = zeros(numel(xbInitMean));
    end
    hereCheckNaNInit( );
    opt.Initials = {xbInitMean, xbInitMse};
end


%
% Initial condition for unit root components
%
if isstruct(opt.UnitRootInitials)
    [xbInitMean, listMissingMeanInit] = ...
        datarequest('xbInit', this, opt.UnitRootInitials, range);
    listMissingMSEInit = cell.empty(1, 0);
    hereCheckNaNInit( );
    opt.UnitRootInitials = xbInitMean;
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
        [timeVarying, initCond] = prepareLinearSystem( ...
            this, range, opt.Override, opt.Multiply ...
            , "variant", 1 ...
            , "returnEarly", true ...
        );
        if ~isempty(timeVarying)
            opt.Override = [];
            opt.Multiply = [];
            opt.Initials = initCond;
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




    function herePrepareSimulateSystemProperty( )
        opt.Simulate = simulate( ...
            this, "asynchronous", @auto, ...
            opt.Simulate{:}, "systemProperty", "S" ...
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



