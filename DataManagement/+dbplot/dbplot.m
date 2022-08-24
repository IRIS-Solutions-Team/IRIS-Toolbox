function [ff, aa, pp] = dbplot(list, d, range, opt, varargin)
% dbplot  Master file for dbplot
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------


if ~isempty(opt.SaveAs)
    [~, ~, opt.SaveAsformat] = fileparts(opt.SaveAs);
end

% Create report struct
q = inp2Struct(list, opt);

% Evaluate expressions
q = evalExpr(q, d, opt);

% Replace empty titles with eval strings
q = handleEmptyTitles(q, opt);

% Create figures and output database (if requested).
opt.outputdata = nargout>2 ...
    || (~isempty(opt.SaveAs) || strcmpi(opt.SaveAsformat, '.csv'));
[ff, aa, pp, figureTitle] = render(q, range, opt, varargin{:});

% Apply ex-post options.
postMortem(ff, aa, pp, figureTitle, opt);

if opt.PageNumber
    printPageNumber(ff);
end

if ~isempty(opt.SaveAs)
    saveAs(ff, pp, opt);
end

end%


function qq = inp2Struct(inp, opt)
    c = inp;
    numGraphs = length(c);
    if isequal(opt.SubPlot, @auto) 
        if numGraphs<=opt.MaxPerFigure
            [numRows, numColumns] = visual.backend.optimizeSubplot(numGraphs);
        else
            [numRows, numColumns] = visual.backend.optimizeSubplot(opt.MaxPerFigure);
        end
        opt.SubPlot = [numRows, numColumns];
    end

    qq = struct( );
    qq.func = 'figure';
    qq.caption = '';
    qq.SubPlot = opt.SubPlot;
    qq.children = { };
    while ~isempty(c)
        [c, q] = getNext(c, opt);
        qq.children{end+1} = q;
    end

    return


    function x = getSubPlot(C)
        % doGetSubPlot  Convert subplot string to vector or `@auto`.
        x = sscanf(C, '%gx%g');
        if isnumeric(x) && length(x)==2 && all(~isnan(x) & x>0 & x==round(x))
            x = x(:).';
        else
            x = @auto;
        end
    end%
end%




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

    c = strtrim(inp{1});
    inp = inp(2:end);
    if ~isempty(c)
        s.func = opt.PlotFunc;
        if iscell(s.func)
            s.funcArgs = s.func(2:end);
            s.func = s.func{1};
        end
        c = resolveFlags(c);
        [body, s.caption] = parser.Helper.parseLabelExprn(c);
        s.caption = strtrim(s.caption);
    else
        s.func = 'empty';
        s.legend = { };
        s.tansform = [ ];
        return
    end

    % Expressions and legends; clone expressionx
    [s.eval, s.legend] = readBody(body);
    if any(strlength(opt.Clone)>0)
        s.eval = ModelSource.cloneAllNames(s.eval, opt.Clone);
    end
    if ~isempty(opt.Preprocess)
        s.eval{1} = opt.Preprocess(s.eval{1});
    end
        

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
    end%
end%


function [evalString, legEntry] = readBody(c)
    c = strtrim(c);
    c = textfun.strrepoutside(c, ', ', sprintf('\n'), '()', '[]', '{}');
    c = textfun.strrepoutside(c, ' & ', sprintf('\n'), '()', '[]', '{}');
    lines = regexp(c, '[^\n]*', 'match');
    [evalString, legEntry] = parser.Helper.parseLabelExprn(lines);
end%


