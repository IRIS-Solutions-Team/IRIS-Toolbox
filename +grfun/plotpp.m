function [PrG,PoG,varargout] = plotpp(Pr,varargin)
% plotpp  Plot prior and/or posterior distributions and/or posterior mode.
%
%
% Syntax
% =======
%
%     [PrG,PoG,H] = grfun.plotpp(E,[ ],[ ],...)
%     [PrG,PoG,H] = grfun.plotpp(E,Est,[ ],...)
%     [PrG,PoG,H] = grfun.plotpp(E,[ ],Theta,...)
%     [PrG,PoG,H] = grfun.plotpp(E,[ ],Stats,...)
%     [PrG,PoG,H] = grfun.plotpp(E,Est,Theta,...)
%     [PrG,PoG,H] = grfun.plotpp(E,Est,Stats,...)
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
% * `PrG` [ struct ] - Struct with x- and y-axis coordinates to plot the
% prior distribution for each parameter.
%
% * `PoG` [ struct ] - Struct with x- and y-axis coordinates to plot the
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
% * `'caption='` [ *empty* | cellstr ] - User-supplied graph titles; if
% empty, default captions will be automatically created.
%
% * `'describe='` [ *'auto'* | true | false ] - Include information on
% prior distributions, starting values, and maximised posterior modes in
% the graph titles; `'auto'` means the descriptions will be shown only if
% `'plotPrior='` is true.
%
% * `'ksdensity='` [ numeric | *empty* ] - Number of points over which the
% density will be calculated; if empty, default number will be used
% depending on the backend function available.
%
% * `'plotInit='` [ *`true`* | `false` | cell ] - Plot starting values
% (initial consition used in posterior mode maximisation) as vertical
% stems.
%
% * `'plotPrior='` [ *`true`* | `false` | cell ] - Plot prior
% distributions.
%
% * `'plotMode='` [ *`true`* | `false` | cell ] - Plot maximised posterior
% modes as vertical stems; the modes are taken from  `Est` (and not from
% `Stats` or `Theta`).
%
% * `'plotPoster='` [ *`true`* | `false` | cell ] - Plot posterior
% distributions.
%
% * `'plotBounds='` [ *`true`* | `false` | cell ] - Plot lower and/or upper
% bounds as vertical lines; if `false`, the bounds will be plotted only
% added if within the graph x-limits.
%
% * `'sigma='` [ numeric | *3* ] - Number of std devs from the mean or the
% mode (whichever covers a larger area) to the left and to right that will
% be plotted unless running out of bounds.
%
% * `'tight='` [ *`true`* | `false` ] - Make graph axes tight.
%
% * `'title=`' [ *`true`* | `false` | cell ] - Display graph titles, and
% specify graphics options for the titles.
%
% * `'xLims='` [ struct | *empty* ] - Control the x-limits of the prior and
% posterior graphs.
%
%
% Description
% ============
%
% The options that control what will be plotted in the graphs
% (i.e. `'plotInit='`, `'plotPrior='`, `'plotMode='`, `'plotPoster='`,
% `'plotBounds='`,`'title='`) can be set to one of the following three
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

MO = [ ]; % Maximised posterior mode.
PO = [ ]; % Simulated posterior distribution.

if ~isempty(varargin)
    if isempty(varargin{1}) ...
            || (isstruct(varargin{1}) ...
            && isequal(fieldnames(Pr),fieldnames(varargin{1})))
        MO = varargin{1};
        varargin(1) = [ ];
    end
end

if ~isempty(varargin)
    if isempty(varargin{1}) ...
            || isnumeric(varargin{1}) ...
            || isstruct(varargin{1})
        PO = varargin{1};
        varargin(1) = [ ];
    end
end

opt = passvalopt('grfun.plotpp',varargin{:});

if isequal(opt.describe,'auto')
    opt.describe = ~isequal(opt.plotprior,false);
end

%--------------------------------------------------------------------------

if isempty(MO)
    opt.plotmode = false;
end

