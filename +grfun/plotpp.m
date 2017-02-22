function [prG, poG, varargout] = plotpp(pr, varargin)
% plotpp  Plot prior and/or posterior distributions and/or posterior mode.
%
%
% Syntax
% =======
%
%     [prG, poG, H] = grfun.plotpp(E, [ ], [ ], ...)
%     [prG, poG, H] = grfun.plotpp(E, Est, [ ], ...)
%     [prG, poG, H] = grfun.plotpp(E, [ ], Theta, ...)
%     [prG, poG, H] = grfun.plotpp(E, [ ], Stats, ...)
%     [prG, poG, H] = grfun.plotpp(E, Est, Theta, ...)
%     [prG, poG, H] = grfun.plotpp(E, Est, Stats, ...)
%
%
% Input arguments
% ================
%
% * `E` [ struct ] - Estimation input struct, see
% [`estimate`](model/estimate), with prior function handles from the
% [logdist](logdist/Contents) package.
%
% * `Est` [ struct | empty ] - Output struct returned by the
% [`model/estimate`](model/estimate) function; `Est` will be used to plot
% the maximised posterior modes.
%
% * `Theta` [ numeric | empty ] - Array with the chain of draws from the
% posterior simulator [`arwm`](poster/arwm).
%
% * `Stats` [ struct | empty ] - Output struct returned by the posterior
% simulator statistics function [`stats`](poster/stats).
%
%
% Output arguments
% =================
%
% * `prG` [ struct ] - Struct with x- and y-axis coordinates to plot the
% prior distribution for each parameter.
%
% * `poG` [ struct ] - Struct with x- and y-axis coordinates to plot the
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
% * `'Caption='` [ *empty* | cellstr ] - User-supplied graph titles; if
% empty, default captions will be automatically created.
%
% * `'Describe='` [ *'auto'* | true | false ] - Include information on
% prior distributions, starting values, and maximised posterior modes in
% the graph titles; `'auto'` means the descriptions will be shown only if
% `'PlotPrior='` is true.
%
% * `'Ksdensity='` [ numeric | *empty* ] - Number of points over which the
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
% modes as vertical stems; the modes are taken from  `Est` (and not from
% `Stats` or `Theta`).
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
            && isequal(fieldnames(pr), fieldnames(varargin{1})))
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

if isequal(opt.describe, 'auto')
    opt.describe = ~isequal(opt.plotprior, false);
end

%--------------------------------------------------------------------------

if isempty(mo)
    opt.plotmode = false;
end

if isempty(po)
    opt.plotposter = false;
end

% Get lower and upper bounds for individual params.
bnd = getBounds(pr);

% Get prior function handles.
prF = getPrFunc(pr);

% Get x-limits for individual priors.
prXLim = getPrXLims(prF, bnd, opt);

% Compute x- and y-axis co-ordinates for prior graphs.
prG = getPrGraphs(prF, prXLim);

% Compute x- and y-axis co-ordinates for posterior graphs.
poG = getPoGraphs(po, bnd, opt);

% Find maximum displayed in each graph; they are used in plotting stem
% graphs.
max_ = getMax(prG, poG);

% Compute x- and y-axis co-ordinates for mode graphs.
moG = getMoGraphs(mo, max_);

% Get starting values for posterior mode maximization.
inG = getInitGraph(pr, max_);

% Get x-limits for posteriors.
poXLim = getPoXLims(poG); %#ok<NASGU>

% fig = [ ];
% ax = [ ];
prLin = [ ];
moLin = [ ];
poLin = [ ];
bndLin = [ ];
inLin = [ ];

% We're done if actual plots are not requested.
if isequal(opt.plotprior, false) ...
        && isequal(opt.plotposter, false) ...
        && isequal(opt.plotinit, false) ...
        && isequal(opt.plotmode, false)
    return
end

% Create titles.
descript = [ ];
if ~isequal(opt.title, false)
    descript = createTitles(prF, moG, poG, inG, opt);
end

% Create graphs.
[fig, ax, tit] = createGraphs(pr, descript, opt);

% Plot priors.
if ~isequal(opt.plotprior, false)
    prLin = plotPriors(ax, prG, opt);
end

% Plot starting values.
if ~isequal(opt.plotinit, false)
    inLin = plotInit(ax, inG, opt);
end