function q = evalExpr(q, d, opt)
    isnumericscalar = @(x) isnumeric(x) && isscalar(x);
    isRound = ~isinf(opt.Round) && ~isnan(opt.Round);
    invalidBase = { };
    for j = 1 : length(q.children)
        ch = q.children{j};
        if all(strcmpi(ch.func, 'empty')) ...
                || all(strcmpi(ch.func, 'subplot')) ...
                || all(strcmpi(ch.func, 'figure'))
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
                if isnumericscalar(opt.DeviationFrom)
                    t = opt.DeviationFrom;
                    if isa(series{k}, 'Series')
                        if ~isfinite(series{k}(t))
                            invalidBase{end+1} = ch.eval{:}; %#ok<AGROW>
                        end
                        series{k} = computeDeviationFrom( ...
                            series{k}, ...
                            t, ch.isLogDev, ch.isLinDev, opt.DeviationTimes ...
                        );
                    end
                end
                if isa(opt.Transform, 'function_handle')
                    series{k} = opt.Transform(series{k});
                end
            end
        end
        if isRound
            for k = 1 : numel(series)
                series{k} = round(series{k}, opt.Round);
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
        q.children{j}.series = series;
    end

    if ~isempty(invalidBase)
        utils.warning('dbplot:dbplot', ...
            ['This expression results in NaN or Inf in base period ', ...
            'for calculating deviations: %s.'], ...
            invalidBase{:})
    end
end%


function q = handleEmptyTitles(q, opt)
    isnumericscalar = @(x) isnumeric(x) && isscalar(x);
    dateS = '';
    if isnumericscalar(opt.DeviationFrom)
        dateS = dat2char(opt.DeviationFrom);
    end
    for j = 1 : numel(q.children)
        ch = q.children{j};
        if all(strcmpi(ch.func, 'empty')) ...
                || all(strcmpi(ch.func, 'subplot')) ...
                || all(strcmpi(ch.func, 'figure'))
            continue
        end
        if isempty(ch.caption)
            if iscellstr(opt.Caption) ...
                    && length(opt.Caption)>=j ...
                    && ~isempty(opt.Caption{j})
                ch.caption = opt.Caption{j};
            elseif isa(opt.Caption, 'function_handle')
                ch.caption = opt.Caption;
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
                    if isa(opt.Transform, 'function_handle')
                        c = func2str(opt.Transform);
                        func = [func, ', ', ...
                            regexprep(c, '^@\(.*?\)', '', 'once')]; %#ok<AGROW>
                    end
                    if ~isempty(func)
                        ch.caption = [ch.caption, func];
                    end
                end
            end
        end
        q.children{j} = ch;
    end
end%


function [vecHFig, vecHAx, plotDb, figureTitle] = render(qq, range, opt, varargin)
    vecHFig = [ ];
    vecHAx = { };
    plotDb = struct( );

    count = 1;
    nRow = NaN;
    nCol = NaN;
    pos = NaN;
    figureTitle = { };
    listErrors = { };
    lsUnknown = { };

    % New figure.
    createNewFigure( );
    
    numPanels = numel(qq.children);
    for j = 1 : numPanels
        func = qq.children{j}.func;
        funcArgs = qq.children{j}.funcArgs;
        
        % If Overflow=true we automatically open a new figure when the
        % subplot count overflows; this is the default behaviour for
        % dbplot( )
        if pos>nRow*nCol && opt.Overflow
            % Open a new figure and reset the subplot position
            createNewFigure( );
        end
        
        if all(strcmpi(func, 'empty'))
            pos = pos + 1;
            continue    
        end
        
        % New panel/subplot.
        aa = createNewPanel( );
        
        ch = qq.children{j};
        x = ch.series;
        leg = ch.legend;
        if isempty(x) || isempty(x{1})
            continue
        end
        inputDataCat = [x{:}];
        appropriateRange = selectAppropriateRange(range, inputDataCat);
        
        % Get title; it can be either a string or a function handle that will be
        % applied to the plotted tseries object.
        tit = getTitle(qq.children{j}.caption, x);
        
        finalLegend = createLegend( );
        % Create an entry for the current panel in the output database. Do not
        % if plotting the panel fails.
        try
            [reportRange, data, ok] = callPlot( ...
                func, funcArgs, aa, appropriateRange, x, inputDataCat, finalLegend, opt, varargin{:} ....
            );
            if ~ok
                lsUnknown{end+1} = qq.children{j}.caption; %#ok<AGROW>
            end
        catch Error
            listErrors{end+1} = qq.children{j}.caption; %#ok<AGROW>
            listErrors{end+1} = Error.message; %#ok<AGROW>
        end
        if ~isempty(tit)
            grfun.title(tit, 'interpreter', opt.Interpreter);
        end
        % Create a name for the entry in the output database based on the
        % (user-supplied) prefix and the name of the current panel. Substitute '_'
        % for any [^\w]. If not a valid Matlab name, replace with "Panel#".
        if opt.outputdata
            plotDbName = tit;
            plotDbName = regexprep(plotDbName, '[ ]*//[ ]*', '___');
            plotDbName = regexprep(plotDbName, '[^\w]+', '_');
            plotDbName = [ ...
                sprintf(opt.Prefix, count), ...
                plotDbName ...
                ]; %#ok<AGROW>
            if ~isvarname(plotDbName)
                plotDbName = sprintf('Panel%g', count);
            end
            if isa(inputDataCat, 'Series')
                try
                    plotDb.(plotDbName) = Series(reportRange, data, finalLegend);
                catch %#ok<CTCH>
                    plotDb.(plotDbName) = NaN;
                end
            end
        end
        if ~isempty(opt.XLabel)
            xlabel(opt.XLabel);
        end
        if ~isempty(opt.YLabel)
            ylabel(opt.YLabel);
        end
        count = count + 1;
        pos = pos + 1;
    end

    if ~isempty(listErrors)
        utils.warning('dbplot:dbplot', ...
            ['Error plotting %s.\n', ...
            '\tUncle says: %s'], ...
            listErrors{:});
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
                if jj <= length(opt.Mark)
                    c = [c, opt.Mark{jj}]; %#ok<AGROW>
                end
                FinalLeg{end+1} = c; %#ok<AGROW>
            end
        end
    end%


    function createNewFigure( )
        if isempty(opt.Figure)
            ff = opt.FigureFunc( );
        else
            opt.Figure(1:2:end) = strrep(opt.Figure(1:2:end), '=', '');
            ff = figure( opt.Figure{:} );
        end
        set(ff, 'SelectionType', 'Open');
        vecHFig = [vecHFig, ff];
        orient('landscape');
        vecHAx{end+1} = [ ];
        nRow = qq.SubPlot(1);
        nCol = qq.SubPlot(2);
        pos = 1;
        figureTitle{end+1} = qq.caption;
    end%


    function aa = createNewPanel( )
        aa = subplot(nRow, nCol, pos);
        vecHAx{end} = [vecHAx{end}, aa];
        set(aa, 'ActivePositionProperty', 'Position');
    end%
