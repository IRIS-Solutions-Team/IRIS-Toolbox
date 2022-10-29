% prepareKalmanOptions2 Prepare Kalman filter options

% >=R2019b
%{
function opt = prepareKalmanOptions2(this, range, opt)

arguments
    this iris.mixin.Kalman
    range double

    opt.Persist (1, 1) logical = false
    opt.FlatOutput (1, 1) logical = true
    opt.MatrixFormat (1, 1) string {validate.mustBeMatrixFormat} = "namedMatrix"
    opt.OutputData (1, :) string = "smooth"
    opt.InternalAssignFunc = @hdataassign
    opt.DiffuseScale (1, 1) double = iris.mixin.Kalman.DIFFUSE_SCALE
    opt.WhenMissing (1, 1) string = "warning"

    opt.Anticipate (1, 1) logical = false
    opt.Ahead (1, 1) double = 1
    opt.Contributions (1, 1) logical = false

    opt.CheckFmse (1, 1) logical = false
    opt.FmseCondTol (1, 1) double = eps()
    opt.Initials {local_validateInitials} = "steady"

    opt.UnitRootInitials {local_validateUnitRootInitials} = "approxDiffuse"
        opt.InitUnitRoot__UnitRootInitials = []

    opt.Preiterate (1, 1) double = 0

    opt.LastSmooth (1, 1) double = Inf
    opt.Outlik (1, :) string = string.empty(1, 0)
        opt.OutOfLik__Outlik = []

    opt.ObjFunc (1, 1) string {mustBeMember(opt.ObjFunc, ["loglik", "prederr"])} = "loglik"
        opt.Objective__ObjFunc = []

    opt.ReturnObjFuncContribs (1, 1) logical = false
        opt.ObjDecomp__ReturnObjFuncContribs = []

    opt.ExcludeFromObjFunc (1, :) string = string.empty(1, 0)

    opt.ObjFuncRange {local_validateObjFuncRange} = @all

    opt.Progress (1, 1) logical = false
    opt.Deviation (1, 1) logical = false

    opt.EvalTrends (1, :) logical = logical.empty(1, 0)
        opt.DTrends__EvalTrends = []

    opt.Relative (1, 1) logical = false
    opt.Simulate {local_validateSimulate} = false
    opt.Weighting double = []
    opt.MeanOnly (1, 1) logical = false
    opt.MedianOnly (1, 1) logical = false
    opt.ReturnStd (1, 1) logical = true
    opt.ReturnMedian (1, :) logical = logical.empty(1, 0)
    opt.ReturnMse (1, 1) logical = true

    opt.Override {validate.mustBeDatabankOrEmpty} = []
        opt.TimeVarying__Override = []
        opt.Vary__Override = []
        opt.Std__Override = []

    opt.Multiply {validate.mustBeDatabankOrEmpty} = []

    opt.Steady (1, :) cell = {"run", false}
    opt.CheckSteady (1, :) cell = {"run", false}
    opt.Solve (1, :) cell = {"run", true}
end
%}
% >=R2019b