% Plot modes.
if ~isequal(opt.plotmode, false)
    moLin = plotMode(ax, moG, opt);
end

% Plot posteriors.
if ~isequal(opt.plotposter, false)
    poLin = plotPoster(ax, poG, opt);
end

% Plot bounds as vertical lines.
if ~isequal(opt.plotbounds, false)
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




function bnd = getBounds(pr)
list = fieldnames(pr);
nlist = numel(list);
bnd = struct( );
for i = 1 : nlist
    temp = pr.(list{i});
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




function prF = getPrFunc(pr)
list = fieldnames(pr);
nList = numel(list);
prF = struct( );
for i = 1 : nList
    try
        prF.(list{i}) = pr.(list{i}){4};
    catch
        prF.(list{i}) = [ ];
    end
end
end




function prXLim = getPrXLims(prF, bnd, opt)
w = opt.sigma;
usrXLims = opt.xlims;

list = fieldnames(prF);
nList = numel(list);
prXLim = struct( );
for i = 1 : nList
    f = prF.(list{i});
    from = NaN;
    to = NaN;
    try
        from = double(usrXLims.(list{i})(1));
        to = double(usrXLims.(list{i})(1));
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
    prXLim.(list{i}) = [from, to];
end
end




function prG = getPrGraphs(prF, prXLim)
list = fieldnames(prF);
nList = numel(list);
prG = struct( );
for i = 1 : nList
    f = prF.(list{i});
    if isempty(f)
        x = NaN;
        y = NaN;
    else
        from = prXLim.(list{i})(1);
        to = prXLim.(list{i})(2);
        x = linspace(from, to, 1000);
        y = f(x, 'proper');
    end
    prG.(list{i}) = {x, y};
end
end




function [fig, ax, tit] = createGraphs(pr, descript, opt)
list = fieldnames(pr);
nList = numel(list);

nSub = opt.subplot;
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
fig = figure( );
ax = [ ];
tit = [ ];
pos = 1;

for i = 1 : nList
    if pos>total
        fig = [fig, figure(figureOpt{:})]; %#ok<AGROW>
        pos = 1;
    end
    ax = [ax, subplot(nSub(1), nSub(2), pos, axesOpt{:})];
    if ~isequal(opt.title, false)
        tit(i) = title(descript{i}, titleOpt{:});
    end
    hold on;
    pos = pos + 1;
end
grfun.clicktocopy(ax);

return




    function processGraphicsOptions( )
        if iscell(opt.figure)
            figureOpt = opt.figure;
            figureOpt(1:2:end) = strrep(figureOpt(1:2:end), '=', '');
        end
        if iscell(opt.axes)
            axesOpt = opt.axes;
            axesOpt(1:2:end) = strrep(axesOpt(1:2:end), '=', '');
        end
        if iscell(opt.title)
            titleOpt = opt.title;
            titleOpt(1:2:end) = strrep(titleOpt(1:2:end), '=', '');
        end
    end
end




function prLin = plotPriors(ax, prG, opt)
list = fieldnames(prG);
nList = numel(list);
prLin = [ ];
plotopt = { };
if iscell(opt.plotprior)
    plotopt = opt.plotprior;
    plotopt(1:2:end) = strrep(plotopt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = prG.(list{i});
    h = plot(ax(i), temp{:}, plotopt{:});
    prLin = [prLin, h]; %#ok<AGROW>
    if opt.tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end




function poLin = plotPoster(ax, poG, opt)
list = fieldnames(poG);
nList = numel(list);
poLin = [ ];
plotOpt = { };
if iscell(opt.plotposter)
    plotOpt = opt.plotposter;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = poG.(list{i});
    h = plot(ax(i), temp{:}, plotOpt{:});
    poLin = [poLin, h]; %#ok<AGROW>
    if opt.tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end 




function moLin = plotMode(ax, moG, opt)
list = fieldnames(moG);
nList = numel(list);
moLin = [ ];
plotOpt = { };
if iscell(opt.plotmode)
    plotOpt = opt.plotmode;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = moG.(list{i});
    h = stem(ax(i), temp{:}, plotOpt{:});
    moLin = [moLin, h]; %#ok<AGROW>
    if opt.tight
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
    [hLow, hHigh] = grfun.plotbounds(ax(i), low, high, y, opt.plotbounds);  
    bndLin = [bndLin, hLow, hHigh]; %#ok<AGROW>
end
end




function inLin = plotInit(ax, inG, opt)
list = fieldnames(inG);
nList = numel(list);
inLin = [ ];
plotOpt = { };
if iscell(opt.plotinit)
    plotOpt = opt.plotinit;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end), '=', '');