end%


function [actualRange, data, isOk] = callPlot( func, funcArgs, aa, ...
                                               inputRange, inputData, inputDataCat, ...
                                               legEnt, opt, varargin )
    isXGrid = opt.Grid;
    isYGrid = opt.Grid;

    data = [ ];
    isOk = true;

    if isa(inputDataCat, 'Series')
        switch func2str(func)
            case {'plot', 'bar', 'barcon', 'stem'}
                [~, actualRange, data] = func( ...
                    inputRange, inputDataCat, varargin{:}, funcArgs{:} ...
                );
            case 'errorbar'
                [~, ~, actualRange, data] = errorbar( ...
                    inputRange, inputData{:}, varargin{:}, funcArgs{:} ...
                );
            case 'plotpred'
                [~, ~, ~, actualRange, data] = plotpred( ...
                    inputRange, inputData{:}, varargin{:}, funcArgs{:} ...
                );
            case 'hist'
                data = inputDataCat;
                data = data(inputRange, :);
                actualRange = inputRange;
                [count, pos] = hist(data);
                [~] = bar(pos, count, 'barWidth', 0.8, varargin{:}, funcArgs{:});
                isXGrid = false;
            case 'plotcmp'
                [aa, ~, ~, actualRange, data] = plotcmp( ...
                    inputRange, inputDataCat, varargin{:}, funcArgs{:} ...
                );
            otherwise
                h = func(inputRange, inputDataCat, varargin{:}, funcArgs{:});
                data = inputDataCat;
                actualRange = get(get(get(h(1), 'Parent'), 'XAxis'), 'TickValues');
        end
    else
        if isequal(inputRange, Inf)
            h = func(inputDataCat, varargin{:}, funcArgs{:});
        else
            h = func(inputRange, inputDataCat, varargin{:}, funcArgs{:});
        end
        data = inputDataCat;
        % actualRange = h.XData;
        actualRange = get(get(get(h(1), 'Parent'), 'XAxis'), 'TickValues');
    end

    if opt.Tight
        visual.backend.setAxesTight(aa);
    end

    if isXGrid
        set(aa, 'XGrid', 'On');
    end

    if isYGrid
        set(aa, 'YGrid', 'On');
    end

    if opt.AddClick
        visual.clickToExpand(aa);
    end

    % Display legend if there is at least one non-empty entry.
    if any(~cellfun(@isempty, legEnt))
        legend(legEnt{:}, 'Location', 'Best');
    end

    if opt.ZeroLine
        visual.zeroline(aa);
    end

    if ~isempty(opt.VLine)
        visual.vline(aa, opt.VLine, 'Color', 'Black');
    end

    if ~isempty(opt.Highlight)
        visual.highlight(aa, opt.Highlight);
    end