if isempty(PO)
    opt.plotposter = false;
end

% Get lower and upper bounds for individual params.
b = xxGetBounds(Pr);

% Get prior function handles.
prF = xxGetPrFunc(Pr);

% Get x-limits for individual priors.
prXLim = xxGetPrXLims(prF,b,opt);

% Compute x- and y-axis co-ordinates for prior graphs.
PrG = xxGetPrGraphs(prF,prXLim);

% Compute x- and y-axis co-ordinates for posterior graphs.
PoG = xxGetPoGraphs(PO,b,opt);

% Find maximum displayed in each graph; they are used in plotting stem
% graphs.
mx = xxGetMax(PrG,PoG);

% Compute x- and y-axis co-ordinates for mode graphs.
mog = xxGetMoGraphs(MO,mx);

% Get starting values for posterior mode maximisation.
ing = xxGetInitGraph(Pr,mx);

% Get x-limits for posteriors.
poxlim = xxGetPoXLims(PoG); %#ok<NASGU>

% Fig = [ ];
% Ax = [ ];
PrLin = [ ];
MoLin = [ ];
PoLin = [ ];
BLin = [ ];
InLin = [ ];

% We're done if actual plots are not requested.
if isequal(opt.plotprior,false) ...
        && isequal(opt.plotposter,false) ...
        && isequal(opt.plotinit,false) ...
        && isequal(opt.plotmode,false)
    return
end

% Create titles.
descript = [ ];
if ~isequal(opt.title,false)
    descript = xxCreateTitles(prF,mog,PoG,ing,opt);
end

% Create graphs.
[Fig,Ax,Tit] = xxCreateGraphs(Pr,descript,opt);

% Plot priors.
if ~isequal(opt.plotprior,false)
    PrLin = xxPlotPriors(Ax,PrG,opt);
end

% Plot starting values.
if ~isequal(opt.plotinit,false)
    InLin = xxplotinit(Ax,ing,opt);
end

% Plot modes.
if ~isequal(opt.plotmode,false)
    MoLin = xxPlotMode(Ax,mog,opt);
end

% Plot posteriors.
if ~isequal(opt.plotposter,false)
    PoLin = xxPlotPoster(Ax,PoG,opt);
end

% Plot bounds as vertical lines.
if ~isequal(opt.plotbounds,false)
    BLin = xxPlotBounds(Ax,b,mx,opt);
end

% Output arguments. For bkw compatiblity, the user can ask for more then
% three, in which case the handle vectors are returned individually.
if nargout > 3
    varargout = { ...
        Fig,Ax,PrLin,PoLin,BLin,Tit,InLin,MoLin, ...
        };
else
    varargout{1} = struct( ...
        'figure',Fig, ...
        'axes',Ax, ...
        'prior',PrLin, ...
        'poster',PoLin, ...
        'bounds',BLin, ...
        'init',InLin, ...
        'mode',MoLin, ...
        'title',Tit ...
        );
end

end


% Subfunctions...


%**************************************************************************


function B = xxGetBounds(Pr)
list = fieldnames(Pr);
nlist = numel(list);
B = struct( );
for i = 1 : nlist
    pr = Pr.(list{i});
    low = -Inf;
    upp = Inf;
    try
        low = pr{2};
    catch
        try %#ok<*TRYNC>
            low = pr(2);
        end
    end
    try
        upp = pr{3};
    catch %#ok<*CTCH>
        try
            upp = pr(3);
        end
    end
    B.(list{i}) = [low,upp];
end
end % xxGetBounds( )


%**************************************************************************


function PrF = xxGetPrFunc(Pr)
list = fieldnames(Pr);
nList = numel(list);
PrF = struct( );
for i = 1 : nList
    try
        PrF.(list{i}) = Pr.(list{i}){4};
    catch
        PrF.(list{i}) = [ ];
    end
end
end % xxGetPrFunc( )


%**************************************************************************


function PrXLim = xxGetPrXLims(PrF,B,Opt)
w = Opt.sigma;
usrXLims = Opt.xlims;

