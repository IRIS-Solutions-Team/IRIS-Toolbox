function barboxes(varargin)

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    ax = varargin{1}(:).';
    varargin(1) = [ ];
else
    ax = gca( );
end

h = { };
for i = ax
    axes(i);

    xTick = get(i,'xTick');
    step = (xTick(2)-xTick(1)) / 2;

    xLim = get(i,'xLim');
    axis(i,'tight');
    yLim = get(i,'yLim');
    tickLength = get(i,'tickLength');
    yLimAdd = (yLim(2) - yLim(1)) / 20;
    set(i,'xLim',xLim,'yLim',[yLim(1)-yLimAdd,yLim(2)+yLimAdd],...
        'xLimMode','manual','yLimMode','manual', ...
        'xTickMode','manual','xGrid','off','tickLength',[0,tickLength(2)]);
    yLim = get(i,'yLim');

    h{end+1} = [ ];
    for j = xTick
        h{end}(end+1) = line([j-step,j-step],yLim);
    end
    h{end}(end+1) = line([j+step,j+step],ylim);
    set(h{end},'lineStyle',get(i,'gridLineStyle'),'color','black');
end

end
