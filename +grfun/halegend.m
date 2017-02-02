function [lg,lgtt] = halegend(varargin)
    
    lg = [ ];
    
    if isempty(varargin)
        return
    end
    
    if all(ishghandle(varargin{1}))
        ax = varargin{1};
        varargin(1) = [ ];
    else
        ax = gca( );
    end
    
    tt = get(ax,'title');
    ttprop = get(tt);
    set(tt,'string','','visible','off');
    lg = legend(ax,varargin{:});
    set(lg,'location','northOutside','orientation','horizontal');
    list = fieldnames(ttprop);
    list = setdiff(list,{'Parent','Position'});
    lgtt = get(lg,'title');
    set(lgtt,'String',ttprop.String);
    for i = 1 : length(list)
            set(lgtt,list{i},ttprop.(list{i}));
        end
    end
    
end
    