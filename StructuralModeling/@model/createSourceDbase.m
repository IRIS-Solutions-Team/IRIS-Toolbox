function outp = createSourceDbase(this, range, varargin)
% createSourceDbase  Create model specific source database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;
TIME_SERIES_CONSTRUCTOR = getappdata(0, 'TIME_SERIES_CONSTRUCTOR');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

if ischar(range)
    range = textinp2dat(range);
end

nCol = [ ];
if ~isempty(varargin) && isnumericscalar(varargin{1})
    nCol = varargin{1};
    varargin(1) = [ ];
end

opt = passvalopt('model.createSourceDbase', varargin{:});

nDraw = opt.ndraw;
if isempty(nCol)
    nCol = opt.ncol;
end

if ~isequal(opt.randshocks, false)
    opt.shockfunc = @randn;
    % ##### Dec 2015 OBSOLETE and scheduled for removal.
    throw( exception.Base('Obsolete:OPTION_USE_INSTEAD', 'warning'), ...
        'randShocks', 'shockFunc'); %#ok<GTARG>
end

%--------------------------------------------------------------------------

nAlt = length(this);

if (nCol>1 && nAlt>1) || (nDraw>1 && nAlt>1)
    utils.error('model:mysourcedb', ...
        ['The options nCol= or nDraw= can be used only with ', ...
        'single parameterisation models.']);
end

% Include at least one lag in the source dbase for reporting purposes.
[xRange, minSh] = getXRange(this, range, opt.AppendPresample, opt.AppendPostsample);
nXPer = length(xRange);
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

if nCol>1 && nAlt>1
    utils.error('model:mysourcedb', ...
        ['Input argument NCol can be used only with ', ...
        'single-parameterisation models.']);
end

nLoop = max([nAlt, nCol, nDraw]);
outp = struct( );

% Deterministic time trend.
ttrend = dat2ttrend(xRange, this);

X = zeros(nQty, nXPer, nAlt);
if ~opt.deviation
    isDelog = false;
    X(ixyxg, :, :) = createTrendArray(this, Inf, isDelog, posyxg, ttrend);
end

if opt.dtrends
    W = evalDtrends(this, [ ], X(ixg, :, :), @all);
    X(1:ny, :, :) = X(1:ny, :, :) + W;
end

X(ixLog, :, :) = real(exp( X(ixLog, :, :) ));

if nLoop>1 && nAlt==1
    X = repmat(X, 1, 1, nLoop);
end

% Measurement variables, transition, exogenous variables.
for i = find(ixyxg)
    name = this.Quantity.Name{i};
    outp.(name) = replace( ...
        TEMPLATE_SERIES, permute(X(i, :, :), [2, 3, 1]), xRange(1), label{i} ...
        );
end

% Do not include pre-sample in shock series.
for i = find(ixe)
    name = this.Quantity.Name{i};
    x = X(i, 1-minSh:end, :);
    outp.(name) = replace( ...
        TEMPLATE_SERIES, permute(x, [2, 3, 1]), range(1), label{i} ...
        );
end

% Generate random residuals if requested.
if ~isequal(opt.shockfunc, @zeros)
    outp = shockdb(this, outp, range, nLoop, 'shockfunc=', opt.shockfunc);
end

% Add parameters.
outp = addparam(this, outp);

% Add LHS names from reporting equations.
nameLhs = this.Reporting.NameLhs;
for i = 1 : length(nameLhs)
    % TODO: use label or name.
    outp.(nameLhs{i}) = comment(TEMPLATE_SERIES, nameLhs{i});
end

end
