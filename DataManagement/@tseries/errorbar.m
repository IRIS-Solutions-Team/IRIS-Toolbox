function [H1, H2, Range, Data] = errorbar(varargin)
% errorbar  Line plot with error bars.
%
% Syntax
% =======
%
%     [LL, EE, Range] = errorbar(X, W, ...)
%     [LL, EE, Range] = errorbar(Range, X, W, ...)
%     [LL, EE, Range] = errorbar(AA, Range, X, W, ...)
%     [LL, EE, Range] = errorbar(X, Lo, Hi, ...)
%     [LL, EE, Range] = errorbar(Range, X, Lo, Hi, ...)
%     [LL, EE, Range] = errorbar(AA, Range, X, Lo, Hi, ...)
%
% Input arguments
% ================
%
% * `AA` [ numeric ] - Handle to axes in which the graph will be plotted; if
% not specified, the current axes will used.
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `X` [ tseries ] - Tseries object whose data will be plotted as a line
% graph.
%
% * `W` [ tseries ] - Width of the bands that will be plotted around the
% lines.
%
% * `Lo` [ tseries ] - Width of the band below the line.
%
% * `Hi` [ tseries ] - Width of the band above the line.
%
% Output arguments
% =================
%
% * `LL` [ numeric ] - Handles to lines plotted.
%
% * `EE` [ numeric ] - Handles to error bars plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'relative='` [ *`true`* | `false` ] - If `true`, the data for the
% lower and upper bounds are relative to the centre, i.e. the bounds will
% be added to the centre (in this case, `Lo` must be negative numbers and
% `Hi` must be positive numbers). If `false`, the bounds are absolute data
% (in this case `Lo` must be lower than `X`, and `Hi` must be higher than
% `X`).
%
% See help on [`tseries/plot`](tseries/plot).
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% if nargin == 0
%     H1 = [ ];
%     H2 = [ ];
%     return
% end
% 
% if all(ishghandle(varargin{1}))
%     ax = varargin{1}(1);
%     varargin(1) = [ ];
% else
%     ax = gca( );
% end
% 
% if isnumeric(varargin{1})
%     Range = varargin{1};
%     varargin(1) = [ ];
% else
%     Range = Inf;
% end
% 
% x = varargin{1};
% varargin(1) = [ ];
% 
% if isempty(varargin) || ~isa(varargin{1}, 'tseries')
%     low = x;
%     low.data = low.data(:, 2:2:end);
%     low.Comment = low.comment(:, 2:2:end);
%     high = low;
%     x.data = x.data(:, 1:2:end);
%     x.Comment = x.comment(:, 1:2:end);
% else
%     low = varargin{1};
%     varargin(1) = [ ];
%     if ~isempty(varargin) && isa(varargin{1}, 'tseries')
%         high = varargin{1};
%         varargin(1) = [ ];
%     else
%         high = low;
%     end
% end

[Ax, Range, X, Lo, Hi, PlotSpec, varargin] = ...
    irisinp.parser.parse('tseries.errorbar', varargin{:});
[errorbarOpt, varargin] = passvalopt('tseries.errorbar', varargin{:});

%--------------------------------------------------------------------------

[~, H1, Range, Data, time] = tseries.myplot(@plot, Ax, Range, [ ], X, PlotSpec, varargin{:});

status = get(gca( ), 'nextPlot');
set(gca( ), 'nextPlot', 'add');
loData = getdata(Lo, Range);
if ~isa(Hi, 'tseries')
    Hi = Lo;
end
hiData = getdata(Hi, Range);
H2 = tseries.myerrorbar(time, Data, loData, hiData, errorbarOpt);
set(gca( ), 'nextPlot', status);

% link = cell(size(h1));
for i = 1 : numel(H1)
    set(H2(i), 'color', get(H1(i), 'color'));
    % link{i} = linkprop([h1(i), h2(i)], 'color');
end
% setappdata(ax, 'link', link);

end%

