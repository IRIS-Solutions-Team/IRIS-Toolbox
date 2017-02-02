function [S, FF, AA] = shockplot(this, shockName, range, lsPlot, varargin)
% shockplot  Short-cut for running and plotting plain shock simulation.
%
% Syntax
% =======
%
%     [S,FF,AA] = shockplot(M,ShockName,SimRange,PlotList,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object that will be simulated.
%
% * `ShkName` [ char ] - Name of the shock that will be simulated.
%
% * `Range` [ numeric | char ] - Date range on which the shock will be
% simulated.
%
% * `PlotList` [ cellstr ] - List of variables that will be reported; you
% can use the syntax of [`dbase/dbplot`](dbase/dbplot).
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with simulation results.
%
% * `FF` [ numeric ] - Handles of figure windows created.
%
% * `AA` [ numeric ] - Handles of axes objects created.
%
% Options affecting the simulation
% =================================
%
% * `'deviation='` [ *`true`* | `false` ] - See the option `'deviation='`
% in [`model/simulate`](model/simulate).
%
% * `'dtrends='` [ *`@auto`* | `true` | `false` ] - See the option
% `'dtrends='` option in [`model/simulate`](model/simulate).
%
% * `'shockSize='` [ *`'std'`* | numeric ] - Size of the shock that will
% be simulated; `'std'` means that one std dev of the shock will be
% simulated.
%
% Options affecting the graphs
% =============================
%
% See help on [`dbase/dbplot`](dbase/dbplot) for other options available.
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
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('ShkName', @ischar);
pp.addRequired('Range', @(x) isdatinp(x));
pp.addRequired('PlotList', @(x) ischar(x) || iscellstr(lsPlot));
pp.parse(this, shockName, range, lsPlot);

[opt, varargin] = passvalopt('model.shockplot', varargin{:});

if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
lse = this.Quantity.Name(ixe);
range = range(1) : range(end);
xRange = range(1)-1 : range(end);
ixRequest = strcmp(lse, shockName);
if ~any(ixRequest)
    utils.error('model:shockplot', ...
        'This is not a valid name of a shock: %s ', ...
        shockName);
end

if strcmpi(opt.shocksize, 'std') ...
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
S = simulate(this,d,range, ...
    'Deviation=', opt.deviation, ...
    'DTrends=', opt.dtrends, ...
    'AddPresample=', true, ...
    opt.simulate{:});

if ~isempty(lsPlot)
    [FF, AA] = dbplot(S, xRange, lsPlot, varargin{:}, opt.dbplot{:});
end

end