end%


function postMortem(ff, aa, plotDb, figureTitle, opt) %#ok<INUSL>
    if ~isempty(opt.Style)
        grfun.style(opt.Style, ff);
    end

    if opt.AddClick
        visual.clickToExpand([aa{:}]);
    end

    if ~isempty(opt.Clear)
        aa = [ aa{:} ];
        aa = aa(opt.Clear);
        if ~isempty(aa)
            tt = get(aa, 'Title');
            if iscell(tt)
                tt = [tt{:}];
            end
            delete(tt);
            delete(aa);
        end
    end

    for i = 1 : length(figureTitle)
        % Figure titles must be created last because the `subplot` commands clear
        % figures.
        if ~isempty(figureTitle{i})
            grfun.ftitle(ff(i), figureTitle{i});
        end
    end

    if isstruct(opt.VisualStyle) && ~isempty(fieldnames(opt.VisualStyle))
        visual.style(ff, opt.VisualStyle);
    end

    if ~isempty(opt.AddToPages)
        add(opt.AddToPages, ff);
    end

    if opt.DrawNow
        drawnow( );
    end
end%


function printPageNumber(ff)
    numPages = numel(ff);
    count = 0;
    for i = 1 : numPages
        figure( ff(i) );
        count = count + 1;
        grfun.ftitle({'', '', sprintf('%g/%g', count, numPages)});
    end
end%


function saveAs(ff, plotDb, opt)
    if strcmpi(opt.SaveAsformat, '.csv')
        dbsave(plotDb, opt.SaveAs, Inf, opt.DbSave{:});
        return
    end
    if strcmpi(opt.SaveAsformat, '.ps')
        [~, fTitle] = fileparts(opt.SaveAs);
        psfile = fullfile([fTitle, '.ps']);
        if exist(psfile, 'file')
            delete(psfile);
        end
        for f = ff(:).'
            figure(f);
            orient('landscape');
            print('-dpsc', '-painters', '-append', psfile);
        end
        return
    end
    if strcmpi(opt.SaveAsformat, '.pdf')
        [filePath, fileTitle, fileExtension] = fileparts(opt.SaveAs);
        numFigures = numel(ff);
        for ithFigure = 1 : numFigures
            figure(ff(ithFigure));
            orient landscape;
            print('-dpdf', '-fillpage', fullfile(filePath, sprintf('%s_F%g%s', fileTitle, ithFigure, fileExtension)));
        end
        return
    end
end%


function tt = getTitle(titleOpt, x)
% Title is either a user-supplied string or a function handle that will be
% applied to the plotted tseries object.
    invalid = '???';
    if isa(titleOpt, 'function_handle')
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
end%




function x = computeDeviationFrom(x, basePer, isMultiplicative, isAdditive, times)
    if isAdditive
        x = times*(x - x(basePer));
    elseif isMultiplicative
        x = times*(x./x(basePer) - 1);
    end
end%




function appropriateRange = selectAppropriateRange(range, inputSeries)
    if isa(inputSeries, 'Series')
        freq = inputSeries.Frequency;
    else
        freq = Frequency.INTEGER;
    end
    appropriateRange = Inf;
    for i = 1 : numel(range)
        if ~isnumeric(range{i})
            continue
        end
        ithRange = double(range{i});
        ithFreq = dater.getFrequency(ithRange(1));
        if freq==ithFreq
            appropriateRange = ithRange;
            return
        end
    end
end%

