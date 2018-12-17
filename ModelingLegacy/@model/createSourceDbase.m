function outputDatabank = createSourceDbase(this, range, varargin)
% createSourceDbase  Create model specific source database
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;
TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

if ischar(range)
    range = textinp2dat(range);
end

numColumnsRequested = [ ];
if ~isempty(varargin) && isnumericscalar(varargin{1})
    numColumnsRequested = varargin{1};
    varargin(1) = [ ];
end

opt = passvalopt('model.createSourceDbase', varargin{:});

numDrawsRequested = opt.ndraw;
if isempty(numColumnsRequested)
    numColumnsRequested = opt.ncol;
end

%--------------------------------------------------------------------------

nv = length(this);
checkNumColumnsRequested = numColumnsRequested==1 || nv==1;
checkNumDrawsRequested = numDrawsRequested==1 || nv==1;
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

label = getLabelOrName(this.Quantity);

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
ixyxg = ixy | ixx | ixg;
posyxg = find(ixy | ixx | ixg);
ixLog = this.Quantity.IxLog;
ny = sum(ixy);
nQty = length(this.Quantity);

numColumnsToCreate = max([nv, numColumnsRequested, numDrawsRequested]);
outputDatabank = struct( );

% Deterministic time trend.
ttrend = dat2ttrend(extendedRange, this);

X = zeros(nQty, nXPer, nv);
if ~opt.Deviation
    isDelog = false;
    X(ixyxg, :, :) = createTrendArray(this, Inf, isDelog, posyxg, ttrend);
end

if opt.DTrends
    W = evalDtrends(this, [ ], X(ixg, :, :), @all);
    X(1:ny, :, :) = X(1:ny, :, :) + W;
end

X(ixLog, :, :) = real(exp( X(ixLog, :, :) ));

if numColumnsToCreate>1 && nv==1
    X = repmat(X, 1, 1, numColumnsToCreate);
end

% Transition variables, exogenous variables
for i = find(ixx | ixg)
    name = this.Quantity.Name{i};
    outputDatabank.(name) = replace( TEMPLATE_SERIES, ...
                                     permute(X(i, :, :), [2, 3, 1]), ...
                                     extendedStart, ...
                                     label{i} );
end

% Do not include pre-sample or post-sample in measurement variables and
% shocks
for i = find(ixy | ixe)
    name = this.Quantity.Name{i};
    x = X(i, 1-minSh:end-maxSh, :);
    outputDatabank.(name) = replace( TEMPLATE_SERIES, ...
                                     permute(x, [2, 3, 1]), ...
                                     start, ...
                                     label{i} );
end

% Generate random residuals if requested
if ~isequal(opt.shockfunc, @zeros)
    outputDatabank = shockdb( this, outputDatabank, range, numColumnsToCreate, ...
                              'shockFunc=', opt.shockfunc );
end

% Add parameters.
outputDatabank = addToDatabank( {'Parameters', 'Std', 'NonzeroCorr'}, this, outputDatabank);

% Add LHS names from reporting equations.
nameLhs = this.Reporting.NameLhs;
for i = 1 : length(nameLhs)
    % TODO: use label or name.
    outputDatabank.(nameLhs{i}) = comment(TEMPLATE_SERIES, nameLhs{i});
end

end
