% prepareKalmanOptions  Prepare Kalman filter options
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team
%

% >=R2019b
%{
function [opt, timeVarying] = prepareKalmanOptions2(this, range, options)

arguments
    this
    range 

    options.FlattenOutput (1, 1) logical = true
    options.MatrixFormat (1, 1) string {validate.mustBeMatrixFormat} = "namedMatrix"
    options.OutputData (1, :) string = "smooth"
    options.OutputDataAssignFunc = @hdataassign

    options.Anticipate (1, 1) logical = false
    options.Ahead (1, 1) double = 1
    options.CheckFMSE (1, 1) logical = false
    ...
end
%}
% >=R2019b


function [opt, timeVarying] = prepareKalmanOptions2(this, range, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Kalman.prepareKalmanOptions');

    addParameter(pp, 'MatrixFormat', 'namedmat', @validate.matrixFormat);
    addParameter(pp, {'OutputData', 'Data', 'Output'}, 'smooth', @(x) isstring(x) || ischar(x));
    addParameter(pp, 'FlattenOutput', true, @validate.logicalScalar);

    addParameter(pp, 'Anticipate', false, @validate.logicalScalar);
    addParameter(pp, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    addParameter(pp, 'OutputDataAssignFunc', @hdataassign, @(x) isa(x, 'function_handle'));
    addParameter(pp, {'CheckFmse', 'ChkFmse'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Condition', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x));
    addParameter(pp, 'FmseCondTol', eps( ), @(x) isnumeric(x) && isscalar(x) && x>0 && x<1);
    addParameter(pp, {'ReturnBreakdown', 'Contributions'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Rolling', false, @(x) isequal(x, false) || isa(x, 'DateWrapper'));
    addParameter(pp, {'Initials', 'Init', 'InitCond'}, 'Steady', @locallyValidateInitCond);
    addParameter(pp, {'InitUnitRoot', 'InitUnit', 'InitMeanUnit'}, 'approxDiffuse', @(x) isstruct(x) || ((ischar(x) || isstring(x)) && ismember(lower(string(x)), lower(["fixedUnknown", "approxDiffuse"]))));
    addParameter(pp, 'LastSmooth', Inf, @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
    addParameter(pp, 'OutOfLik', { }, @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(pp, {'ObjFuncContributions', 'ObjDecomp'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, {'ObjFunc', 'Objective'}, 'loglik', @(x) ischar(x) && any(strcmpi(x, {'loglik', 'mloglik', '-loglik', 'prederr'})));
    addParameter(pp, {'ObjFuncRange', 'ObjectiveSample'}, @all, @(x) isnumeric(x) || isequal(x, @all));
    addParameter(pp, {'Plan', 'Scenario'}, [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x));
    addParameter(pp, 'Progress', false, @validate.logicalScalar);
    addParameter(pp, 'Relative', false, @validate.logicalScalar);
    addParameter(pp, {'Override', 'TimeVarying', 'Vary', 'Std'}, [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, 'Multiply', [ ], @(x) isempty(x) || isstruct(x));
    addParameter(pp, 'Simulate', false, @(x) isequal(x, false) || validate.nestedOptions(x));
    addParameter(pp, 'Weighting', [ ], @isnumeric);
    addParameter(pp, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(pp, 'MedianOnly', false, @validate.logicalScalar);
    addParameter(pp, 'ReturnStd', true, @validate.logicalScalar);
    addParameter(pp, 'ReturnMedian', logical.empty(1, 0));
    addParameter(pp, 'ReturnMSE', true, @validate.logicalScalar);
    addDeviationOptions(pp, false);
end
opt = parse(pp, varargin{:});

range = double(range);
startRange = range(1);
endRange = range(end);
range = dater.colon(startRange, endRange);
numPeriods = round(endRange - startRange + 1);
[ny, ~, numXb, ~, ~, ~, nz] = sizeSolution(this);


opt.ReturnMedian = locallyResolveMedianOption(this, opt.ReturnMedian);


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
if isempty(opt.OutOfLik)
    opt.OutOfLik = [ ];
else
    if ischar(opt.OutOfLik)
        opt.OutOfLik = regexp(opt.OutOfLik, '\w+', 'match');
    end
    opt.OutOfLik = opt.OutOfLik(:)';
    ell = lookup(this.Quantity, cellstr(opt.OutOfLik), 4);
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
optionsHere = struct("Clip", true, "Presample", true);
if ~isempty(opt.Override) || ~isempty(opt.Multiply)
    [opt.OverrideStdcorr, ~, opt.MultiplyStd] = varyStdCorr( ...
        this, range, opt.Override, opt.Multiply ...
        , optionsHere ...
    );
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
% User-supplied initials is a 1-by-2 cell array with a mean vector and an MSE
% matrix.
%
if iscell(opt.Initials)
    xbVector = getBackwardSolutionVector(this.Vector);
    maxLag = min([imag(xbVector), 0]) - 1;
    presampleDates = dater.plus(range(1), maxLag:-1);
    if validate.databank(opt.Initials{1})
        if numXb>0
            names = textual.stringify(this.Quantity.Name);
            numQuantities = numel(names);
            inxXb = false(1, numQuantities);
            inxXb(real(xbVector)) = true;
            xbNames = textual.stringify(names(inxXb));
            xbLogNames = textual.stringify(names(inxXb & this.Quantity.InxLog));
            context = "";
            dbInfo = checkInputDatabank( ...
                this, opt.Initials{1}, range ...
                , string.empty(1, 0), xbNames ...
                , string.empty(1, 0), xbLogNames ...
                , context ...
            );

            names(~inxXb) = missing;
            array = requestData(this, dbInfo, opt.Initials{1}, names, presampleDates);
            linx = sub2ind(size(array), real(xbVector), imag(xbVector)-maxLag);
            opt.Initials{1} = reshape(double(array(linx)), numXb, 1);
        else
            opt.Initials{1} = double.empty(0, 1);
        end
    elseif ~isempty(opt.Initials{1})
        opt.Initials{1} = reshape(double(opt.Initials{1}), numXb, 1);
    end

    if isa(opt.Initials{2}, 'Series') && iscell(opt.Initials{2}.Data)
        x = getData(opt.Initials{2}, presampleDates(end));
        opt.Initials{2} = reshape(x{1}, numXb, numXb);
    elseif isequal(opt.Initials{2}, 0)
        opt.Initials{2} = zeros(numXb, numXb);
    elseif ~isempty(opt.Initials{2})
        opt.Initials{2} = reshape(opt.Initials{2}, numXb, numXb);
    end
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
    opt.RollingColumns = dater.rangeLength(range(1), opt.Rolling);
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
        if isempty(opt.Override) || ~validate.databank(opt.Override) || isempty(fieldnames(opt.Override))
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


    function hereCheckRollingColumns( )
        x = opt.RollingColumns;
        assert( all(round(x)==x) && all(x>=1) && all(x<=numPeriods), ...
                'Model:Filter:IllegalRolling', ...
                'Illegal dates specified in option Rolling=' );
    end%


    function herePrepareSimulateSystemProperty( )
        opt.Simulate = simulate( ...
            this, "asynchronous", @auto, ...
            opt.Simulate{:}, "SystemProperty", "S" ...
        );
    end%
end%

%
% Local functions
%

function flag = locallyResolveMedianOption(this, flag)
    %(
    if ~isempty(flag)
        return
    end
    flag = hasLogVariables(this);
    %)
end%

%
% Local Validators
%

function flag = locallyValidateInitCond(x)
    if iscell(x) && any(numel(x)==[2, 3])
        return
    end
    if validate.anyString(x, 'Asymptotic', 'Stochastic', 'Steady', 'Fixed', 'FixedUnknown')
        flag = true;
        return
    end
    flag = false;
end%



