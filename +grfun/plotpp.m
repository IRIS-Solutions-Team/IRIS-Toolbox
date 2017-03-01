function [priorPoints, posterPoints, varargout] = plotpp(inp, varargin)
% plotpp  Plot prior and/or posterior distributions and/or posterior mode.
%
% Syntax
% =======
%
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, [ ], [ ], ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, est, [ ], ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, [ ], theta, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, [ ], stats, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, est, theta, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(inp, est, stats, ...)
%
%
% Input arguments
% ================
%
% * `inp` [ struct ] - Estimation input struct, see
% [`estimate`](model/estimate), with prior function handles from the
% [logdist](logdist/Contents) package.
%
% * `est` [ struct | empty ] - Output struct returned from the
% [`model/estimate`](model/estimate) function; `est` will be used to plot
% the maximized posterior modes.
%
% * `theta` [ numeric | empty ] - Array with the chain of draws from the
% posterior simulator [`arwm`](poster/arwm).
%
% * `stats` [ struct | empty ] - Output struct returned from the posterior
% simulator statistics function [`stats`](poster/stats).
%
%
% Output arguments
% =================
%
% * `priorPoints` [ struct ] - Struct with x- and y-axis coordinates to plot the
% prior distribution for each parameter.
%
% * `posterPoints` [ struct ] - Struct with x- and y-axis coordinates to plot the
% posterior distribution for each parameter.
%
% * `H` [ struct ] - Struct with handles to the graphics objects plotted by
% `plotpp`; the struct has the following fields with vectors of handles:
% `figure`, `axes`, `prior`, `poster`, `bounds`, `init`, `mode`, `title`.
%
%
% Options
% ========
%
% * `'Axes='` [ *empty* | cell ] - Graphics options that will be applied to
% every Axes object created by `plotpp( )`.
%
% * `'Caption='` [ *empty* | cellstr ] - User-supplied graph titles; if
% empty, default captions will be automatically created.
%
% * `'Describe='` [ *@auto* | true | false ] - Include information on
% prior distributions, starting values, and maximised posterior modes in
% the graph titles; `@auto` means the descriptions will be shown only if
% `'PlotPrior='` is true.
%
% * `'Figure='` [ *empty* | cell ] - Graphics options that will be applied
% to every Figure object created by `plotpp( )`.
%
% * `'KsDensity='` [ numeric | *empty* ] - Number of points over which the
% density will be calculated; if empty, default number will be used
% depending on the backend function available.
%
% * `'PlotInit='` [ *`true`* | `false` | cell ] - Plot starting values
% (initial consition used in posterior mode maximisation) as vertical
% stems.
%
% * `'PlotPrior='` [ *`true`* | `false` | cell ] - Plot prior
% distributions.
%
% * `'PlotMode='` [ *`true`* | `false` | cell ] - Plot maximised posterior
% modes as vertical stems; the modes are taken from  `est` (and not from
% `stats` or `theta`).
%
% * `'PlotPoster='` [ *`true`* | `false` | cell ] - Plot posterior
% distributions.
%
% * `'PlotBounds='` [ *`true`* | `false` | cell ] - Plot lower and/or upper
% bounds as vertical lines; if `false`, the bounds will be plotted only
% added if within the graph x-limits.
%
% * `'Sigma='` [ numeric | *3* ] - Number of std devs from the mean or the
% mode (whichever covers a larger area) to the left and to right that will
% be plotted unless running out of bounds.
%
% * `'Subplot='` [ `@auto` | numeric ] - Specification of subplot division
% of graphs produced by `plotpp( )`; `@auto` means all graphs will be
% fitted into one figure window using optimal subplot divison; `[k, n]`
% means graphs will be arranged into k-by-n subplots in as many figure
% windows as needed; a scalar, `n`, is the same as `[n, n]`.
%
% * `'Tight='` [ *`true`* | `false` ] - Make graph axes tight.
%
% * `'Title='` [ *`true`* | `false` | cell ] - Display graph titles, and
% specify graphics options for the titles.
%
% * `'XLims='` [ struct | *empty* ] - Control the x-limits of the prior and
% posterior graphs.
%
%
% Description
% ============
%
% The options that control what will be plotted in the graphs
% (i.e. `'PlotInit='`, `'PlotPrior='`, `'PlotMode='`, `'PlotPoster='`, 
% `'PlotBounds='`, `'Title='`) can be set to one of the following three
% values:
%
% * `true`, 
% * `false`, 
% * a cell array with sub-options to control the appearance of the
% respetive line; these will be passed into the respective plotting
% function.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

