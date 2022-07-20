function [s, ff, aa] = shockplot(this, shockName, range, listOfNamesToPlot, varargin)
% shockplot  Short-cut for running and plotting plain shock simulation.
%
% ## Syntax ##
%
%     [S, FF, AA] = shockplot(M, ShockName, Range, PlotList, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object that will be simulated.
%
% * `ShockName` [ char ] - Name of the shock that will be simulated.
%
% * `Range` [ DateWrapper ] - Date range on which the shock will be
% simulated.
%
% * `PlotList` [ cellstr ] - List of variables that will be reported; you
% can use the syntax of [`dbase/dbplot`](dbase/dbplot).
%
%
% ## Output Arguments ##
%
% * `S` [ struct ] - Database with simulation results.
%
% * `FF` [ numeric ] - Handles of figure windows created.
%
% * `AA` [ numeric ] - Handles of axes objects created.
%
%
% ## Options Controlling the Simulation ##
%
% * `'Deviation='` [ *`true`* | `false` ] - See the option `'Deviation='`
% in [`model/simulate`](model/simulate).
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - See the option
% `'dtrends='` option in [`model/simulate`](model/simulate).
%
% * `'ShockSize='` [ *`'std'`* | numeric ] - Size of the shock that will
% be simulated; `'std'` means that one std dev of the shock will be
% simulated.
%
%
% ## Options Controlling the Chart Plotted ##
%
% See help on [`dbase/dbplot`](dbase/dbplot) for other options available.
%
%
% ## Description ##
%
% The simulated shock always occurs at time `t=1`. Starting the simulation
% range, `Range`, before `t=1` allows you to simulate anticipated
% shocks.
%
% The graphs automatically include one pre-sample period, i.e. one period
% prior to the start of the simulation.
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    if ischar(listOfNamesToPlot)
        listOfNamesToPlot = { listOfNamesToPlot };
    end
catch %#ok<CTCH>
    listOfNamesToPlot = { };
end


islogicalscalar = @(x) islogical(x) && isscalar(x);
%(
defaults = { ...
    'dbplot', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'Deviation', true, islogicalscalar, ...
    'DTrends, DTrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto), ...
    'simulate', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'shocksize, size', 'std', @(x) isnumeric(x) || (ischar(x) && strcmpi(x, 'std')), ...
};
%)


[opt, varargin] = passvalopt(defaults, varargin{:});

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
lse = this.Quantity.Name(ixe);
range = range(1) : range(end);
ixRequest = strcmp(lse, shockName);
if ~any(ixRequest)
    throw( ...
        exception.Base('Model:InvalidShockName', 'error'), ...
        shockName ...
        ); %#ok<GTARG>
end

if strcmpi(opt.shocksize, 'Std') ...
        || isequal(opt.shocksize, @auto) ...
        || isequal(opt.shocksize, @std)
    shkSize = permute(this.Variant.StdCorr(:, ixRequest, :), [1, 3, 2]);
else
    shkSize = opt.shocksize;
end

if opt.Deviation
    d = zerodb(this, range);
else
    d = sstatedb(this, range);
end

d.(shockName)(1, :) = shkSize;
s = simulate(this,d,range, ...
    'Deviation', opt.Deviation, ...
    'EvalTrends', opt.EvalTrends, ...
    'AppendPresample', true, ...
    opt.simulate{:});

if ~isempty(listOfNamesToPlot)
    plotRange = range(1)-1 : range(end);
    [ff, aa] = dbplot(s, plotRange, listOfNamesToPlot, varargin{:}, opt.dbplot{:});
end

end
