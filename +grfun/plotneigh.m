% plotneigh  Plot local behaviour of objective function after estimation.
%
% Syntax
% =======
%
%     H = grfun.plotneigh(D, ...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Structure describing the local behaviour of the
% objective function returned by the [`neighbourhood`](model/neighbourhood)
% function.
%
% Output arguments
% =================
%
% * `H` [ struct ] - Struct with handles to the graphics objects plotted by
% `plotpp`; the struct has the following fields with vectors of handles:
% `figure`, `axes`, `obj`, `est`, `lik`, `bounds`.
%
% Options
% ========
%
% * `'caption='` [ *empty* | cellstr ] - User-supplied graph titles; if
% empty, default captions will be automatically created.
%
% * `'model='` [ model | *empty* ] - Model object used to create graph
% captions if the option `'caption='` is `'descript'` or `'alias'`.
%
% * `'plotObj='` [ *`true`* | `false` ] - Plot the local behaviour of the
% overall objective function; a cell array can be specified to control
% graphics options.
%
% * `'plotLik='` [ *`true`* | `false` | cell ] - Plot the local behaviour
% of the data likelihood component; a cell array can be specified to
% control graphics options.
%
% * `'plotEst='` [ *`true`* | `false` | cell ] - Mark the actual parameter
% estimate; a cell array can be specified to control graphics options.
%
% * `'plotBounds='` [ *`true`* | `false` | cell ] - Draw the lower and/or
% upper bounds if they fall within the graph range; a cell array can be
% specified to control graphics options.
%
% * `'subplot='` [ *`'auto'`* | numeric ] - Subplot division of the figure
% when plotting the results.
%
% * `'title='` [ `{'interpreter=', 'none'}` | cell ] - Display graph titles, 
% and specify graphics options for the titles.
%
% * `'linkAxes='` [ `true` | *`false`* ] - Make the vertical axes identical
% for all graphs.
%
% Description
% ============
%
% The data log-likelihood curves are shifted up or down by an arbitrary
% constant to make them fit in the graph; their curvature is preserved.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function varargout = plotneigh(d, varargin)


defaults = { 
    'Caption', [ ], @(x) isempty(x) || iscellstr(x)
    'plotobj', true, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotlik', true, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotest', {'marker', '*', 'linestyle', 'none', 'color', 'red'}, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotbounds', {'color', 'red'}, @(x) isequal(x, true) || isequal(x, false)  || iscellstr(x(1:2:end))
    'subplot', @auto, @(x) isequal(x, @auto) || isnumeric(x)
    'title', {'interpreter', 'none'}, @(x) isempty(x) || isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'linkaxes', false, @(x) isequal(x, true) || isequal(x, false)
};

opt = passvalopt(defaults, varargin{:});


isPlotObj = ~isequal(opt.plotobj, false);
isPlotLik = ~isequal(~opt.plotlik, false);
isPlotEst = ~isequal(opt.plotest, false);
isPlotBounds = ~isequal(opt.plotbounds, false);
isTitle = ~isequal(opt.title, false);

isPlot = isPlotObj || isPlotLik || isPlotEst;

%--------------------------------------------------------------------------

figh = [ ];
axh = [ ];
objh = [ ];
likh = [ ];
esth = [ ];
bh = [ ];

if ~isPlot
    return
end

plist = fieldnames(d);
np = numel(plist);
sub = grfun.nsubplot(opt.subplot, np);

n = prod(sub);
yLim = nan(np, 2);

% Force a new figure window.
count = n + 1;

plotObjOpt = { };
plotEstOpt = { };
plotLikOpt = { };
plotBoundsOpt = { };
titleOpt = { };
doGraphicsOpt( );

% Graph titles.
if isTitle
    cp = cell(1, np);
    doCaptions( );
end

for i = 1 : np
    count = count + 1;
    if count > n
        count = 1;
        figh(end+1) = figure( ); %#ok<AGROW>
    end
    axh(end+1) = subplot(sub(1), sub(2), count); %#ok<AGROW>
    x = d.(plist{i}){1};
    xMin = min(x);
    xMax = max(x);
    % Objective func (minus posterior density).
    y1 = d.(plist{i}){2}(:, 1);
    % Objective func at optimum.
    x3 = d.(plist{i}){3}(1);
    y3 = d.(plist{i}){3}(2);
    hold('all');
    % Minus log lik of data.
    y2 = d.(plist{i}){2}(:, 2);
    [~, inx] = min(abs(x - x3));
    z = y1(inx) - y2(inx);
    y2 = y2 + z;
    if isPlotObj
        objh(end+1) = plot(x, y1, plotObjOpt{:}); %#ok<AGROW>
    end
    if isPlotLik
        likh(end+1) = plot(x, y2, plotLikOpt{:}); %#ok<AGROW>
    end
    if isPlotEst
        esth(end+1) = plot(x3, y3, plotEstOpt{:}); %#ok<AGROW>
    end
    if isPlotBounds
        lo = d.(plist{i}){3}(3);
        hi = d.(plist{i}){3}(4);
        if lo >= xMin && lo <= xMax
            bh(end+1) = grfun.vline(lo, 'marker', '>', ...
                plotBoundsOpt{:}); %#ok<AGROW>
        end
        if hi >= xMin && hi <= xMax
            bh(end+1) = grfun.vline(hi, 'marker', '<', ...
                plotBoundsOpt{:}); %#ok<AGROW>
        end
    end
    grid('on');
    if isTitle
        title(cp{i}, titleOpt{:});
    end
    axis('tight');
    yLim(i, :) = get(axh(end), 'yLim');
    try %#ok<TRYNC>
        set(axh(end), 'xLim', [xMin, xMax]);
    end
end

if opt.linkaxes
    % Sort ylims by the total coverage.
    [~, inx] = sort(yLim*[-1;1]); %#ok<*NOANS, *ASGLU>
    yLim = yLim(inx, :);
    linkaxes(axh, 'y');
    % Set ylims to the median coverage.
    set(axh(end), 'yLim', yLim(ceil(np/2), :));
end

if nargout > 1
    % Bkw compatibiliy.
    varargout = {figh, axh, objh, likh, esth, bh};
else
    % Create struct with graphics handles.
    varargout = cell(1, 1);
    varargout{1} = struct( );
    varargout{1}.figure = figh;
    varargout{1}.axes = axh;
    varargout{1}.obj = objh;
    varargout{1}.lik = likh;
    varargout{1}.est = esth;
    varargout{1}.bounds = bh;
end

return

    function doGraphicsOpt( )
        if iscell(opt.plotobj) && iscellstr(opt.plotobj(1:2:end))
            plotObjOpt = opt.plotobj;
            plotObjOpt(1:2:end) = strrep(plotObjOpt(1:2:end), '=', '');
        end
        if iscell(opt.plotest) && iscellstr(opt.plotest(1:2:end))
            plotEstOpt = opt.plotest;
            plotEstOpt(1:2:end) = strrep(plotEstOpt(1:2:end), '=', '');
        end
        if iscell(opt.plotlik)  && iscellstr(opt.plotlik(1:2:end))
            plotLikOpt = opt.plotlik;
            plotLikOpt(1:2:end) = strrep(plotLikOpt(1:2:end), '=', '');
        end
        if iscell(opt.plotbounds) && iscellstr(opt.plotbounds(1:2:end))
            plotBoundsOpt = opt.plotbounds;
            plotBoundsOpt(1:2:end) = strrep(plotBoundsOpt(1:2:end), '=', '');
        end
        if iscell(opt.title) && iscellstr(opt.title(1:2:end))
            titleOpt = opt.title;
            titleOpt(1:2:end) = strrep(titleOpt(1:2:end), '=', '');
        end
    end%


    function doCaptions( )
        if ~isempty(opt.Caption) && iscellstr(opt.Caption)
            cp = opt.Caption;
            ncp = length(cp);
            if ncp > np
                cp = cp(1:np);
            elseif ncp < np
                cp(ncp+1:np) = plist(ncp+1:np);
            end
        else
            cp = plist;
        end
    end%
end%