list = fieldnames(PrF);
nList = numel(list);
PrXLim = struct( );
for i = 1 : nList
    f = PrF.(list{i});
    from = NaN;
    to = NaN;
    try
        from = double(usrXLims.(list{i})(1));
        to = double(usrXLims.(list{i})(1));
    end
    if (isnan(from) || isnan(to) ) && ~isempty(f)
        low = B.(list{i})(1);
        high = B.(list{i})(2);
        mean = f([ ],'mean');
        sgm = f([ ],'std');
        mode = f([ ],'mode');
        from = min(mean-w*sgm,mode-w*sgm);
        from = max(from,low);
        to = max(mean+w*sgm,mode+w*sgm);
        if ~isfinite(to)
            to = max(w*mean,w*mode);
        end
        to = min(to,high);
    end
    PrXLim.(list{i}) = [from,to];
end
end % xxGetPrXLims( )


%**************************************************************************


function PrG = xxGetPrGraphs(PrF,PrXLim)
list = fieldnames(PrF);
nList = numel(list);
PrG = struct( );
for i = 1 : nList
    f = PrF.(list{i});
    if isempty(f)
        x = NaN;
        y = NaN;
    else
        from = PrXLim.(list{i})(1);
        to = PrXLim.(list{i})(2);
        x = linspace(from,to,1000);
        y = f(x,'proper');
    end
    PrG.(list{i}) = {x,y};
end
end % xxgetrpxlim( )


%**************************************************************************


function [Fig,Ax,Tit] = xxCreateGraphs(Pr,Descript,Opt)
list = fieldnames(Pr);
nList = numel(list);

nSub = Opt.subplot;
if isequal(nSub,@auto)
    nSub = ceil(sqrt(nList));
    if nSub*(nSub-1) >= nList
        nSub = [nSub-1,nSub];
    else
        nSub = [nSub,nSub];
    end
elseif length(nSub) == 1
    nSub = [nSub,nSub];
end

total = prod(nSub);
Fig = figure( );
Ax = nan(1,nList);
Tit = nan(1,nList);
pos = 1;

figureOpt = { };
axesOpt = { };
titleOpt = { };
doGraphicsOpt( );

for i = 1 : nList
    if pos > total
        Fig = [Fig,figure(figureOpt{:})]; %#ok<AGROW>
        pos = 1;
    end
    Ax(i) = subplot(nSub(1),nSub(2),pos,axesOpt{:});
    if ~isequal(Opt.title,false)
        Tit(i) = title(Descript{i},titleOpt{:});
    end
    hold(Ax(i),'all');
    pos = pos + 1;
end
grfun.clicktocopy(Ax);


    function doGraphicsOpt( )
        if iscell(Opt.figure)
            figureOpt = Opt.figure;
            figureOpt(1:2:end) = strrep(figureOpt(1:2:end),'=','');
        end
        if iscell(Opt.axes)
            axesOpt = Opt.axes;
            axesOpt(1:2:end) = strrep(axesOpt(1:2:end),'=','');
        end
        if iscell(Opt.title)
            titleOpt = Opt.title;
            titleOpt(1:2:end) = strrep(titleOpt(1:2:end),'=','');
        end
    end % doGraphicsOpt( )
end % xxCreateGraphs( )



%**************************************************************************


function PrLin = xxPlotPriors(Ax,PrG,Opt)
list = fieldnames(PrG);
nList = numel(list);
PrLin = [ ];
plotopt = { };
if iscell(Opt.plotprior)
    plotopt = Opt.plotprior;
    plotopt(1:2:end) = strrep(plotopt(1:2:end),'=','');
end
for i = 1 : nList
    prG = PrG.(list{i});
    h = plot(Ax(i),prG{:},plotopt{:});
    PrLin = [PrLin,h]; %#ok<AGROW>
    if Opt.tight
        grfun.yaxistight(Ax(i));
    end
    grid(Ax(i),'on');
