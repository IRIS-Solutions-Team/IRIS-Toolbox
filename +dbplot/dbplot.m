function [ff, aa, pp] = dbplot(fileName, d, range, varargin)
% dbplot  Master file for dbplot.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[opt, varargin] = passvalopt('dbase.dbplot', varargin{:});

%--------------------------------------------------------------------------

if ~isempty(opt.saveas)
    [~, ~, opt.saveasformat] = fileparts(opt.saveas);
end

% Create report struct.
q = inp2Struct(fileName, opt);

% Resolve auto subplots.
q = resolveSubplot(q);

% Evaluate expressions.
q = evalExpr(q, d, opt);

% Replace empty titles with eval strings.
q = handleEmptyTitles(q, opt);

% Create figures and output database (if requested).
opt.outputdata = nargout>2 ...
    || (~isempty(opt.saveas) || strcmpi(opt.saveasformat, '.csv'));
[ff, aa, pp, figTitle] = render(q, range, opt, varargin{:});

% Apply ex-post options.
postMortem(ff, aa, pp, figTitle, opt);

if opt.pagenumber
    printPageNumber(ff);
end

if ~isempty(opt.saveas)
    saveAs(ff, pp, opt);
end

end




function qq = inp2Struct(inp, opt)
import parser.Preparser;
if isfunc(inp)
    % Input file name can be function handle.
    inp = func2str(inp);
end

