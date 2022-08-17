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

function [H1, H2, Range, data] = errorbar(varargin)

if all(isgraphics(varargin{1}, 'axes'))
    axesHandle = varargin{1};
    varargin(1) = [];
else
    axesHandle = gca();
end

if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [];
else
    range = Inf;
end

[X, Lo] = deal(varargin{1:2});
varargin(1:2) = [];

Hi = [];
if ~isempty(varargin) 
    if isa(varargin{1}, 'tseries')
        Hi = varargin{1};
        varargin(1) = [];
    end
end

plotSpec = '';
if ~isempty(varargin)
    x = varargin{1};
    if iscell(x)
        plotSpec = x;
        varargin(1) = [];
    elseif (ischar(x) || isstring(x)) && mod(numel(varargin), 2)==1
        plotSpec = x;
        varargin(1) = [];
    end
end


persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;
    addParameter(ip, 'ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(false));
    addParameter(ip, 'Relative', true, @(x) isequal(x, true) || isequal(false));
end
errorbarOpt = parse(ip, varargin{:});


if isempty(plotSpec)
    plotSpec = '';
elseif iscell(plotSpec)
    plotSpec = plotSpec{1};
end

[H1, range, data, time] = tseries.implementPlot(@plot, axesHandle, range, X, plotSpec, ip.UnmatchedInCell{:});

status = get(axesHandle, 'nextPlot');
set(axesHandle, 'nextPlot', 'add');
loData = getData(Lo, range);
if ~isa(Hi, 'tseries')
    Hi = Lo;
end
hiData = getData(Hi, range);
H2 = tseries.myerrorbar(axesHandle, time, data, loData, hiData, errorbarOpt);
set(axesHandle, 'nextPlot', status);

% link = cell(size(h1));
for i = 1 : numel(H1)
    set(H2(i), 'color', get(H1(i), 'color'));
    % link{i} = linkprop([h1(i), h2(i)], 'color');
end
% setappdata(ax, 'link', link);

end%