mo = [ ]; % Maximised posterior mode.
po = [ ]; % Simulated posterior distribution.

if ~isempty(varargin)
    if isempty(varargin{1}) ...
            || (isstruct(varargin{1}) ...
            && isequal(fieldnames(inp), fieldnames(varargin{1})))
        mo = varargin{1};
        varargin(1) = [ ];
    end
end

if ~isempty(varargin)
    if isempty(varargin{1}) ...
            || isnumeric(varargin{1}) ...
            || isstruct(varargin{1})
        po = varargin{1};
        varargin(1) = [ ];
    end
end

opt = passvalopt('grfun.plotpp', varargin{:});

if isequal(opt.Describe, @auto)
    opt.Describe = ~isequal(opt.PlotPrior, false);
end

%--------------------------------------------------------------------------

if isempty(mo)
    opt.PlotMode = false;
end

if isempty(po)
    opt.PlotPoster = false;
end

% Get lower and upper bounds for individual params.
bnd = getBounds(inp);

% Get prior function handles.
priorFunc = getPriorFunc(inp);

% Get x-limits for individual priors.
priorXLim = getPriorXLim(priorFunc, bnd, opt);

% Compute x- and y-axis co-ordinates for prior graphs.
priorPoints = getPriorPoints(priorFunc, priorXLim);

% Compute x- and y-axis co-ordinates for posterior graphs.
posterPoints = getPosterPoints(po, bnd, opt);

% Find maximum displayed in each graph; they are used in plotting stem
% graphs.
max_ = getMax(priorPoints, posterPoints);

% Compute x- and y-axis co-ordinates for mode graphs.
modePoints = getModePoints(mo, max_);

% Get starting values for posterior mode maximization.
initPoints = getInitPoints(inp, max_);

% Get x-limits for posteriors.
posterXLim = getPosterXLim(posterPoints); %#ok<NASGU>

% fig = [ ];
% ax = [ ];
prLin = [ ];
moLin = [ ];
poLin = [ ];
bndLin = [ ];
inLin = [ ];

% We're done if actual plots are not requested.
if isequal(opt.PlotPrior, false) ...
        && isequal(opt.PlotPoster, false) ...
        && isequal(opt.PlotInit, false) ...
        && isequal(opt.PlotMode, false)
    return
end

% Create titles.
descript = [ ];
if ~isequal(opt.Title, false)
    descript = createTitles(priorFunc, modePoints, posterPoints, initPoints, opt);
end

% Create graphs.
[fig, ax, tit] = createGraphs(inp, descript, opt);

% Plot priors.
if ~isequal(opt.PlotPrior, false)
    prLin = plotPriors(ax, priorPoints, opt);
end

% Plot starting values.
if ~isequal(opt.PlotInit, false)
    inLin = plotInit(ax, initPoints, opt);
end

% Plot modes.
if ~isequal(opt.PlotMode, false)
    moLin = plotMode(ax, modePoints, opt);
end

% Plot posteriors.
if ~isequal(opt.PlotPoster, false)
    poLin = plotPoster(ax, posterPoints, opt);
end

% Plot bounds as vertical lines.
if ~isequal(opt.PlotBounds, false)
    bndLin = plotBounds(ax, bnd, max_, opt);
end