end
end % xxPlotPriors( )


%**************************************************************************


function PoLin = xxPlotPoster(Ax,PoG,Opt)
list = fieldnames(PoG);
nList = numel(list);
PoLin = [ ];
plotOpt = { };
if iscell(Opt.plotposter)
    plotOpt = Opt.plotposter;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end),'=','');
end
for i = 1 : nList
    poG = PoG.(list{i});
    h = plot(Ax(i),poG{:},plotOpt{:});
    PoLin = [PoLin,h]; %#ok<AGROW>
    if Opt.tight
        grfun.yaxistight(Ax(i));
    end
    grid(Ax(i),'on');
end
end % xxPlotPoster( )


%**************************************************************************


function MoLin = xxPlotMode(Ax,MoG,Opt)
list = fieldnames(MoG);
nList = numel(list);
MoLin = [ ];
plotOpt = { };
if iscell(Opt.plotmode)
    plotOpt = Opt.plotmode;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end),'=','');
end
for i = 1 : nList
    moG = MoG.(list{i});
    h = stem(Ax(i),moG{:},plotOpt{:});
    MoLin = [MoLin,h]; %#ok<AGROW>
    if Opt.tight
        grfun.yaxistight(Ax(i));
    end
    grid(Ax(i),'on');
end

end % xxPlotMode( ).

%**************************************************************************
function BLin = xxPlotBounds(Ax,B,Max,Opt)

list = fieldnames(B);
nList = numel(list);
BLin = [ ];
for i = 1 : nList
    low = B.(list{i})(1);
    high = B.(list{i})(2);
    y = Max.(list{i});
    [hLow,hHigh] = grfun.plotbounds(Ax(i),low,high,y,Opt.plotbounds);  
    BLin = [BLin,hLow,hHigh]; %#ok<AGROW>
end
end % xxPlotPriors( )


%**************************************************************************


function InLin = xxplotinit(Ax,InG,Opt)
list = fieldnames(InG);
nList = numel(list);
InLin = [ ];
plotOpt = { };
if iscell(Opt.plotinit)
    plotOpt = Opt.plotinit;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end),'=','');
end
for i = 1 : nList
    inG = InG.(list{i});
    if isempty(inG)
        continue
    end
    h = stem(Ax(i),inG{:},plotOpt{:});
    InLin = [InLin,h]; %#ok<AGROW>
    if Opt.tight
        grfun.yaxistight(Ax(i));
    end
    grid(Ax(i),'on');
end
end % xxPlotInit( )


%**************************************************************************


function MoG = xxGetMoGraphs(MO,Max)
if isempty(MO)
    MoG = [ ];
    return
end

list = fieldnames(MO);
nList = numel(list);
MoG = struct( );
for i = 1 : nList
    try
        x = MO.(list{i});
        y = 0.98*Max.(list{i});
        if isnan(y)
            % This happens if there's no prior distribution on this
            % parameter.
            y = 1;
        end
    catch
        x = NaN;
        y = NaN;
    end
    MoG.(list{i}) = {x,y};
end
end % xxGetMoGraphs( )


%**************************************************************************


function PoG = xxGetPoGraphs(Po,B,Opt)
if isempty(Po)
    PoG = [ ];
    return
end

% w = Opt.sigma;
w = 5;
list = fieldnames(B);
nList = numel(list);
for i = 1 : nList
    try
        x = Po.ksdensity(:,1);
        y = Po.ksdensity(:,2);
        PoG.(list{i}) = {x,y};
        continue
    end
    the = doTryGetChain( );
    if ~isempty(the)
        % User supplied simulated posterior distributions.
        low = B.(list{i})(1);
        high = B.(list{i})(2);
        [x,y] = poster.myksdensity(the,low,high,Opt.ksdensity);
        myMean = mean(the);
        myStd = std(the);
        inx = x < myMean-w*myStd | x > myMean+w*myStd;
        x(inx) = [ ];
        y(inx) = [ ];
    else
        x = NaN;
        y = NaN;
    end
    PoG.(list{i}) = {x,y};
