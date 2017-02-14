function [s, ff, aa] = shockplot(this, shockName, range, lsPlot, varargin)
% shockplot  Short-cut for running and plotting plain shock simulation.
%
% Syntax
% =======
%
%     [s, ff, aa] = shockplot(m, shockName, range, plotLis,...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object that will be simulated.
%
% * `shockName` [ char ] - Name of the shock that will be simulated.
%
% * `range` [ numeric | char ] - Date range on which the shock will be
% simulated.
%
% * `plotList` [ cellstr ] - List of variables that will be reported; you
% can use the syntax of [`dbase/dbplot`](dbase/dbplot).
%
%
% Output arguments
% =================
%
% * `s` [ struct ] - Database with simulation results.
%
% * `ff` [ numeric ] - Handles of figure windows created.
%
% * `aa` [ numeric ] - Handles of axes objects created.
%
%
% Options affecting the simulation
% =================================
%
% * `'Deviation='` [ *`true`* | `false` ] - See the option `'deviation='`
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
% Options affecting the graphs
% =============================
%
% See help on [`dbase/dbplot`](dbase/dbplot) for other options available.
%
%
% Description
% ============
%
% The simulated shock always occurs at time `t=1`. Starting the simulation
% range, `SimRange`, before `t=1` allows you to simulate anticipated
% shocks.
%
% The graphs automatically include one pre-sample period, i.e. one period
% prior to the start of the simulation.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    if ischar(lsPlot)
        lsPlot = {lsPlot};
    end
catch %#ok<CTCH>
    lsPlot = { };
end

pp = inputParser( );
pp.addRequired('m', @(x) isa(x, 'model'));
pp.addRequired('shockName', @ischar);
pp.addRequired('range', @(x) isdatinp(x));
pp.addRequired('plotList', @(x) ischar(x) || iscellstr(lsPlot));
pp.parse(this, shockName, range, lsPlot);

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
    shkSize = model.Variant.getStdCorr(this.Variant, ixRequest, ':');
    shkSize = permute(shkSize, [1, 3, 2]);
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

if ~isempty(lsPlot)
    plotRange = range(1)-1 : range(end);
    [ff, aa] = dbplot(s, plotRange, lsPlot, varargin{:}, opt.dbplot{:});
end

end