% Output arguments. For bkw compatiblity, the user can ask for more then
% three, in which case the handle vectors are returned individually.
if nargout>3
    varargout = { ...
        fig, ax, prLin, poLin, bndLin, tit, inLin, moLin, ...
        };
else
    varargout{1} = struct( ...
        'figure', fig, ...
        'axes', ax, ...
        'prior', prLin, ...
        'poster', poLin, ...
        'bounds', bndLin, ...
        'init', inLin, ...
        'mode', moLin, ...
        'title', tit ...
        );
end

end




function bnd = getBounds(inp)
list = fieldnames(inp);
nlist = numel(list);
bnd = struct( );
for i = 1 : nlist
    temp = inp.(list{i});
    low = NaN;
    upp = NaN;
    try
        low = temp{2};
    catch
        try %#ok<*TRYNC>
            low = temp(2);
        end
    end
    try
        upp = temp{3};
    catch %#ok<*CTCH>
        try
            upp = temp(3);
        end
    end
    bnd.(list{i}) = [low, upp];
end
end




function priorFunc = getPriorFunc(inp)
list = fieldnames(inp);
nList = numel(list);
priorFunc = struct( );
for i = 1 : nList
    try
        priorFunc.(list{i}) = inp.(list{i}){4};
    catch
        priorFunc.(list{i}) = [ ];
    end
end
end




function priorXLim = getPriorXLim(priorFunc, bnd, opt)
w = opt.Sigma;
userXLim = opt.XLim;

list = fieldnames(priorFunc);
nList = numel(list);
priorXLim = struct( );
for i = 1 : nList
    f = priorFunc.(list{i});
    from = NaN;
    to = NaN;
    try
        from = double(userXLim.(list{i})(1));
        to = double(userXLim.(list{i})(1));
    end
    if (isnan(from) || isnan(to) ) && ~isempty(f)
        low = bnd.(list{i})(1);
        high = bnd.(list{i})(2);
        mean = f([ ], 'mean');
        sgm = f([ ], 'std');
        mode = f([ ], 'mode');
        from = min(mean-w*sgm, mode-w*sgm);
        from = max(from, low);
        to = max(mean+w*sgm, mode+w*sgm);
        if ~isfinite(to)
            to = max(w*mean, w*mode);
        end
        to = min(to, high);
    end
    priorXLim.(list{i}) = [from, to];
end
end




function priorPoints = getPriorPoints(priorFunc, priorXLim)
list = fieldnames(priorFunc);
nList = numel(list);
priorPoints = struct( );
for i = 1 : nList
    f = priorFunc.(list{i});
    if isempty(f)
        x = NaN;
        y = NaN;
    else
        from = priorXLim.(list{i})(1);
        to = priorXLim.(list{i})(2);
        x = linspace(from, to, 1000);
        y = f(x, 'proper');
    end
    priorPoints.(list{i}) = {x, y};
end
end




function [fig, ax, tit] = createGraphs(inp, descript, opt)
list = fieldnames(inp);
nList = numel(list);

nSub = opt.Subplot;
if isequal(nSub, @auto)
    nSub = ceil(sqrt(nList));
    if nSub*(nSub-1)>=nList
        nSub = [nSub-1, nSub];
    else
        nSub = [nSub, nSub];
    end
elseif length(nSub)==1
    nSub = [nSub, nSub];
end

figureOpt = { };
axesOpt = { };
titleOpt = { };
processGraphicsOptions( );

total = prod(nSub);
fig = figure(figureOpt{:});
ax = [ ];
tit = [ ];
pos = 1;

for i = 1 : nList
    if pos>total
        fig = [fig, figure(figureOpt{:})]; %#ok<AGROW>
        pos = 1;
    end
    ax = [ax, subplot(nSub(1), nSub(2), pos, axesOpt{:})];
    if ~isequal(opt.Title, false)
        tit(i) = title(descript{i}, titleOpt{:});
    end
    hold on;
    pos = pos + 1;
end
grfun.clicktocopy(ax);