end


    function The = doTryGetChain( )
        The = [ ];
        if isnumeric(Po)
            try
                The = Po(i,:);
            end
        else
            try
                The = Po.chain.(list{i});
            end
        end
    end % doTryGetChain( )
end % xxgGetPosGraph( )


%**************************************************************************


function PoXLim = xxGetPoXLims(PoG)
if isempty(PoG)
    PoXLim = [ ];
    return
end

list = fieldnames(PoG);
nList = numel(list);
PoXLim = struct( );
for i = 1 : nList
    poG = PoG.(list{i});
    from = min(poG{1});
    to = max(poG{1});
    PoXLim.(list{i}) = [from,to];
end
end % xxGetPoXLims( )


%**************************************************************************


function InG = xxGetInitGraph(Pr,Max)
list = fieldnames(Pr);
nList = numel(list);
InG = struct( );
for i = 1 : nList
    pr = Pr.(list{i});
    if isempty(pr)
        x = NaN;
    elseif isnumeric(pr)
        x = pr(1);
    elseif iscell(pr)
        x = pr{1};
    else
        x = NaN;
    end
    if isnan(x)
        InG.(list{i}) = [ ];
        continue
    end
    y = 0.98*Max.(list{i});
    InG.(list{i}) = {x,y};
end
end % xxGetInitGraph( )


%**************************************************************************


function Tit = xxCreateTitles(PrF,MoG,~,InG,Opt)
list = fieldnames(PrF);
nList = numel(list);
Tit = cell(1,nList);
for iGraph = 1 : nList
    if iscellstr(Opt.caption) && length(Opt.caption) >= iGraph
        % User-supplied captions.
        Tit{iGraph} = Opt.caption{iGraph};
    else
        % Default captions based on the parameter name; treat underscores because
        % the `'interpreter='` is `'tex'` by default.
        Tit{iGraph} = list{iGraph};
        Tit{iGraph} = strrep(Tit{iGraph},'_','\_');
        Tit{iGraph} = ['{\bf',Tit{iGraph},'}'];
    end
    if ~Opt.describe
        continue
    end
    if ~isequal(Opt.plotprior,false)
        doDescribePrior( );
    end
    if ~isequal(Opt.plotmode,false)
        doDescribeMode( );
    end
    if ~isequal(Opt.plotinit,false)
        doDescribeInit( );
    end
end


    function doDescribePrior( )
        f = PrF.(list{iGraph});
        if isempty(f)
            Tit{iGraph} = [Tit{iGraph},sprintf('\nprior: flat')];
        else
            try
                name = f([ ],'name');
                mu = f([ ],'mean');
                sgm = f([ ],'std');
                Tit{iGraph} = [Tit{iGraph}, ...
                    sprintf('\nprior: %s {\\mu=}%g {\\sigma=}%g', ...
                    name,mu,sgm)];
            end
        end
    end % doDescribePrior( )


    function doDescribeMode( )
        try
            mog = MoG.(list{iGraph}){1};
            Tit{iGraph} = [Tit{iGraph}, ...
                sprintf('\nmaximised poster: %g',mog)];
        end
    end % doDescribeMode( )


    function doDescribeInit( )
        try
            ing = InG.(list{iGraph}){1};
            if isnumericscalar(ing)
                Tit{iGraph} = [Tit{iGraph}, ...
                    sprintf('\nstart: %g',ing)];
            end
        end
    end % doDescribeInit( )
end % xxCreateTitles( )


%**************************************************************************


function Max = xxGetMax(PrG,PoG)
list = fieldnames(PrG);
nList = numel(list);
Max = struct( );
for i = 1 : nList
    prg = PrG.(list{i}){2};
    mx = max(prg(:));
    try
        poG = PoG.(list{i}){2};
        poGMax = max(poG(:));
        mx = max(mx,poGMax);
    end
    Max.(list{i}) = mx;
end
end % xxGetMax( )