end
for i = 1 : nList
    temp = inG.(list{i});
    if isempty(temp)
        continue
    end
    h = stem(ax(i), temp{:}, plotOpt{:});
    inLin = [inLin, h]; %#ok<AGROW>
    if opt.tight
        grfun.yaxistight(ax(i));
    end
    grid(ax(i), 'on');
end
end




function moG = getMoGraphs(mo, max_)
if isempty(mo)
    moG = [ ];
    return
end

list = fieldnames(mo);
nList = numel(list);
moG = struct( );
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
    moG.(list{i}) = {x, y};
end
end




function poG = getPoGraphs(po, bnd, opt)
if isempty(po)
    poG = [ ];
    return
end

% w = opt.sigma;
w = 5;
list = fieldnames(bnd);
nList = numel(list);
for i = 1 : nList
    try
        x = po.ksdensity(:, 1);
        y = po.ksdensity(:, 2);
        poG.(list{i}) = {x, y};
        continue
    end
    the = tryGetChain( );
    if ~isempty(the)
        % User supplied simulated posterior distributions.
        low = bnd.(list{i})(1);
        high = bnd.(list{i})(2);
        [x, y] = poster.myksdensity(the, low, high, opt.ksdensity);
        myMean = mean(the);
        myStd = std(the);
        inx = x<myMean-w*myStd | x>myMean+w*myStd;
        x(inx) = [ ];
        y(inx) = [ ];
    else
        x = NaN;
        y = NaN;
    end
    poG.(list{i}) = {x, y};
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




function poXLim = getPoXLims(poG)
if isempty(poG)
    poXLim = [ ];
    return
end

list = fieldnames(poG);
nList = numel(list);
poXLim = struct( );
for i = 1 : nList
    temp = poG.(list{i});
    from = min(temp{1});
    to = max(temp{1});
    poXLim.(list{i}) = [from, to];
end
end




function inG = getInitGraph(pr, max_)
list = fieldnames(pr);
nList = numel(list);
inG = struct( );
for i = 1 : nList
    temp = pr.(list{i});
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
    inG.(list{i}) = {x, y};
end
end




function tit = createTitles(prF, MoG, ~, inG, opt)
list = fieldnames(prF);
nList = numel(list);
tit = cell(1, nList);
for iGraph = 1 : nList
    if iscellstr(opt.caption) && length(opt.caption)>=iGraph
        % User-supplied captions.
        tit{iGraph} = opt.caption{iGraph};
    else
        % Default captions based on the parameter name; treat underscores because
        % the Interpreter= is 'tex' by default.
        tit{iGraph} = list{iGraph};
        tit{iGraph} = strrep(tit{iGraph}, '_', '\_');
        tit{iGraph} = ['{\bf', tit{iGraph}, '}'];
    end
    if ~opt.describe
        continue
    end
    if ~isequal(opt.plotprior, false)
        describePrior( );
    end
    if ~isequal(opt.plotmode, false)
        describeMode( );
    end
    if ~isequal(opt.plotinit, false)
        describeInit( );
    end
end

return




    function describePrior( )
        f = prF.(list{iGraph});
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
            temp = MoG.(list{iGraph}){1};
            tit{iGraph} = [tit{iGraph}, ...
                sprintf('\nmaximised poster: %g', temp)];
        end
    end




    function describeInit( )
        try
            h = inG.(list{iGraph}){1};
            if isnumericscalar(h)
                tit{iGraph} = [tit{iGraph}, ...
                    sprintf('\nstart: %g', h)];
            end
        end
    end 
end 




function max_ = getMax(prG, poG)
list = fieldnames(prG);
nList = numel(list);
max_ = struct( );
for i = 1 : nList
    temp = prG.(list{i}){2};
    maxPr = max(temp(:));
    try
        temp = poG.(list{i}){2};
        maxPo = max(temp(:));
    catch
        maxPo = [ ];
    end
    max_.(list{i}) = max([maxPr; maxPo]);
end
end
