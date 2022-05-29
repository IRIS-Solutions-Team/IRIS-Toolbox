function [HPos, HNeg, HNaNInf, HMax] = plotmat(X, varargin)
% plotmat  Visualise 2D matrix.
%
% __Syntax__
%
%     [HPos, HNeg, HNanInf, HMax] = grfun.plotmat(X, ...)
%     [HPos, HNeg, HNanInf, HMax] = plotmat(X, ...)
%
%
% __Input arguments__
%
% * `X` [ numeric ] - 2D matrix that will be visualised; ND matrices will
% be unfolded in 2nd dimension before plotting.
%
%
% __Output arguments__
%
% * `HPos` [ numeric ] - Handles to discs displaying non-negative entries.
%
% * `HNeg` [ numeric ] - Handles to discs displeying negative entries.
%
% * `HNanInf` [ numeric ] - Handles to NaN or Inf marks.
%
% * `HMax` [ numeric ] - Handles to circles displaying maximum value.
%
%
% __Options__
%
% * `'ColNames='` [ char | cellstr | empty | *`'auto'`* ] - Names that will
% be given to the columns of the matrix.
%
% * `'RowNames='` [ char | cellstr | empty | *`'auto'`* ] - Names that will
% be give to the row of the matrix.
%
% * `'MaxCircle='` [ `true` | *`false`* ] - If `true`, display a circle
% denoting the maximum value around each entry.
%
% * `'NanInf='` [ char | `X` ] - Appearance of `NaN` and `Inf` entries.
%
% * `'ShowDiag='` [ *`true`* | `false` ] - If `false`, hide the entries on
% the main diagonal by setting them to `NaN`.
%
% * `'Scale='` [ numeric | *`'auto'`* ] - Maximum value (positive) relative to
% which all matrix entries will be scaled; by default the scale is the
% maximum entry in the input matrix, `max(max(abs(X(isfinite(X))))`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

defaults = { 
    'colnames, colname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'rownames, rowname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'maxcircle', false, @(x) isequal(x, true) || isequal(x, false)
    'naninf', 'X', @(x) ischar(x) && length(x)==1
    'scale', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || (isnumeric(x) && isscalar(x) && x>0)
    'showdiag', true, @(x) isequal(x, true) || isequal(x, false)
    ... Bkw compatibility options:
    'frame', [ ], @(x) isempty(x) || isequal(x, true) || isequal(x, false)
};

opt = passvalopt(defaults, varargin{:});


X = X(:, :);

if isa(X, 'namedmat')
    if ischar(opt.colnames) && strcmpi(opt.colnames, 'auto')
        opt.colnames = colnames(X);
    end
    if ischar(opt.rownames) && strcmpi(opt.rownames, 'auto')
        opt.rownames = rownames(X);
    end
end

if ~opt.showdiag
    diagInx = eye(size(X)) == 1;
    X(diagInx) = NaN;
end

if ischar(opt.scale) && strcmpi(opt.scale, 'auto')
    opt.scale = max(max(abs(X(isfinite(X)))));
end

if ~isfinite(opt.scale)
    opt.scale = 1;
end

% Bkw compatibility options:
if ~isempty(opt.frame)
    opt.maxcircle = opt.frame;
end

%--------------------------------------------------------------------------

[nRow, nCol] = size(X);
radius = 0.45;
X = X/opt.scale * radius;
gray = 0.6*[1, 1, 1];

HPos = [ ];
HNeg = [ ];
HNaNInf = [ ];
HMax = [ ];

status = ishold( );
hold on;

for row = 1 : nRow
    for col = 1 : nCol
        x = X(row, col);
        if ~isfinite(x)
            HNaNInf(end+1) = text(col, 1+nRow-row, opt.naninf, ...
                'horizontalAlignment', 'center', ...
                'verticalAlignment', 'middle'); %#ok<AGROW>
        else
            h = grfun.plotcircle(col, 1+nRow-row, abs(x), 'fill', true);
            if x >= 0
                HPos(end+1) = h; %#ok<AGROW>
            else
                HNeg(end+1) = h; %#ok<AGROW>
            end
            HMax(end+1) = ...
                grfun.plotcircle(col, 1+nRow-row, radius, 'color', gray); %#ok<AGROW>
        end
    end
end

set(gca( ), ...
    'xAxisLocation', 'top', ...
    'box', 'on', ...
    'xLim', [0, nCol+1], ...
    'yLim', [0, nRow+1], ...
    'xTick', 1:nCol, ...
    'yTick', 1:nRow, ...
    'xLimMode', 'manual', ...
    'yLimMode', 'manual', ...
    'xTickMode', 'manual', ...
    'yTickMode', 'manual');
axis equal;

if ~status
    hold('off');
end

set(HPos, 'faceColor', [0, 0, 0.8], 'edgeColor', 'none');
set(HNeg, 'faceColor', [0.8, 0, 0], 'edgeColor', 'none');
if ~opt.maxcircle
    set(HMax, 'lineStyle', 'none', 'marker', 'none');
end

opt.rownames = getNames(opt.rownames, nRow);
if ~isempty(opt.rownames)
    set(gca, 'yTickLabel', opt.rownames(nRow:-1:1));
end

opt.colnames = getNames(opt.colnames, nCol);
if ~isempty(opt.colnames)
    set(gca, 'xTickLabel', opt.colnames(1:nCol));
end

set(gca, 'xTickLabelMode', 'manual', 'yTickLabelMode', 'manual');

end


function C = getNames(C, N)
    if ischar(C)
        C = regexp(C, '[^, ;]+', 'match');
        C = strtrim(C);
    end
    if isempty(C)
        C = { };
        return
    end
    if length(C) < N
        C(end+1:N) = {''};
    end
end
