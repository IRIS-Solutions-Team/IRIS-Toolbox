function [s, ff, aa] = shockplot(this, shockName, range, listOfNamesToPlot, varargin)
% shockplot  Short-cut for running and plotting plain shock simulation.
%
% __Syntax__
%
%     [S, FF, AA] = shockplot(M, ShockName, Range, PlotList, ...)
%
%
% __Input Arguments__
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
% __Output Arguments__
%
% * `S` [ struct ] - Database with simulation results.
%
% * `FF` [ numeric ] - Handles of figure windows created.
%
% * `AA` [ numeric ] - Handles of axes objects created.
%
%
% __Options Controlling the Simulation__
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
% __Options Controlling the Chart Plotted__
%
% See help on [`dbase/dbplot`](dbase/dbplot) for other options available.
%
%
% __Description__
%
% The simulated shock always occurs at time `t=1`. Starting the simulation
% range, `Range`, before `t=1` allows you to simulate anticipated
% shocks.
%
% The graphs automatically include one pre-sample period, i.e. one period
% prior to the start of the simulation.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try
    if ischar(listOfNamesToPlot)
        listOfNamesToPlot = { listOfNamesToPlot };
    end
catch %#ok<CTCH>
    listOfNamesToPlot = { };
end

pp = inputParser( );
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('ShockName', @ischar);
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.addRequired('PlotList', @(x) ischar(x) || iscellstr(x));
pp.parse(this, shockName, range, listOfNamesToPlot);

[opt, varargin] = passvalopt('model.shockplot', varargin{:});

if ischar(range)
    range = textinp2dat(range);
end

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

if opt.deviation
    d = zerodb(this, range);
else
    d = sstatedb(this, range);
end

d.(shockName)(1, :) = shkSize;
s = simulate(this,d,range, ...
    'Deviation=', opt.deviation, ...
    'DTrends=', opt.dtrends, ...
    'AppendPresample=', true, ...
    opt.simulate{:});

if ~isempty(listOfNamesToPlot)
    plotRange = range(1)-1 : range(end);
    [ff, aa] = dbplot(s, plotRange, listOfNamesToPlot, varargin{:}, opt.dbplot{:});
end

end
