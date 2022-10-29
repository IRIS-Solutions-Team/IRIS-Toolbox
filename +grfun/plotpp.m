function [priorPoints, posterPoints, varargout] = plotpp(estSpecs, varargin)
% plotpp  Plot prior and/or posterior distributions and/or posterior mode.
%
% Syntax
% =======
%
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, [ ], [ ], ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, summary, [ ], ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, [ ], theta, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, [ ], stats, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, summary, theta, ...)
%     [priorPoints, posterPoints, H] = grfun.plotpp(estSpecs, summary, stats, ...)
%
%
% Input arguments
% ================
%
% * `estSpecs` [ struct ] - Estimation specification struct, see
% [`estimate`](model/estimate), with prior function handles from the
% [logdist](logdist/Contents) package.
%
% * `summary` [ table | struct | empty ] - Summary returned from the
% [`model/estimate`](model/estimate) function; `summary` will be used to
% plot the maximized posterior modes.
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
% prior distributions, starting values, and maximized posterior modes in
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
% * `'PlotMode='` [ *`true`* | `false` | cell ] - Plot maximized posterior
% modes as vertical stems; the modes are taken from  `summary` (and not from
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

summary = [ ]; % Maximized posterior mode
po = [ ]; % Simulated posterior distribution

estSpecsFields = fieldnames(estSpecs);

if ~isempty(varargin)
    if isempty(varargin{1}) ...
            || ( isstruct(varargin{1}) && all(ismember(estSpecsFields, fieldnames(varargin{1}))) ) ...
            || ( isa(varargin{1}, 'table') && all(ismember(estSpecsFields, varargin{1}.Properties.RowNames)) ) ...
        summary = varargin{1};
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


defaults = { 
    'Axes', { }, @iscell
    'Caption', [ ], @(x) isempty(x) || iscellstr(x)
    'Describe, DescribePrior', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false)
    'KsDensity', [ ], @(x) isempty(x) || isintscalar(x)
    'Figure', { }, @iscell
    'PlotInit', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotMode', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotPrior', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotPoster', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotBounds', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto) || iscell(x)
    'Sigma', 3, @(x) isnumeric(x) && isscalar(x) && x>0
    'Subplot', @auto, @(x) isequal(x, @auto) || isnumeric(x)
    'Tight', true, @(x) isequal(x, true) || isequal(x, false)
    'Title', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'XLim, XLims', [ ], @(x) isempty(x) || isstruct( )
};

opt = passvalopt(defaults, varargin{:});


if isequal(opt.Describe, @auto)
    opt.Describe = ~isequal(opt.PlotPrior, false);
end

%--------------------------------------------------------------------------

if isempty(summary)
    opt.PlotMode = false;
end

if isempty(po)
    opt.PlotPoster = false;
end

% Get lower and upper bounds for individual params.
bnd = getBounds(estSpecs);

% Get prior function handles.
priorFunc = getPriorFunc(estSpecs);

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
modePoints = getModePoints(summary, max_);

% Get starting values for posterior mode maximization.
initPoints = hereGetInitPoints(estSpecs, max_, summary);

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
[fig, ax, tit] = createGraphs(estSpecs, descript, opt);

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

end%


%
% Local Functions
%


function bnd = getBounds(estSpecs)
list = fieldnames(estSpecs);
nlist = numel(list);
bnd = struct( );
for i = 1 : nlist
    temp = estSpecs.(list{i});
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




function priorFunc = getPriorFunc(estSpecs)
list = fieldnames(estSpecs);
nList = numel(list);
priorFunc = struct( );
for i = 1 : nList
    try
        priorFunc.(list{i}) = estSpecs.(list{i}){4};
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
        if isa(f, 'distribution.Distribution')
            mean = f.Mean;
            sgm = f.Std;
            mode = f.Mode;
        else
            try
                mean = f([ ], 'mean');
                sgm = f([ ], 'std');
                mode = f([ ], 'mode');
            catch
                mean = NaN;
                sgm = NaN;
                mode = NaN;
            end
        end
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
        if isa(f, 'distribution.Distribution')
            y = f.pdf(x);
        else
            try
                y = f(x, 'proper');
            catch
                y = nan(size(x));
            end
        end
    end
    priorPoints.(list{i}) = {x, y};
end
end




function [fig, ax, tit] = createGraphs(estSpecs, descript, opt)
list = fieldnames(estSpecs);
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
    hold on
    pos = pos + 1;
end
grfun.clicktocopy(ax);

return


    function processGraphicsOptions( )
        if iscell(opt.Figure)
            figureOpt = opt.Figure;
        end
        if iscell(opt.Axes)
            axesOpt = opt.Axes;
        end
        if iscell(opt.Title)
            titleOpt = opt.Title;
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




function modePoints = getModePoints(summary, max_)
if isempty(summary)
    modePoints = [ ];
    return
end

if isstruct(summary)
    list = fieldnames(summary);
else
    list = summary.Properties.RowNames;
end
nList = numel(list);
modePoints = struct( );
for i = 1 : nList
    ithName = list{i};
    try
        if isstruct(summary)
            x = summary.(ithName);
        else
            x = summary{ithName, 'PosterMode'};
        end
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




function initPoints = hereGetInitPoints(estSpecs, max_, summary)
    initPoints = struct( );
    for name = reshape(string(fieldnames(estSpecs)), 1, [ ])
        temp = estSpecs.(name);
        if isempty(temp)
            x = NaN;
        elseif isnumeric(temp)
            x = temp(1);
        elseif iscell(temp)
            x = temp{1};
        else
            x = NaN;
        end
        % If starting value is NaN,look it up in the summary table
        if isequaln(x, NaN) && isa(summary, 'table')
           try
               x = summary{name, 'Start'};
           end
        end
        % Keep NaNs
        y = 0.98*max_.(name);
        initPoints.(name) = {x, y};
    end
end%




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
        addToTitle = '';
        if isempty(f)
            addToTitle = sprintf('\nPrior: Flat');
        else
            if isa(f, 'distribution.Distribution')
                addToTitle = sprintf('\nPrior: %s {\\mu=}%g {\\sigma=}%g', f.Name, f.Mean, f.Std);
            else
                try
                    name = f([ ], 'name');
                    mu = f([ ], 'mean');
                    sgm = f([ ], 'std');
                    addToTitle = sprintf('\nPrior: %s {\\mu=}%g {\\sigma=}%g', name, mu, sgm);
                end
            end
        end
        tit{iGraph} = [tit{iGraph}, addToTitle];
    end 




    function describeMode( )
        try
            temp = modePoints.(list{iGraph}){1};
            tit{iGraph} = [tit{iGraph}, ...
                sprintf('\nMaximized Poster: %g', temp)];
        end
    end




    function describeInit( )
        isnumericscalar = @(x) isnumeric(x) && isscalar(x);
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
