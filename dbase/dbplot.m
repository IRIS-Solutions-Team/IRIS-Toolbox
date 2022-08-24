% dbplot  Plot from database
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     [FF, AA, PDb] = dbplot(InputDatabase, ~Range, ~List, ...)
%
%
% __Input Arguments__
%
% * `InputDatabase` [ struct ] - Database (struct) or an array of structs
% with input data.
%
% * `~Range=@auto` [ DateWrapper | cell | `@auto` ] - Date range or a cell
% array of date ranges (for different date frequencies); `@auto` means the
% function [`dbrange`](dbase/dbrange) will be used to determined the range
% plotted, different for each date frequency found in the database.
%
% * `~List=@all` [ cellstr | rexp ] - List of expressions (or labelled
% expressions) that will be evaluated and plotted in separate graphs; if
% not specified, all time series name found in the input database
% `InputDatabase` will be plotted. Alternatively, `List` can be a regular
% expression (rexp object), which will be matched against all time series
% names in the input database.
%
%
% __Output Arguments__
%
% * `FF` [ numeric ] - Handles to figures created by `qplot`.
%
% * `AA` [ cell ] - Handles to axes created by `qplot`.
%
% * `PDB` [ struct ] - Database with actually plotted series.
%
%
% __Options__
%
% * `DdClick=true` [ `true` | `false` ] - Make axes expand in a new
% graphics figure upon mouse click.
%
% * `Captions={ }` [ cellstr | @comment | empty ] - Captions that will be
% used for chart titles;l `@comment` means comments from the time series
% will be used.
%
% * `Clear=[ ]` [ numeric | empty ] - Serial numbers of graphs (axes
% objects) that will not be displayed.
%
% * `DbSave={ }` [ cellstr | empty ] - Options passed to `dbsave( )` when
% `SaveAs=` is used.
%
% * `DeviationsFrom=[ ]` [ DateWrapper | empty ] - Each expression in `List`
% that starts with a `@` or `#` (see Description) will be reported in
% deviations from this specified date.
%
% * `DeviationsTimes=[ ]` [ numeric | empty ] - Used only if
% `DeviationsFrom=` is non-empty; each expression in `List` that starts
% with a `@` or `#` (see Description) will be reported in deviations
% multiplied by this number.
%
% * `DrawNow=false` [ `true` | `false` ] - Call Matlab `drawnow` function
% upon completion of all figures.
%
% * `FigureFunc=@figure` [ func_handle ] - Function to create new figure
% windows.
%
% * `Grid=true` [ `true` | `false` ] - Add grid lines to all graphs.
%
% * `Highlight=[ ]` [ numeric | cell | empty ] - Date range or ranges that
% will be highlighted.
%
% * `Interpreter='latex'` [ `'latex'` | `'none'` ] - Interpreter used in
% graph titles.
%
% * `Mark=''` [ cellstr | empty ] - Marks that will be added to each legend
% entry to distinguish individual columns of multivariated tseries objects
% plotted.
%
% * `MaxPerFigure=36` [ numeric ] - Maximum number of graphs in one figure
% window; if the actual graph count exceeds `MaxPerFigure=`, the option
% `Subplot=` is adjusted automatically, and new figure windows are opened
% as needed.
%
% * `Overflow=false` [ `true` | `false` ] - Open automatically a new figure
% window if the number of subplots exceeds the available total;
% `Overflow=false` means an error will occur instead.
%
% * `PlotFunc=@plot` [ `@bar` | `@hist` | `@plot` | `@plotcmp` |
% `@plotpred` | `@stem1` | cell ] - Plot function used to create the
% graphs; use a cell array, `{plotFunc, ...}` to specify extra input
% arguments that will be passed into the plotting function.
%
% * `Prefix='P%g_'` [ char ] - Prefix (a `sprintf` format string) that will
% be used to precede the name of each entry in the `PDb` database.
%
% * `Round=Inf` [ numeric | `Inf` ] - Round the input data to this number of
% decimals before plotting; `Inf` means no rounding.
%
% * `SaveAs=''` [ char | empty ] - File name under which the plotted data
% will be saved either in a CSV data file or a PS graphics file; you can
% use the `'DbSave='` option to control the options used when saving CSV.
%
% * `SubPlot=@auto` [ `@auto` | numeric ] - Default subplot division of
% figures; `@auto` means the division will be automatically determined for
% the total number of panels (charts) or based on the option
% `MaxPerFigure=`.
%
% * `SState=[ ]'` [ struct | model | empty ] - Database or model object
% from which the steady-state values referenced to in the quick-report file
% will be taken.
%
% * `Style=[ ]` [ struct | empty ] - Style structure that will be applied
% to all figures and their children upon completion.
%
% * `Transform=[ ]` [ function_handle | *empty* ] - Function that will be
% used to transform the data plotted; see Description.
%
% * `Tight=false` [ `true` | `false` ] - Make the y-axis in each graph
% tight.
%
% * `VLine=[ ]` [ numeric | empty ] - Dates at which vertical lines will be
% plotted.
%
% * `ZeroLine=false` [ `true` | `false` ] - Add a horizontal zero line to
% graphs whose y-axis includes zero.
%
%
% __Description__
%
% The function `dbplot( )` opens a new figure window (as many as needed to
% accommodate all graphs given the option `Subplot=`), and creates a
% graph for each entry in the cell array `List`.
%
% `List` can contain either the names of database fields, or expressions
% referring to database fields; these expressions will be then evaluated in
% the input database context. You can also add labels (that will be
% displayed as graph titles) enclosed in double quotes and preceding the
% expressions. Alternatively, you can specify titles through the option
% `Captions=`. At the beginning of the expression, you can use one of the
% following marks:
%
% * `^` (a hat symbol) means the function specified in the option
% `Transform=` will not be applied to that expression;
%
% * `@` (an at symbol) in combination with the option `DeviationFrom=`
% means that the deviations will reported in multiplicative form (i.e. the
% actual value divided by the base period value).
%
% * `#` (a hash symbol) in combination with the option `DeviationFrom=`
% means that the deviations will reported in additive form (i.e. the actual
% value minus the base period value).
%
%
% _Mixed Date Frequencies_
%
% Time series with different date frequencies (yearly, quarterly, monthly,
% and so forth) can also be plotted by `dbplot( )` as long as different
% frequencies are not combined in one chart.
%
% If the input database, `InputDatabase`, comprises time series of
% different date frequencies (for instance, monthly and quarterly), specify
% the plot range as a cell array of date ranges, one for each date
% frequency. If a range is not specified for a certain date frequency, the
% time series of that frequency are plotted with an `Inf` range (see
% below).
%
% Two special range specifications can be used in `dbplot( )`:
%
% 1. `@auto` means that the entire database is first searched, and for each
% date frequency, the earliest start date and the latest end date are
% found among the time series of that frequency. The time series of the
% same date frequency are then plotted on this very same range each.
%
% 2. `Inf` means that each time series will be plotted on its own entire
% range. Time series of the same date frequency may therefore end up being
% plotted on different ranges.
%
%
% __Example__
%
% The following command will plot the time series `x` and `y` as deviations
% from `1` multiplied by `100` (see the option `Transform=`), and the
% time series `z` as it is (because of the `^` symbol at the beginning).
% The first series will be labeled simply `'x'`, while the last two series
% will be labeled `'Series y'` and `'Series z'`, respectively.
%
%     dbplot(d, qq(2010, 1):qq(2015, 4), ...
%        { 'x', '"Series y" y', '^"Series z"' }, ...
%        'Transform=', @(x) 100*(x-1));
%
%
% __Example__
%
% The following command will plot the time series `x` and `y` as deviations
% from year 2000; `x` will be computed as additive deviations (i.e. the
% base period value will be subtracted from its observations) whereas `y`
% will be computed as a multiplicative deviations (i.e. the observations
% will be divided by the base period value). The last time series `z` will
% not be transforme.d
%
%     dbplot(d, yy(2000):yy(2010), ...
%        { '# x', '@ y', 'z' }, ...
%        'DeviationsFrom=', yy(2000));
%
%
% __Example__
%
% The following command will plot all time series found in the database
% that start with an `'a'`.
%
%     dbplot(d, rexp('^a.*'));
%
%
% __Example__
%
% Create an example database with the following fields: `c`, `ctrend`, `y`, 
% `ytrend`, `k`, `ktrend` (the exact way these series are created is, of
% course, irrelevant):
%
%     range = qq(2000, 1):qq(2004, 4);
%     s = struct( );
%     s.c = 1+cumsum( Series(range, @rand)/10 );
%     s.ctrend = hpf(s.c);
%     s.y = 1+cumsum( Series(range, @rand)/10 );
%     s.ytrend = hpf(s.y);
%     s.k = 1+ cumsum( Series(range, @rand)/10 );
%     s.ktrend = hpf(s.k);
%     disp(s);
%     
% Plot the individual series against their respective trends, each in its
% own graph:
%
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '[k, ktrend]' } );
% 
% To automate this task, create the list of expressions to be plotted using
% the standard Matlab function `strcat`:
% 
%     list = {'c', 'y', 'k'};
%     plotList = strcat( '[' , list , ', ' , list , 'trend]' );
%     disp(plotList);
%     dbplot(s, range, plotList);
% 
% In the case of some complex transformation(s), e.g.
% 
%     dbplot(s, range, { ...
%         '100*log([c, ctrend])',  ...
%         '100*log([y, ytrend])', ...
%         '100*log([k, ktrend])' } );
% 
% use the option `Transform=` to apply the specified function to all
% series before they get plotted:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '[k, ktrend]' }, ...
%         'Transform=', @(x) 100*log(x) );
% 
% If some graphs need to be excluded from `Transform=`, use a hat `^` at
% the beginning of the expression:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '^[k, ktrend]' }, ...
%         'Transform=', @(x) 100*log(x) );
% 
% Include titles for the individual graphs in double quotes at the
% beginning of each expression:
% 
%     dbplot(s, range, { ...
%         '"Consumption" [c, ctrend]', ...
%         '"Output" [y, ytrend]', ...
%         '"Capital" [k, ktrend]' } );
% 
% or alternatively use the option `Captions=` to do the same thing:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '[k, ktrend]' }, ....
%         'Captions=', {'Consumption', 'Output', 'Capital'} );
%
%
% __Example__
%
% The database `d` comprises four series. Two quarterly series, `ShortQ`
% and `LongQ`, range from `2001Q1` to `2010Q4` and from `1991Q1` to
% `2020Q4`, respectively. Two monthly series,`ShortM` and `LongM`, range
% from `2001M01` to `2010M12` and from `1991M01` to `2020M12`, respectivel.
%
% The range specification `Inf`
%
%     dbplot(d, Inf, ...
%         {'ShortQ', 'LongQ', 'ShortM'm, 'LongM'});
%
% plots the series each on its entire range available:
%
% * `ShortQ`: `2001Q1` to `2010Q4`
% * `LongQ`:  `1991Q1` to `2020Q4`
% * `ShortM`: `2001M01` to `2010M12`
% * `LongM`:  `1991M01` to `2020M12`
%
% The range specification `@auto`
%
%     dbplot(d, Inf, ...
%         {'ShortQ', 'LongQ', 'ShortM'm, 'LongM'});
%
% plots the series of the same frequency on the same range (created from
% the earliest start date to the latest end date among that date
% frequency):
%
% * `ShortQ`: `1991Q1` to `2020Q4`
% * `LongQ`:  `1991Q1` to `2020Q4`
% * `ShortM`: `1991M01` to `2020M12`
% * `LongM`:  `1991M01` to `2020M12`
%
% If a range is specified for one frequency only,
%
%     dbplot(d, qq(2005,1):qq(2009,4), ...
%         {'ShortQ', 'LongQ', 'ShortM'm, 'LongM'});
%
% or equivalently
%
%     dbplot(d, { qq(2005,1):qq(2009,4) }, ...
%         {'ShortQ', 'LongQ', 'ShortM'm, 'LongM'});
%
% the time series of the other frequency (or frequencies) are plotted as if
% with `Inf`:
%
% * `ShortQ`: `2005Q1` to `2009Q4`
% * `LongQ`:  `2005Q1` to `2009Q4`
% * `ShortM`: `2001M01` to `2010M12`
% * `LongM`:  `1991M01` to `2020M12`
%
% Finally, date ranges can be specified for more than one frequency using a
% cell array (the order of the ranges within the cell array does not
% matter):
%
%     dbplot(d, { qq(2005,1):qq(2009,4), mm(1995,1):mm(2030,12) }, ...
%         {'ShortQ', 'LongQ', 'ShortM'm, 'LongM'});
%
% In that case, the time series will be plotted on those ranges
% accordingly:
%
% * `ShortQ`: `2005Q1` to `2009Q4`
% * `LongQ`:  `2005Q1` to `2009Q4`
% * `ShortM`: `1995M01` to `2030M12`
% * `LongM`:  `1995M01` to `2030M12`
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [ff, aa, pp] = dbplot(d, varargin)

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbplot');
    parser.KeepUnmatched = true;
    parser.addRequired('InputDatabase', @isstruct);
    parser.addOptional('Range', @auto); %, @(x) isequal(x, @auto) || validate.date(x) || (iscell(x) && ~iscellstr(x)));
    parser.addOptional('List', @all, @(x) isequal(x, @all) || iscellstr(x) || isa(x, 'rexp') || isa(x, 'string'));
    
    parser.addParameter('AddClick', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('AddToPages', [ ], @(x) isempty(x) || isa(x, 'pages.New'));
    parser.addParameter({'Caption', 'Captions', 'Title', 'Titles'}, { }, @(x) isempty(x) || iscellstr(x) || isa(x, 'function_handle'));
    parser.addParameter('Clear', [ ], @isnumeric);
    parser.addParameter('Clone', ["", ""], @(x) isstring(x) && isequal(size(x), [1, 2]));
    parser.addParameter({'DeviationFrom', 'DeviationsFrom'}, [ ], @(x) isempty(x) || isequal(x, false) || (isnumeric(x) && isscalar(x)));
    parser.addParameter({'DeviationTimes', 'DeviationsTimes'}, 1, @(x) isnumeric(x) && isscalar(x));
    parser.addParameter('DbSave', false, @(x) isequal(x, true) || isequal(x, false) || (iscell(x) && iscellstr(x(1:2:end))));
    parser.addParameter('DrawNow', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('IncludeInLegend', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Grid', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('FigureFunc', @figure, @(x) isa(x, 'function_handle'));
    parser.addParameter({'Figure', 'FigureOpt', 'FigureOptions'}, cell.empty(1, 0), @(x) iscell(x) && iscellstr(x(1:2:end)));
    parser.addParameter('Highlight', [ ], @(x) isnumeric(x) || (iscell(x) && all(cellfun(@isnumeric, x))));
    parser.addParameter('Interpreter', 'none', @(x) any(strcmpi(x, {'latex', 'tex', 'none'})));
    parser.addParameter('Mark', cell.empty(1, 0), @iscellstr);
    parser.addParameter('MaxPerFigure', 36, @(x) isintscalar(x) && x>0);
    parser.addParameter('Overflow', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'PageNumber', 'PageNumbers'}, false, @(x) isequal(x, true) || isequal(x, false));    
    parser.addParameter({'PlotFunc', 'PlotFn'}, @plot, @(x) isa(x, 'function_handle') || ischar(x) || (iscell(x) && isa(x{1}, 'function_handle') && iscellstr(x(2:2:end))));
    parser.addParameter('Prefix', 'P%g_', @ischar);
    parser.addParameter('Preprocess', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addParameter('Round', Inf, @(x) isnumeric(x) && isscalar(x) && x>=0 && round(x)==x);
    parser.addParameter('SaveAs', '', @ischar);
    parser.addParameter({'Steady', 'SState'}, struct( ), @(x) isempty(x) || isstruct(x) || isa(x, 'model'));
    parser.addParameter('Style', struct( ), @(x) isempty(x) || isstruct(x) || (iscellstr(x) && length(x)==1));
    parser.addParameter('VisualStyle', struct( ), @(x) isempty(x) || isstruct(x) || (iscellstr(x) && length(x)==1));
    parser.addParameter({'SubDatabase', 'SubDbase'}, [ ], @(x) isempty(x) || iscellstr(x) || ischar(x));
    parser.addParameter('SubPlot', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && numel(x)==2 && all(round(x)==x) && all(x>0)));
    parser.addParameter('Tight', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Transform', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addParameter('VLine', [ ], @(x) isempty(x) || isnumeric(x));
    parser.addParameter('XLabel', '', @(x) ischar(x) || iscellstr(x));
    parser.addParameter('YLabel', '', @(x) ischar(x) || iscellstr(x));
    parser.addParameter('ZeroLine', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(parser, d, varargin{:});
range = parser.Results.Range;
list = parser.Results.List;
opt = parser.Options;
unmatchedOptions = parser.UnmatchedInCell;

if isequal(list, @all)
    % All time series names in the input database.
    list = dbnames(d, 'ClassFilter', 'Series');
elseif isa(list, 'rexp')
    % Regular expression.
    list = dbnames(d, 'NameFilter', list, 'ClassFilter', 'Series');
elseif isa(list, 'string')
    list = cellstr(list);
end

if isequal(range, @auto)
    range = dbrange(d, list);
end

if ~iscell(range)
    range = { range };
end

%--------------------------------------------------------------------------

[ff, aa, pp] = dbplot.dbplot(list, d, range, opt, unmatchedOptions{:});

end%

