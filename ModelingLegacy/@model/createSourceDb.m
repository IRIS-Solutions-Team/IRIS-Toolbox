% createSourceDb  Create model specific source database
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function outputDb = createSourceDb(this, range, varargin)

TYPE = @int8;
TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );

numColumnsRequested = [ ];
if ~isempty(varargin) && isnumericscalar(varargin{1})
    numColumnsRequested = varargin{1};
    varargin(1) = [ ];
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser("@Model/createSourceDb");
    pp.KeepDefaultOptions = true;
    addRequired(pp, "model", @(x) isa(x, 'model'));
    addRequired(pp, "range", @DateWrapper.validateProperRangeInput);

    addParameter(pp, ["AppendPresample", "AddPresample"], true, @validate.logicalScalar);
    addParameter(pp, ["AppendPostsample", "AddPostsample"], true, @validate.logicalScalar);
    addParameter(pp, ["NumDraws", "NDraw"], 1, @(x) validate.roundScalar(x, 1, Inf));
    addParameter(pp, ["NumColumns", "NCol"], 1, @(x) validate.roundScalar(x, 1, Inf));
    addParameter(pp, 'ShockFunc', @zeros, @(x) isequal(x, @zeros) || isequal(x, @randn) || isequal(x, @lhsnorm)); 
    addDeviationOptions(pp, false);
end
%)
[skipped, opt] = maybeSkip(pp, this, range, varargin{:});
if ~skipped
    opt = parse(pp, this, range, varargin{:});
end

numDrawsRequested = opt.NumDraws;
if isempty(numColumnsRequested)
    numColumnsRequested = opt.NumColumns;
end

%--------------------------------------------------------------------------

nv = countVariants(this);
checkNumColumnsRequested = numColumnsRequested==1 || nv==1;
checkNumDrawsRequested = numDrawsRequested==1 || nv==1;
if ~checkNumColumnsRequested || ~checkNumDrawsRequested
    throw( exception.Base('Model:NumColumnsNumOfDraws', 'error') );
end

%
% Extended Range
% `getActualMinMaxShifts( )` includes at least one lag for reporting
% purposes
% 
[minSh, maxSh] = getActualMinMaxShifts(this);
range = double(range);
start = range(1);
extStart = range(1);
extEnd = range(end);
if ~isa(range, 'DateWrapper')
    start = DateWrapper(start);
    extStart = DateWrapper(extStart);
    extEnd = DateWrapper(extEnd);
end
if opt.AppendPresample
    extStart = addTo(extStart, minSh);
end
if opt.AppendPostsample
    extEnd = addTo(extEnd, maxSh);
end
extRange = extStart : extEnd;
numExtPeriods = length(extRange);

label = this.Quantity.LabelOrName;

inxY = this.Quantity.Type==TYPE(1);
inxX = this.Quantity.Type==TYPE(2);
inxE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
inxG = this.Quantity.Type==TYPE(5);
inxYXG = inxY | inxX | inxG;
posYXG = find(inxY | inxX | inxG);
inxLog = this.Quantity.IxLog;
ny = sum(inxY);
numQuantities = numel(this.Quantity);

numColumnsToCreate = max([nv, numColumnsRequested, numDrawsRequested]);
outputDb = struct( );

%
% Deterministic time trend
%
ttrend = dat2ttrend(extRange, this);

X = zeros(numQuantities, numExtPeriods, nv);
if ~opt.Deviation
    isDelog = false;
    X(inxYXG, :, :) = createTrendArray(this, Inf, isDelog, posYXG, ttrend);
end

if opt.DTrends
    W = evalTrendEquations(this, [ ], X(inxG, :, :), @all);
    X(1:ny, :, :) = X(1:ny, :, :) + W;
end

X(inxLog, :, :) = real(exp( X(inxLog, :, :) ));

if numColumnsToCreate>1 && nv==1
    X = repmat(X, 1, 1, numColumnsToCreate);
end


%
% Transition variables
%
for i = find(inxX)
    name = this.Quantity.Name{i};
    outputDb.(name) = replace( ...
        TIME_SERIES_TEMPLATE ...
        , permute(X(i, :, :), [2, 3, 1]) ...
        , extStart, label{i} ...
    );
end


%
% Do not include pre-sample or post-sample in measurement variables and
% shocks
% 
for i = find(inxY | inxE)
    name = this.Quantity.Name{i};
    x = X(i, 1-minSh:end-maxSh, :);
    outputDb.(name) = replace( ...
        TIME_SERIES_TEMPLATE ...
        , permute(x, [2, 3, 1]) ...
        , start, label{i} ...
    );
end


%
% Generate random residuals if requested
% 
if ~isequal(opt.ShockFunc, @zeros)
    outputDb = shockdb( ...
        this, outputDb, range, numColumnsToCreate ...
        , 'ShockFunc=', opt.ShockFunc ...
    );
end


%
% Exogenous variables
%
for i = find(inxG)
    name = this.Quantity.Name{i};
    outputDb.(name) = replace( ...
        TIME_SERIES_TEMPLATE ...
        , permute(X(i, :, :), [2, 3, 1]) ...
        , extStart, label{i} ...
    );
end


%
% Add parameters
%
outputDb = addToDatabank( {'Parameters', 'Std', 'NonzeroCorr'}, this, outputDb);


%
% Add LHS names from reporting equations
%
nameLhs = this.Reporting.NamesOfLhs;
for i = 1 : length(nameLhs)
    % TODO: use label or name
    outputDb.(nameLhs{i}) = comment(TIME_SERIES_TEMPLATE, nameLhs{i});
end

end%

