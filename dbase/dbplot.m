function [ff, aa, pp] = dbplot(d, varargin)
% dbplot  Plot from database
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [FF, AA, PDb] = dbplot(D, ~Range, ~List, ...)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Database (struct) or an array of structs with input data.
%
% * `~Range=@auto` [ DateWrapper | cell | numeric ] - Date range or a cell
% array of date ranges for different date frequencies; if not specified,
% the function [`dbrange`](dbase/dbrange) will be used to determined the
% range plotted (so that it is the same for all time series of a given date
% frequency).
%
% * `~List=@all` [ cellstr | rexp ] - List of expressions (or labelled
% expressions) that will be evaluated and plotted in separate graphs; if
% not specified, all time series name found in the input database `D` will
% be plotted. Alternatively, `List` can be a regular expression (rexp
% object), which will be matched against all time series names in the input
% database.
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
% _Mixed Frequencies_
%
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('dbase.dbplot');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('InputDatabase', @isstruct);
    inputParser.addOptional('Range', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x) || (iscell(x) && ~iscellstr(x)));
    inputParser.addOptional('List', @all, @(x) isequal(x, @all) || iscellstr(x) || isa(x, 'rexp'));
    
    inputParser.addParameter('AddClick', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'Caption', 'Captions', 'Title', 'Titles'}, { }, @(x) isempty(x) || iscellstr(x) || isfunc(x));
    inputParser.addParameter('Clear', [ ], @isnumeric);
    inputParser.addParameter('Clone', '', @ischar);
    inputParser.addParameter({'DeviationFrom', 'DeviationsFrom'}, [ ], @(x) isempty(x) || isequal(x, false) || (isnumeric(x) && isscalar(x)));
    inputParser.addParameter({'DeviationTimes', 'DeviationsTimes'}, 1, @(x) isnumeric(x) && isscalar(x));
    inputParser.addParameter('DbSave', false, @(x) isequal(x, true) || isequal(x, false) || (iscell(x) && iscellstr(x(1:2:end))));
    inputParser.addParameter('DrawNow', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('IncludeInLegend', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Grid', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('FigureFunc', @figure, @(x) isa(x, 'function_handle'));
    inputParser.addParameter({'FigureOpt', 'FigureOptions', 'Figure'}, cell.empty(1, 0), @(x) iscell(x) && iscellstr(x(1:2:end)));
    inputParser.addParameter('Highlight', [ ], @(x) isnumeric(x) || (iscell(x) && all(cellfun(@isnumeric, x))));
    inputParser.addParameter('Interpreter', 'none', @(x) any(strcmpi(x, {'latex', 'tex', 'none'})));
    inputParser.addParameter('Mark', cell.empty(1, 0), @iscellstr);
    inputParser.addParameter('MaxPerFigure', 36, @(x) isintscalar(x) && x>0);
    inputParser.addParameter('Overflow', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'PageNumber', 'PageNumbers'}, false, @(x) isequal(x, true) || isequal(x, false));    
    inputParser.addParameter({'PlotFunc', 'PlotFn'}, @plot, @(x) isfunc(x) || ischar(x) || (iscell(x) && isfunc(x{1}) && iscellstr(x(2:2:end))));
    inputParser.addParameter('Prefix', 'P%g_', @ischar);
    inputParser.addParameter('Round', Inf, @(x) isnumeric(x) && isscalar(x) && x>=0 && round(x)==x);
    inputParser.addParameter('SaveAs', '', @ischar);
    inputParser.addParameter({'Steady', 'SState'}, struct( ), @(x) isempty(x) || isstruct(x) || isa(x, 'model'));
    inputParser.addParameter('Style', struct( ), @(x) isempty(x) || isstruct(x) || (iscellstr(x) && length(x)==1));
    inputParser.addParameter({'SubDatabase', 'SubDbase'}, [ ], @(x) isempty(x) || iscellstr(x) || ischar(x));
    inputParser.addParameter('SubPlot', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && numel(x)==2 && all(round(x)==x) && all(x>0)));
    inputParser.addParameter('Tight', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Transform', [ ], @(x) isempty(x) || isfunc(x));
    inputParser.addParameter('VLine', [ ], @(x) isempty(x) || isnumeric(x));
    inputParser.addParameter('XLabel', '', @(x) ischar(x) || iscellstr(x));
    inputParser.addParameter('YLabel', '', @(x) ischar(x) || iscellstr(x));
    inputParser.addParameter('ZeroLine', false, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(d, varargin{:});
range = inputParser.Results.Range;
list = inputParser.Results.List;
opt = inputParser.Options;
unmatchedOptions = inputParser.UnmatchedInCell;

if isequal(list, @all)
    % All time series names in the input database.
    list = dbnames(d, 'ClassFilter=', 'TimeSubscriptable');
elseif isa(list, 'rexp')
    % Regular expression.
    list = dbnames(d, 'NameFilter=', list, 'ClassFilter=', 'TimeSubscriptable');
end

if isequal(range, @auto)
    range = dbrange(d, list);
end

if ~iscell(range)
    range = { range };
end

%--------------------------------------------------------------------------

[ff, aa, pp] = dbplot.dbplot(list, d, range, opt, unmatchedOptions{:});

end