% <=R2019a
%(
function opt = prepareKalmanOptions2(this, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 

    addParameter(ip, "Persist", false);
    addParameter(ip, "FlatOutput", true);
    addParameter(ip, "MatrixFormat", "namedMatrix");
    addParameter(ip, "OutputData", "smooth");
    addParameter(ip, "InternalAssignFunc", @hdataassign);
    addParameter(ip, "DiffuseScale", iris.mixin.Kalman.DIFFUSE_SCALE);
    addParameter(ip, "WhenMissing", "warning");

    addParameter(ip, "Anticipate", false);
    addParameter(ip, "Ahead", 1);
    addParameter(ip, "Contributions", false);

    addParameter(ip, "CheckFmse", false);
    addParameter(ip, "FmseCondTol", eps());
    addParameter(ip, "Initials", "steady");

    addParameter(ip, "UnitRootInitials", "approxDiffuse");
        addParameter(ip, "InitUnitRoot__UnitRootInitials", []);

    addParameter(ip, "Preiterate", 0);

    addParameter(ip, "LastSmooth", Inf);
    addParameter(ip, "Outlik", string.empty(1, 0));
        addParameter(ip, "OutOfLik__Outlik", []);

    addParameter(ip, "ObjFunc", "loglik");
        addParameter(ip, "Objective__ObjFunc", []);

    addParameter(ip, "ReturnObjFuncContribs", false);
        addParameter(ip, "ObjDecomp__ReturnObjFuncContribs", []);

    addParameter(ip, "ExcludeFromObjFunc", string.empty(1, 0));

    addParameter(ip, "ObjFuncRange", @all);

    addParameter(ip, "Progress", false);
    addParameter(ip, "Deviation", false);

    addParameter(ip, "EvalTrends", logical.empty(1, 0));
        addParameter(ip, "DTrends__EvalTrends", []);

    addParameter(ip, "Relative", false);
    addParameter(ip, "Simulate", false);
    addParameter(ip, "Weighting", []);
    addParameter(ip, "MeanOnly", false);
    addParameter(ip, "MedianOnly", false);
    addParameter(ip, "ReturnStd", true);
    addParameter(ip, "ReturnMedian", logical.empty(1, 0));
    addParameter(ip, "ReturnMse", true);

    addParameter(ip, "Override", []);
        addParameter(ip, "TimeVarying__Override", []);
        addParameter(ip, "Vary__Override", []);
        addParameter(ip, "Std__Override", []);

    addParameter(ip, "Multiply", []);

    addParameter(ip, "Steady", {"run", false});
    addParameter(ip, "CheckSteady", {"run", false});
    addParameter(ip, "Solve", {"run", true});
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end


range = double(range);
startRange = range(1);
endRange = range(end);
range = dater.colon(startRange, endRange);
numPeriods = round(endRange - startRange + 1);
[ny, ~, numXb, ~, ~, ~, nz] = sizeSolution(this);


opt.ReturnMedian = local_resolveMedianOption(this, opt.ReturnMedian);
opt.FilterRange = range;


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
opt.Condition = [];
% if isempty(opt.Condition) || nz>0
    % opt.Condition = [];
% else
    % [~, opt.Condition] = userSelection2Index(this.Quantity, opt.Condition, 1);
% end


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
optionsHere = struct('Clip', true, 'Presample', true);
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
        elseif any(size(opt.Weighting)==1)
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
% Measurement variables excluded from objective function
%
if ~isempty(opt.ExcludeFromObjFunc)
    measurementNames = textual.stringify(getNamesByType(this.Quantity, 1));
    opt.ExcludeFromObjFunc = textual.stringify(opt.ExcludeFromObjFunc);
    inx = ismember(opt.ExcludeFromObjFunc, measurementNames);
    if any(~inx)
        exception.error([ ...
            "Model"
            "This is not a valid measurement variable name to exclude from objective function: %s "
        ], opt.ExcludeFromObjFunc(~inx));
    end
    opt.ExcludeFromObjFunc = reshape(ismember(measurementNames, opt.ExcludeFromObjFunc), [], 1);
else
    opt.ExcludeFromObjFunc = false(ny, 1);
end


%
% Initial condition
%
% User-supplied initials is a 1-by-2 cell array with a mean vector and an MSE
% matrix.
%
if ~isempty(opt.Initials) && iscell(opt.Initials)
    if validate.databank(opt.Initials{1})
        xbVector = getBackwardSolutionVector(this.Vector);
        maxLag = min([imag(xbVector), 0]) - 1;
        presampleDates = dater.plus(range(1), maxLag:-1);
        if numXb>0
            namesInRows = textual.stringify(this.Quantity.Name);
            numQuantities = numel(namesInRows);
            inxXb = false(1, numQuantities);
            inxXb(real(xbVector)) = true;
            xbNames = textual.stringify(namesInRows(inxXb));
            xbLogNames = textual.stringify(namesInRows(inxXb & this.Quantity.InxLog));
            context = "";

            dbInfo = checkInputDatabank( ...
                this, opt.Initials{1}, range ...
                , string.empty(1, 0), xbNames ...
                , string.empty(1, 0), xbLogNames ...
                , context ...
            );

            % namesInRows(~inxXb) = missing;
            array = requestData(this, dbInfo, opt.Initials{1}, namesInRows, presampleDates);
            array = ensureLog(this, dbInfo, array, namesInRows);

            linx = sub2ind(size(array), real(xbVector), imag(xbVector)-maxLag);
            opt.Initials{1} = reshape(double(array(linx)), numXb, 1);
        else
            opt.Initials{1} = double.empty(0, 1);
        end
    elseif ~isempty(opt.Initials{1})
        opt.Initials{1} = reshape(double(opt.Initials{1}), numXb, 1);
    end

    if isa(opt.Initials{2}, 'Series') && iscell(opt.Initials{2}.Data)
        xbVector = getBackwardSolutionVector(this.Vector);
        maxLag = min([imag(xbVector), 0]) - 1;
        presampleDates = dater.plus(range(1), maxLag:-1);
        x = getData(opt.Initials{2}, presampleDates(end));
        opt.Initials{2} = reshape(x{1}, numXb, numXb);
    elseif isequal(opt.Initials{2}, 0)
        opt.Initials{2} = zeros(numXb, numXb);
    elseif ~isempty(opt.Initials{2})
        opt.Initials{2} = reshape(double(opt.Initials{2}), numXb, numXb);
    end
end


%
% Initial condition for unit root components
%
if isstruct(opt.UnitRootInitials)
    [xbInitMean, missingMean] = ...
        datarequest('xbInit', this, opt.UnitRootInitials, range);
    missingMse = cell.empty(1, 0);
    here_checkNaNInit( );
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
    here_prepareSimulateSystemProperty( );
end

return

    function here_checkNaNInit( )
        %(
        if ~isempty(missingMean)
            thisError = { 'Model:MissingInitial'
                          'The value for this mean initial condition is missing from input databank: %s ' };
            throw( exception.Base(thisError, 'error'), ...
                   missingMean{:} );
        end
        if ~isempty(missingMse)
            thisError = { 'Model:MissingInitial'
                          'The value for this MSE initial condition is missing from input databank: %s ' };
            throw( exception.Base(thisError, 'error'), ...
                   missingMse{:} );
        end
        %)
    end%


    function here_prepareSimulateSystemProperty( )
        %(
        opt.Simulate = simulate( ...
            this, "asynchronous", @auto, ...
            opt.Simulate{:} ...
            , "SystemProperty", "S" ...
        );
        %)
    end%
end%

%
% Local functions
%

function flag = local_resolveMedianOption(this, flag)
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

function flag = local_validateInitials(x)
    %(
    flag = true;
    if iscell(x) && any(numel(x)==[2, 3])
        return
    end
    valid = ["asymptotic", "stochastic", "steady", "fixed", "fixedUnknown"];
    if validate.anyText(x, valid)
        return
    end
    error("Input value must be a cell array or one of " + join(valid, ", "));
    %)
end%


function flag = local_validateUnitRootInitials(x)
    %(
    flag = true;
    if validate.databank(x)
        return
    end
    valid = ["fixedUnknown", "approxDiffuse", "preiterate"];
    if validate.anyText(x, valid)
        return
    end
    error("Input value must be a databank or one of " + join(valid, ", "));
end%


function flag = local_validateObjFuncRange(x)
    %(
    flag = isnumeric(x) || isequal(x, @all);
    %)
end%


function flag = local_validateSimulate(x)
    %(
    flag = isequal(x, false) || validate.nestedOptions(x);
    %)
end%

