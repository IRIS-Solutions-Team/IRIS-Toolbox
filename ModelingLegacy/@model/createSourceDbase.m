function outputDatabank = createSourceDbase(this, range, varargin)
% createSourceDbase  Create model specific source database
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;
TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );

if ischar(range)
    range = textinp2dat(range);
end

numOfColumnsRequested = [ ];
if ~isempty(varargin) && isnumericscalar(varargin{1})
    numOfColumnsRequested = varargin{1};
    varargin(1) = [ ];
end

opt = passvalopt('model.createSourceDbase', varargin{:});

numOfDrawsRequested = opt.ndraw;
if isempty(numOfColumnsRequested)
    numOfColumnsRequested = opt.ncol;
end

%--------------------------------------------------------------------------

nv = length(this);
checkNumColumnsRequested = numOfColumnsRequested==1 || nv==1;
checkNumDrawsRequested = numOfDrawsRequested==1 || nv==1;
if ~checkNumColumnsRequested || ~checkNumDrawsRequested
    throw( exception.Base('Model:NumOfColumnsNumOfDraws', 'error') );
end

% __Extended Range__
% getActualMinMaxShifts( ) Includes at least one lag for reporting purposes.
[minSh, maxSh] = getActualMinMaxShifts(this);
start = range(1);
extendedStart = range(1);
xEnd = range(end);
if ~isa(range, 'DateWrapper')
    start = DateWrapper(start);
    extendedStart = DateWrapper(extendedStart);
    xEnd = DateWrapper(xEnd);
end
if opt.AppendPresample
    extendedStart = addTo(extendedStart, minSh);
end
if opt.AppendPostsample
    xEnd = addTo(xEnd, maxSh);
end
extendedRange = extendedStart : xEnd;
nXPer = length(extendedRange);

label = this.Quantity.LabelOrName;

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
ixyxg = ixy | ixx | ixg;
posyxg = find(ixy | ixx | ixg);
ixLog = this.Quantity.IxLog;
ny = sum(ixy);
numOfQuantities = length(this.Quantity);

numOfColumnsToCreate = max([nv, numOfColumnsRequested, numOfDrawsRequested]);
outputDatabank = struct( );

% Deterministic time trend.
ttrend = dat2ttrend(extendedRange, this);

X = zeros(numOfQuantities, nXPer, nv);
if ~opt.Deviation
    isDelog = false;
    X(ixyxg, :, :) = createTrendArray(this, Inf, isDelog, posyxg, ttrend);
end

if opt.DTrends
    W = evalTrendEquations(this, [ ], X(ixg, :, :), @all);
    X(1:ny, :, :) = X(1:ny, :, :) + W;
end

X(ixLog, :, :) = real(exp( X(ixLog, :, :) ));

if numOfColumnsToCreate>1 && nv==1
    X = repmat(X, 1, 1, numOfColumnsToCreate);
end

% Transition variables, exogenous variables
for i = find(ixx | ixg)
    name = this.Quantity.Name{i};
    outputDatabank.(name) = replace( TIME_SERIES_TEMPLATE, ...
                                     permute(X(i, :, :), [2, 3, 1]), ...
                                     extendedStart, ...
                                     label{i} );
end

% Do not include pre-sample or post-sample in measurement variables and
% shocks
for i = find(ixy | ixe)
    name = this.Quantity.Name{i};
    x = X(i, 1-minSh:end-maxSh, :);
    outputDatabank.(name) = replace( TIME_SERIES_TEMPLATE, ...
                                     permute(x, [2, 3, 1]), ...
                                     start, ...
                                     label{i} );
end

% Generate random residuals if requested
if ~isequal(opt.shockfunc, @zeros)
    outputDatabank = shockdb( this, outputDatabank, range, numOfColumnsToCreate, ...
                              'ShockFunc=', opt.shockfunc );
end

% Add parameters
outputDatabank = addToDatabank( {'Parameters', 'Std', 'NonzeroCorr'}, this, outputDatabank);

% Add LHS names from reporting equations
nameLhs = this.Reporting.NamesOfLhs;
for i = 1 : length(nameLhs)
    % TODO: use label or name
    outputDatabank.(nameLhs{i}) = comment(TIME_SERIES_TEMPLATE, nameLhs{i});
end

end%