if ischar(inp)
    % Q-file
    %--------
    % Preparse a q-file.
    c = parser.Preparser.parse(inp, [ ], struct( ), '', opt.clone);
    
    % Replace escaped % signs.
    c = strrep(c, '\%', '%');
    
    % Replace single quotes with double quotes.
    c = strrep(c, '''', '"');
else
    % Cell array of strings
    %-----------------------
    c = inp;
    nGraph = length(c);
    if isequal(opt.subplot, @auto) && nGraph>opt.maxperfigure
        opt.subplot = grfun.nsubplot(opt.subplot, opt.maxperfigure);
    end
    if ~isempty(opt.clone)
        labels = fragileobj(c);
        [c, labels] = protectquotes(c, labels);
        c = Preparser.cloneAllNames(c, opt.clone);
        c = restore(c, labels);
    end
end

qq = { };
isFirst = true;
while ~isempty(c)
    [c, q] = getNext(c, opt);
    if isequal(q.func, 'subplot')
        opt.subplot = getSubPlot(q.caption);
        continue
    end
    % Add a new figure if there's none at the beginning of the report.
    if isFirst && ~isequal(q.func, 'figure')
        q0 = struct( );
        q0.func = 'figure';
        q0.caption = '';
        q0.subplot = opt.subplot;
        q0.children = { };
        qq{end+1} = q0; %#ok<AGROW>
    end
    if isequal(q.func, 'figure')
        qq{end+1} = q; %#ok<AGROW>
    else
        qq{end}.children{end+1} = q;
    end
    isFirst = false;
end

return




    function x = getSubPlot(C)
        % doGetSubPlot  Convert subplot string to vector or `@auto`.
        x = sscanf(C, '%gx%g');
        if isnumeric(x) && length(x)==2 && all(~isnan(x) & x>0 & isround(x))
            x = x(:).';
        else
            x = @auto;
        end
    end
end 




function [inp, s] = getNext(inp, opt)
s = struct( );
s.func = '';
s.funcArgs = { };
s.caption = '';
s.eval = { };
s.isLogDev = false;
s.isLinDev = false;
s.isTransform = true;

if isempty(inp)
    return
end

if ischar(inp)
    % Replace old syntax !** with !..
    inp = strrep(inp, '!**', '!..');
    % Q-file code from `qplot`.
    tags = '#|!\+\+|!\-\-|!::|!ii|!II|!\.\.|!\^\^';
    [tok, e] = regexp(inp, ['(', tags, ')([\^#@]{0, 2})(.*?)(?=', tags, '|$)'], ...
        'tokens', 'end', 'once');
    if ~isempty(tok)
        s.func = tag2PlotFunc(tok{1});
        resolveFlags(tok{2});
        tok = regexp(tok{3}, '([^\n]*)(.*)', 'once', 'tokens');
        s.caption = tok{1};
        body = tok{2};
        inp = inp(e+1:end);
    end
elseif iscellstr(inp)
    % Cellstr from `dbplot`.
    c = strtrim(inp{1});
    inp = inp(2:end);
    if ~isempty(c)
        s.func = opt.plotfunc;
        if iscell(s.func)
            s.funcArgs = s.func(2:end);
            s.func = s.func{1};
        end
        c = resolveFlags(c);
        [body, s.caption] = parser.Helper.parseLabelExprn(c);
    else
        s.func = 'empty';
        s.legend = { };
        s.tansform = [ ];
    end
else
    return
end

if isequal(s.func, 'empty')
    return
end

% Title.
s.caption = strtrim(s.caption);

if isequal(s.func, 'subplot')
    return
end

if isequal(s.func, 'figure')
    s.subplot = opt.subplot;
    s.children = { };
    return
end

% Expressions and legends.
[s.eval, s.legend] = readBody(body);

return




    function c = resolveFlags(c)
        while true && ~isempty(c)
            switch c(1)
                case '^'
                    s.isTransform = false;
                case '@'
                    if ~s.isLinDev
                        s.isLogDev = true;
                    end
                case '#'
                    if ~s.isLogDev
                        s.isLinDev = true;
                    end
                case ' '
                    % Do nothing.
                otherwise
                    break
            end
            c(1) = '';
        end
    end % doFlags( )
end 




function [evalString, legEntry] = readBody(c)
c = strtrim(c);
c = textfun.strrepoutside(c, ', ', sprintf('\n'), '()', '[]', '{}');
c = textfun.strrepoutside(c, ' & ', sprintf('\n'), '()', '[]', '{}');
lines = regexp(c, '[^\n]*', 'match');
[evalString, legEntry] = parser.Helper.parseLabelExprn(lines);
end 




function q = resolveSubplot(q)
nFig = length(q);
for i = 1 : nFig
    nPanel = length(q{i}.children);
    q{i}.subplot = grfun.nsubplot(q{i}.subplot, nPanel);
end
end 




function q = evalExpr(q, d, opt)
isRound = ~isinf(opt.round) && ~isnan(opt.round);
invalidBase = { };
for i = 1 : length(q)
    for j = 1 : length(q{i}.children)
        ch = q{i}.children{j};
        if isequal(ch.func, 'empty') ...
                || isequal(ch.func, 'subplot') ...
                || isequal(ch.func, 'figure')
            continue
        end
        nSeries = length(ch.eval);
        
        if isempty(opt.SubDatabase)
            % Allow for an array of structs, [d1, d2, d3]. Evaluate
            % expressions first within individual structs, apply
            % transformations, and only then combine all series.
            ndb = length(d);
            series = cell(ndb, nSeries);
            for k = 1 : ndb
                [series{k, :}] = dbeval(d(k), opt.Steady, ch.eval{:});
            end
        else
            % Evaluate expressions in a given list of sub-databases, apply
            % transformations, and only then combine all series.
            lsSub = opt.SubDatabase;
            if ischar(lsSub)
                lsSub = regexp(lsSub, '\w+', 'match');
            else
                lsSub = regexp(lsSub, '\w+', 'match', 'once');
            end
            ndb = numel(lsSub);
            series = cell(ndb, nSeries);
            for k = 1 : ndb
                [series{k, :}] = dbeval(d.(lsSub{k}), opt.Steady, ch.eval{:});
            end
        end
                
        if ch.isTransform
            for k = 1 : numel(series)
                % First, calculate deviations, then apply a tranformation function.
                if isnumericscalar(opt.deviationfrom)
                    t = opt.deviationfrom;
                    if isa(series{k}, 'tseries')
                        if ~isfinite(series{k}(t))
                            invalidBase{end+1} = ch.eval{:}; %#ok<AGROW>
                        end
                        series{k} = computeDeviationFrom(series{k}, ...
                            t, ch.isLogDev, ch.isLinDev, opt.deviationtimes);
                    end
                end
                if isa(opt.transform, 'function_handle')
                    series{k} = opt.transform(series{k});
                end
            end
        end
        if isRound
            for k = 1 : numel(series)
                series{k} = round(series{k}, opt.round);
            end
        end
        if size(series, 1)>1
            temp = series;
            series = cell(1, size(temp, 2));
            for k = 1 : nSeries
                series{1, k} = horzcat(temp{:, k});
            end
            clear temp;
        end
        q{i}.children{j}.series = series;
    end
end

if ~isempty(invalidBase)
    utils.warning('dbplot:dbplot', ...
        ['This expression results in NaN or Inf in base period ', ...
        'for calculating deviations: %s.'], ...
        invalidBase{:})
end
end 




function q = handleEmptyTitles(q, opt)
dateS = '';
if isnumericscalar(opt.deviationfrom)
    dateS = dat2char(opt.deviationfrom);
end
for i = 1 : length(q)
    for j = 1 : length(q{i}.children)
        ch = q{i}.children{j};
        if isequal(ch.func, 'empty') ...
                || isequal(ch.func, 'subplot') ...
                || isequal(ch.func, 'figure')
            continue
        end
        if isempty(ch.caption)
            k = i*j;
            if iscellstr(opt.caption) ...
                    && length(opt.caption) >= k ...
                    && ~isempty(opt.caption{k})
                ch.caption = opt.caption{k};
            elseif isfunc(opt.caption)
                ch.caption = opt.caption;
            else
                ch.caption = [ ...
                    sprintf('%s & ', ch.eval{1:end-1}), ...
                    ch.eval{end}];
                if ch.isTransform
                    func = '';
                    if ch.isLinDev
                        func = [func, ', #', dateS]; %#ok<AGROW>
                    elseif ch.isLogDev
                        func = [func, ', @', dateS]; %#ok<AGROW>
                    end
                    if isa(opt.transform, 'function_handle')
                        c = func2str(opt.transform);
                        func = [func, ', ', ...
                            regexprep(c, '^@\(.*?\)', '', 'once')]; %#ok<AGROW>
                    end
                    if ~isempty(func)
                        ch.caption = [ch.caption, func];
                    end
                end
            end
        end
        q{i}.children{j} = ch;
    end
end

end 




function [vecHFig, vecHAx, plotDb, figTitle] = render(qq, range, opt, varargin)
TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
vecHFig = [ ];
vecHAx = { };
plotDb = struct( );

count = 1;
nRow = NaN;
nCol = NaN;
pos = NaN;
figTitle = { };
lsError = { };
lsUnknown = { };

for i = 1 : length(qq)
    % New figure.
    createNewFigure( );
    
    nchild = length(qq{i}.children);
    for j = 1 : nchild
        
        func = qq{i}.children{j}.func;
        funcArgs = qq{i}.children{j}.funcArgs;
        
        % If `'overflow='` is true we automatically open a new figure when the
        % subplot count overflows; this is the default behaviour for `dbplot`.
        % Otherwise, an error occurs; this is the default behaviour for `qplot`.
        if pos>nRow*nCol && opt.overflow
            % Open a new figure and reset the subplot position `pos`.
            createNewFigure( );
        end
        
        if isequal(func, 'empty')
            pos = pos + 1;
            continue    
        end
        
        % New panel/subplot.
        aa = createNewPanel( );
        
        ch = qq{i}.children{j};
        x = ch.series;
        leg = ch.legend;
        
        % Get title; it can be either a string or a function handle that will be
        % applied to the plotted tseries object.
        tit = getTitle(qq{i}.children{j}.caption, x);
        
        finalLegend = createLegend( );
        % Create an entry for the current panel in the output database. Do not
        % if plotting the panel fails.
        try
            [reportRange, data, ok] = callPlot(func, ...
                funcArgs, aa, range, x, finalLegend, opt, varargin{:});
            if ~ok
                lsUnknown{end+1} = qq{i}.children{j}.caption; %#ok<AGROW>
            end
        catch Error
            lsError{end+1} = qq{i}.children{j}.caption; %#ok<AGROW>
            lsError{end+1} = Error.message; %#ok<AGROW>
        end
        if ~isempty(tit)
            grfun.title(tit, 'interpreter=', opt.interpreter);
        end
        % Create a name for the entry in the output database based on the
        % (user-supplied) prefix and the name of the current panel. Substitute '_'
        % for any [^\w]. If not a valid Matlab name, replace with "Panel#".
        if opt.outputdata
            plotDbName = tit;
            plotDbName = regexprep(plotDbName, '[ ]*//[ ]*', '___');
            plotDbName = regexprep(plotDbName, '[^\w]+', '_');
            plotDbName = [ ...
                sprintf(opt.prefix, count), ...
                plotDbName ...
                ]; %#ok<AGROW>
            if ~isvarname(plotDbName)
                plotDbName = sprintf('Panel%g', count);
            end
            try
                plotDb.(plotDbName) = TIME_SERIES_CONSTRUCTOR(reportRange, data, finalLegend);
            catch %#ok<CTCH>
                plotDb.(plotDbName) = NaN;
            end
        end
        if ~isempty(opt.xlabel)
            xlabel(opt.xlabel);
        end
        if ~isempty(opt.ylabel)
            ylabel(opt.ylabel);
        end
        count = count + 1;
        pos = pos + 1;
    end
        
end

if ~isempty(lsError)
    utils.warning('dbplot:dbplot', ...
        ['Error plotting %s.\n', ...
        '\tUncle says: %s'], ...
        lsError{:});
end

if ~isempty(lsUnknown)
    utils.warning('dbplot:dbplot', ...
        'Unknown or invalid plot function when plotting %s.', ...
        lsUnknown{:});
end

return




    function FinalLeg = createLegend( )
        % Splice legend and marks.
        FinalLeg = { };
        for ii = 1 : length(x)
            for jj = 1 : size(x{ii}, 2)
                c = '';
                if ii <= length(leg)
                    c = [c, leg{ii}]; %#ok<AGROW>
                end
                if jj <= length(opt.mark)
                    c = [c, opt.mark{jj}]; %#ok<AGROW>
                end
                FinalLeg{end+1} = c; %#ok<AGROW>
            end
        end
    end




    function createNewFigure( )
        if isempty(opt.figureopt)
            ff = opt.figurefunc( );
        else
            figureOpt = opt.figureopt;
            figureOpt(1:2:end) = strrep(figureOpt(1:2:end), '=', '');
            ff = figure( figureOpt{:} );
        end
        set(ff, 'SelectionType', 'Open');
        vecHFig = [vecHFig, ff];
        orient('landscape');
        vecHAx{end+1} = [ ];
        nRow = qq{i}.subplot(1);
        nCol = qq{i}.subplot(2);
        pos = 1;
        figTitle{end+1} = qq{i}.caption;
    end




    function aa = createNewPanel( )
        aa = subplot(nRow, nCol, pos);
        vecHAx{end} = [vecHAx{end}, aa];
        set(aa, 'activePositionProperty', 'position');
    end 
end




function [range, data, isOk] = callPlot(func, funcArgs, aa, inpRange, inpData, legEnt, opt, varargin)
isXGrid = opt.grid;
isYGrid = opt.grid;

data = [ ];
isOk = true;

switch func2str(func)
    case {'plot', 'bar', 'barcon', 'stem'}
        inpDataCat = [inpData{:}];
        if isa(inpDataCat, 'tseries')
            [~, range, data] = func(inpRange, inpDataCat, varargin{:}, funcArgs{:});
        elseif ~isempty(inpDataCat)
            data = inpDataCat;
            range = inpRange;
            func(inpRange, inpDataCat, varargin{:}, funcArgs{:});
        else
            % Do nothing.
        end
    case 'errorbar'
        [~, ~, range, data] ...
            = errorbar(inpRange, inpData{:}, varargin{:}, funcArgs{:});
    case 'plotpred'
        [~, ~, ~, range, data] ...
            = plotpred(inpRange, inpData{:}, varargin{:}, funcArgs{:});
    case 'hist'
        data = [ inpData{:} ];
        data = data(inpRange, :);
        range = inpRange;
        [count, pos] = hist(data);
        [~] = bar(pos, count, 'barWidth', 0.8, varargin{:}, funcArgs{:});
        isXGrid = false;
    case 'plotcmp'
        [aa, ~, ~, range, data] ...
            = plotcmp(inpRange, [inpData{:}], varargin{:}, funcArgs{:});
    otherwise
        data = [inpData{:}];
        range = inpRange;
        func(inpRange, [inpData{:}], varargin{:}, funcArgs{:});
end

if opt.tight
    isTseries = getappdata(aa(1), 'IRIS_SERIES');
    if isequal(isTseries, true)
        grfun.yaxistight(aa(1));
    else
        axis(aa, 'tight');
    end
end

if isXGrid
    set(aa, 'xgrid', 'on');
end

if isYGrid
    set(aa, 'ygrid', 'on');
end

if opt.addclick
    grfun.clicktocopy(aa);
end

% Display legend if there is at least one non-empty entry.
if any(~cellfun(@isempty, legEnt))
    legend(legEnt{:}, 'Location', 'Best');
end

if opt.zeroline
    grfun.zeroline(aa);
end

if ~isempty(opt.vline)
    grfun.vline(aa, opt.vline, 'color=', 'black');
end

if ~isempty(opt.highlight)
    grfun.highlight(aa, opt.highlight);
end

end 




function postMortem(ff, aa, plotDb, fifTitle, opt) %#ok<INUSL>
if ~isempty(opt.style)
    grfun.style(opt.style, ff);
end

if opt.addclick
    grfun.clicktocopy([aa{:}]);
end

if ~isempty(opt.clear)
    aa = [ aa{:} ];
    aa = aa(opt.clear);
    if ~isempty(aa)
        tt = get(aa, 'title');
        if iscell(tt)
            tt = [tt{:}];
        end
        delete(tt);
        delete(aa);
    end
end

for i = 1 : length(fifTitle)
    % Figure titles must be created last because the `subplot` commands clear
    % figures.
    if ~isempty(fifTitle{i})
        grfun.ftitle(ff(i), fifTitle{i});
    end
end

if opt.maxfigure
    grfun.maxfigure(ff);
end

if opt.drawnow
    drawnow( );
end
end 




function printPageNumber(ff)
nPage = numel(ff);
count = 0;
for i = 1 : nPage
    figure( ff(i) );
    count = count + 1;
    grfun.ftitle({'', '', sprintf('%g/%g', count, nPage)});
end
end




function saveAs(ff, plotDb, opt)
if strcmpi(opt.saveasformat, '.csv')
    dbsave(plotDb, opt.saveas, Inf, opt.dbsave{:});
    return
end

if strcmpi(opt.saveasformat, '.ps')
    [~, fTitle] = fileparts(opt.saveas);
    psfile = fullfile([fTitle, '.ps']);
    if exist(psfile, 'file')
        utils.delete(psfile);
    end
    for f = ff(:).'
        figure(f);
        orient('landscape');
        print('-dpsc', '-painters', '-append', psfile);
    end
    return
end

if strcmpi(opt.saveasformat, '.pdf')
    [filePath, fileTitle, fileExtension] = fileparts(opt.saveas);
    numberOfFigures = numel(ff);
    for ithFigure = 1 : numberOfFigures
        figure(ff(ithFigure));
        orient landscape;
        print('-dpdf', '-fillpage', fullfile(filePath, sprintf('%s_F%g%s', fileTitle, ithFigure, fileExtension)));
    end
    return
end
end 




function Func = tag2PlotFunc(tag)
% Convert the plotFunc= option in dbplot( ) to the corresponding tag.
switch tag
    case '#'
        Func = 'subplot';
    case '!++'
        Func = 'figure';
    case '!..'
        Func = 'empty';
    case '!--'
        Func = @plot;
    case '!::'
        Func = @bar;
    case '!II'
        Func = @errorbar;
    case '!ii'
        Func = @stem;
    case '!^^'
        Func = @hist;
    case '!>>'
        Func = @plotpred;
    case '!??'
        Func = @plotcmp;
    otherwise
        Func = @plot;
end
end 




function tt = getTitle(titleOpt, x)
% Title is either a user-supplied string or a function handle that will be
% applied to the plotted tseries object.
invalid = '???';
if isfunc(titleOpt)
    try
        tt = titleOpt([x{:}]);
        if iscellstr(tt)
            %Tit = sprintf('%s, ', Tit{:});
            %Tit(end) = '';
            tt = tt{1};
        end
        if ~ischar(tt)
            tt = invalid;
        end
    catch %#ok<CTCH>
        tt = invalid;
    end
elseif ischar(titleOpt)
    tt = titleOpt;
else
    tt = invalid;
end
end 




function x = computeDeviationFrom(x, basePer, isMultiplicative, isAdditive, times)
if isAdditive
    x = times*(x - x(basePer));
elseif isMultiplicative
    x = times*(x./x(basePer) - 1);
end
end