return




    function processGraphicsOptions( )
        if iscell(opt.Figure)
            figureOpt = opt.Figure;
            figureOpt(1:2:end) = strrep(figureOpt(1:2:end), '=', '');
        end
        if iscell(opt.Axes)
            axesOpt = opt.Axes;
            axesOpt(1:2:end) = strrep(axesOpt(1:2:end), '=', '');
        end
        if iscell(opt.Title)
            titleOpt = opt.Title;
            titleOpt(1:2:end) = strrep(titleOpt(1:2:end), '=', '');
        end
    end
end




function prLin = plotPriors(ax, priorPoints, opt)
list = fieldnames(priorPoints);
nList = numel(list);
prLin = [ ];
plotopt = { };
if iscell(opt.PlotPrior)
    plotopt = opt.PlotPrior;
    plotopt(1:2:end) = strrep(plotopt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = priorPoints.(list{i});
    h = plot(ax(i), temp{:}, plotopt{:});
    prLin = [prLin, h]; %#ok<AGROW>
    if opt.Tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end




function poLin = plotPoster(ax, posterPoints, opt)
list = fieldnames(posterPoints);
nList = numel(list);
poLin = [ ];
plotOpt = { };
if iscell(opt.PlotPoster)
    plotOpt = opt.PlotPoster;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = posterPoints.(list{i});
    h = plot(ax(i), temp{:}, plotOpt{:});
    poLin = [poLin, h]; %#ok<AGROW>
    if opt.Tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end 




function moLin = plotMode(ax, modePoints, opt)
list = fieldnames(modePoints);
nList = numel(list);
moLin = [ ];
plotOpt = { };
if iscell(opt.PlotMode)
    plotOpt = opt.PlotMode;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = modePoints.(list{i});
    h = stem(ax(i), temp{:}, plotOpt{:});
    moLin = [moLin, h]; %#ok<AGROW>
    if opt.Tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end




function bndLin = plotBounds(ax, bnd, max_, opt)
list = fieldnames(bnd);
nList = numel(list);
bndLin = [ ];
for i = 1 : nList
    low = bnd.(list{i})(1);
    high = bnd.(list{i})(2);
    y = max_.(list{i});
    [hLow, hHigh] = grfun.plotbounds(ax(i), low, high, y, opt.PlotBounds);  
    bndLin = [bndLin, hLow, hHigh]; %#ok<AGROW>
end
end




function inLin = plotInit(ax, initPoints, opt)
list = fieldnames(initPoints);
nList = numel(list);
inLin = [ ];
plotOpt = { };
if iscell(opt.PlotInit)
    plotOpt = opt.PlotInit;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = initPoints.(list{i});
    if isempty(temp)
        continue
    end
    h = stem(ax(i), temp{:}, plotOpt{:});
    inLin = [inLin, h]; %#ok<AGROW>
    if opt.Tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end




function modePoints = getModePoints(mo, max_)
if isempty(mo)
    modePoints = [ ];
    return
end

list = fieldnames(mo);
nList = numel(list);
modePoints = struct( );
for i = 1 : nList
    try
        x = mo.(list{i});
        y = 0.98*max_.(list{i});
        if isnan(y)
            % This happens if there's no prior distribution on this
            % parameter.
            y = 1;
        end
    catch
        x = NaN;
        y = NaN;
    end
    modePoints.(list{i}) = {x, y};
end
end




function posterPoints = getPosterPoints(po, bnd, opt)
if isempty(po)
    posterPoints = [ ];
    return
end

% w = opt.Sigma;
w = 5;
list = fieldnames(bnd);
nList = numel(list);
for i = 1 : nList
    try
        x = po.ksdensity(:, 1);
        y = po.ksdensity(:, 2);
        posterPoints.(list{i}) = {x, y};
        continue
    end
    the = tryGetChain( );
    if ~isempty(the)
        % User supplied simulated posterior distributions.
        low = bnd.(list{i})(1);
        high = bnd.(list{i})(2);
        [x, y] = poster.myksdensity(the, low, high, opt.KsDensity);
        myMean = mean(the);
        myStd = std(the);
        inx = x<myMean-w*myStd | x>myMean+w*myStd;
        x(inx) = [ ];
        y(inx) = [ ];
    else
        x = NaN;
        y = NaN;
    end
    posterPoints.(list{i}) = {x, y};
end

return




    function the = tryGetChain( )
        the = [ ];
        if isnumeric(po)
            try
                the = po(i, :);
            end
        else
            try
                the = po.chain.(list{i});
            end
        end
    end
end 




function posterXLim = getPosterXLim(posterPoints)
if isempty(posterPoints)
    posterXLim = [ ];
    return
end
list = fieldnames(posterPoints);
nList = numel(list);
posterXLim = struct( );
for i = 1 : nList
    temp = posterPoints.(list{i});
    from = min(temp{1});
    to = max(temp{1});
    posterXLim.(list{i}) = [from, to];
end
end




function initPoints = getInitPoints(inp, max_)
list = fieldnames(inp);
nList = numel(list);
initPoints = struct( );
for i = 1 : nList
    temp = inp.(list{i});
    if isempty(temp)
        x = NaN;
    elseif isnumeric(temp)
        x = temp(1);
    elseif iscell(temp)
        x = temp{1};
    else
        x = NaN;
    end
    % Keep NaNs.
    y = 0.98*max_.(list{i});
    initPoints.(list{i}) = {x, y};
end
end




function tit = createTitles(priorFunc, modePoints, ~, initPoints, opt)
list = fieldnames(priorFunc);
nList = numel(list);
tit = cell(1, nList);
for iGraph = 1 : nList
    if iscellstr(opt.Caption) && length(opt.Caption)>=iGraph
        % User-supplied captions.
        tit{iGraph} = opt.Caption{iGraph};
    else
        % Default captions based on the parameter name; treat underscores because
        % the Interpreter= is 'tex' by default.
        tit{iGraph} = list{iGraph};
        tit{iGraph} = strrep(tit{iGraph}, '_', '\_');
        tit{iGraph} = ['{\bf', tit{iGraph}, '}'];
    end
    if ~opt.Describe
        continue
    end
    if ~isequal(opt.PlotPrior, false)
        describePrior( );
    end
    if ~isequal(opt.PlotMode, false)
        describeMode( );
    end
    if ~isequal(opt.PlotInit, false)
        describeInit( );
    end
end

return




    function describePrior( )
        f = priorFunc.(list{iGraph});
        if isempty(f)
            tit{iGraph} = [tit{iGraph}, sprintf('\nprior: flat')];
        else
            try
                name = f([ ], 'name');
                mu = f([ ], 'mean');
                sgm = f([ ], 'std');
                tit{iGraph} = [tit{iGraph}, ...
                    sprintf('\nprior: %s {\\mu=}%g {\\sigma=}%g', ...
                    name, mu, sgm)];
            end
        end
    end 




    function describeMode( )
        try
            temp = modePoints.(list{iGraph}){1};
            tit{iGraph} = [tit{iGraph}, ...
                sprintf('\nmaximised poster: %g', temp)];
        end
    end




    function describeInit( )
        try
            h = initPoints.(list{iGraph}){1};
            if isnumericscalar(h)
                tit{iGraph} = [tit{iGraph}, ...
                    sprintf('\nstart: %g', h)];
            end
        end
    end 
end 




function max_ = getMax(priorPoints, posterPoints)
list = fieldnames(priorPoints);
nList = numel(list);
max_ = struct( );
for i = 1 : nList
    temp = priorPoints.(list{i}){2};
    maxPrior = max(temp(:));
    try
        temp = posterPoints.(list{i}){2};
        maxPoster = max(temp(:));
    catch
        maxPoster = [ ];
    end
    max_.(list{i}) = max([maxPrior; maxPoster]);
end
end
