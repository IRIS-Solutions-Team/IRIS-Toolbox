function [ff, aa, pp] = dbplot(d, varargin)
% dbplot  Plot from database.
%
% Syntax
% =======
%
%     [FF, AA, PDb] = dbplot(D, List, Range, ...)
%     [FF, AA, PDb] = dbplot(D, Range, List, ...)
%     [FF, AA, PDb] = dbplot(D, List, ...)
%     [FF, AA, PDb] = dbplot(D, Range, ...)
%     [FF, AA, PDb] = dbplot(D, ...)
%
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database (struct) or an array of structs with input data.
%
% * `List` [ cellstr | rexp ] - List of expressions (or labelled
% expressions) that will be evaluated and plotted in separate graphs; if
% not specified, all time series name found in the input database `D` will
% be plotted. Alternatively, `List` can be a regular expression (rexp
% object), which will be matched against all time series names in the input
% database.
%
% * `Range` [ numeric ] - Date range; if not specified, the function
% [`dbrange`](dbase/dbrange) will be used to determined the plotted range
% (same for all graphs).
%
%
% Output arguments
% =================
%
% * `FF` [ numeric ] - Handles to figures created by `qplot`.
%
% * `AA` [ cell ] - Handles to axes created by `qplot`.
%
% * `PDB` [ struct ] - Database with actually plotted series.
%
%
% Options
% ========
%
% * `'addClick='` [ *`true`* | `false` ] - Make axes expand in a new
% graphics figure upon mouse click.
%
% * `'captions='` [ cellstr | @comment | *empty* ] - Strings that will be
% used for titles in the graphs that have no title in the q-file.
%
% * `'clear='` [ numeric | *empty* ] - Serial numbers of graphs (axes
% objects) that will not be displayed.
%
% * `'dbSave='` [ cellstr | *empty* ] - Options passed to `dbsave` when
% `'saveAs='` is used.
%
% * `'deviationsFrom='` [ numeric | *empty* ] - Each expression in `List`
% that starts with a `@` or `#` (see Description) will be reported in
% deviations from this specified date.
%
% * `'deviationsTimes='` [ numeric | *empty* ] - Used only if
% `'deviationsFrom='` is non-empty; each expression in `List` that starts
% with a `@` or `#` (see Description) will be reported in deviations
% multiplied by this number.
%
% * `'drawNow='` [ `true` | *`false`* ] - Call Matlab `drawnow` function
% upon completion of all figures.
%
% * `'figureFunc='` [ func_handle | `@figure` ] - Function to create new
% figure windows.
%
% * `'grid='` [ *`true`* | `false` ] - Add grid lines to all graphs.
%
% * `'highlight='` [ numeric | cell | *empty* ] - Date range or ranges that
% will be highlighted.
%
% * `'interpreter='` [ *`'latex'`* | 'none' ] - Interpreter used in graph
% titles.
%
% * `'mark='` [ cellstr | *empty* ] - Marks that will be added to each
% legend entry to distinguish individual columns of multivariated tseries
% objects plotted.
%
% * `'maxPerFigure='` [ numeric | *`36`* ] - Maximum number of graphs in
% one figure window; if the actual graph count exceeds `maxPerFigure`, the
% option '`subplot=`' is adjusted automatically, and new figure windows are
% opened as needed.
%
% * `'overflow='` [ `true` | *`false`* ] - Open automatically a new figure
% window if the number of subplots exceeds the available total;
% `'overflow='false` means an error will occur instead.
%
% * `'plotFunc='` [ @bar | @hist | *@plot* | @plotcmp | @plotpred | @stem |
% cell ] - Plot function used to create the graphs; use a cell array, 
% `{plotFunc, ...}` to specify extra input arguments that will be passed
% into the plotting function.
%
% * `'prefix='` [ char | *`'P%g_'`* ] - Prefix (a `sprintf` format string)
% that will be used to precede the name of each entry in the `PDb`
% database.
%
% * `'round='` [ numeric | *`Inf`* ] - Round the input data to this number of
% decimals before plotting.
%
% * `'saveAs='` [ char | *empty* ] - File name under which the plotted data
% will be saved either in a CSV data file or a PS graphics file; you can
% use the `'dbsave='` option to control the options used when saving CSV.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all figures and their children created by the `qplot` function.
%
% * `'subplot='` [ *'auto'* | numeric ] - Default subplot division of
% figures, can be modified in the q-file.
%
% * `'sstate='` [ struct | model | *empty* ] - Database or model object
% from which the steady-state values referenced to in the quick-report file
% will be taken.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all created figures upon completion.
%
% * `'transform='` [ function_handle | *empty* ] - Function that will be
% used to trans
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis in each graph
% tight.
%
% * `'vLine='` [ numeric | *empty* ] - Dates at which vertical lines will
% be plotted.
%
% * `'zeroLine='` [ `true` | *`false`* ] - Add a horizontal zero line to
% graphs whose y-axis includes zero.
%
%
% Description
% ============
%
% The function `dbplot` opens a new figure window (as many as needed to
% accommodate all graphs given the option `'subplot='`), and creates a
% graph for each entry in the cell array `List`.
%
% `List` can contain either the names of database fields, or expressions
% referring to database fields; these expressions will be then evaluated in
% the input database context. You can also add labels (that will be
% displayed as graph titles) enclosed in double quotes and preceding the
% expressions. Alternatively, you can specify titles through the option
% `'captions='`. At the beginning of the expression, you can use one of the
% following marks:
%
% * `^` (a hat symbol) means the function specified in the option
% `'transform='` will not be applied to that expression;
%
% * `@` (an at symbol) in combination with the option `'deviationFrom='`
% means that the deviations will reported in multiplicative form (i.e. the
% actual value divided by the base period value).
%
% * `#` (a hash symbol) in combination with the option `'deviationFrom='`
% means that the deviations will reported in additive form (i.e. the actual
% value minus the base period value).
%
%
% Example
% ========
%
% The following command will plot the time series `x` and `y` as deviations
% from `1` multiplied by `100` (see the option `'transform='`), and the
% time series `z` as it is (because of the `^` symbol at the beginning).
% The first series will be labeled simply `'x'`, while the last two series
% will be labeled `'Series y'` and `'Series z'`, respectively.
%
%     dbplot(d, qq(2010, 1):qq(2015, 4), ...
%        { 'x', '"Series y" y', '^"Series z"' }, ...
%        'transform=', @(x) 100*(x-1));
%
%
% Example
% ========
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
%        'deviationsFrom=', yy(2000));
%
%
% Example
% ========
%
% The following command will plot all time series found in the database
% that start with `'a'`.
%
%     dbplot(d, rexp('^a.*'));
%
%
% Example
% ========
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
% use the option `'transform='` to apply the specified function to all
% series before they get plotted:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '[k, ktrend]' }, ...
%         'transform=', @(x) 100*log(x) );
% 
% If some graphs need to be excluded from `'transform='`, use a hat `^` at
% the beginning of the expression:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '^[k, ktrend]' }, ...
%         'transform=', @(x) 100*log(x) );
% 
% Include titles for the individual graphs in double quotes at the
% beginning of each expression:
% 
%     dbplot(s, range, { ...
%         '"Consumption" [c, ctrend]', ...
%         '"Output" [y, ytrend]', ...
%         '"Capital" [k, ktrend]' } );
% 
% or alternatively use the option `'captions='` to do the same thing:
% 
%     dbplot(s, range, ...
%         { '[c, ctrend]', '[y, ytrend]', '[k, ktrend]' }, ....
%         'captions=', {'Consumption', 'Output', 'Capital'} );
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('d', @(x) isstruct(x));
pp.parse(d);

% Allow for `List` or `Range` missing from input arguments, but options
% still present.
list = @all;
range = @auto;
while ~isempty(varargin) && ~ischar(varargin{1}) ...
        && ( isequal(range, @auto) || isequal(list, @all) )
    if isnumeric(varargin{1})
        range = varargin{1};
        varargin(1) = [ ];
        continue
    end
    if iscellstr(varargin{1}) || isa(varargin{1}, 'rexp')
        list = varargin{1};
        varargin(1) = [ ];
        continue
    end
end

if isequal(list, @all)
    % All time series names in the input database.
    list = dbnames(d, 'ClassFilter=', 'tseries');
elseif isa(list, 'rexp')
    % Regular expression.
    list = dbnames(d, 'NameFilter=', list, 'ClassFilter=', 'tseries');
end

if isequal(range, @auto)
    range = dbrange(d, list);
end

%--------------------------------------------------------------------------

[ff, aa, pp] = dbplot.dbplot(list, d, range, varargin{:});

end
