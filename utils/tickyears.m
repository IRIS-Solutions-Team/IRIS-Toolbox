function tickyears(varargin)
% tickyears  Year-based grid on X axis.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    vecH = varargin{1};
    varargin(1) = [ ];
else
    vecH = gca( );
end

if ~isempty(varargin)
    n = varargin{1};
else
    n = 1;
end

%--------------------------------------------------------------------------

for i = 1 : numel(vecH)
    peer = getappdata(vecH(i), 'graphicsPlotyyPeer');
    if isempty(peer)
        h = vecH(i);
    else
        h = peer;
    end
    xLim = get(h, 'xLim');
    xTick = floor(xLim(1)) : n : ceil(xLim(end));
    set( h,...
        'XLim', xTick([1, end]),...
        'XLimMode', 'Manual',...
        'XTick', xTick,...
        'XTickMode', 'Manual',...
        'XTickLabelMode', 'Auto' );
end

end
