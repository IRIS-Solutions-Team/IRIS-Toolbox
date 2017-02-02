function Ax = movetosubplot(Ax,varargin)
% movetosubplot  Move an existing axes object or legend to specified subplot position.
%
% Syntax
% =======
%
%     Ax = grfun.movetosubplot(Ax,M,N,P)
%     Ax = grfun.movetosubplot(Ax,'bottom')
%     Ax = grfun.movetosubplot(Ax,'top')
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handle to an existing axes object or legend.
%
% * `M`, `N`, `P` [ numeric ] - Specification of the new position; see help
% on standard `subplot`.
%
% Output arguments
% =================
%
% * `AX` [ numeric ] - Handle to the axes or legend moved to the new
% position.
%
% Description
% ============
%
% The syntax with `'bottom'` and `'top'` places the axes centered at,
% respectively, the bottom or top of the figure window.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    return
end

oldPos = get(Ax,'position');
Fig = get(Ax,'parent');
set(Fig,'units','normalized');

margin = ishg2(0.01*1, 0.001);

if ischar(varargin{1})
    where = varargin{1};
    varargin(1) = [ ]; 
    switch where
        case 'bottom'
            bottomPos = margin;
            if ~isempty(varargin)
                bottomPos = varargin{1};
                varargin(1) = [ ]; %#ok<NASGU>
            end
            newPos = [0.5-oldPos(3)/2, bottomPos, oldPos(3:4)];
        case 'top'
            topPos = 1 - margin;
            if length(varargin) > 1
                topPos = varargin{1};
                varargin(1) = [ ]; %#ok<NASGU>
            end
            newPos = [0.5-oldPos(3)/2, topPos-oldPos(4), oldPos(3:4)];
    end
else
    helperAx = subplot(varargin{:},'visible','off');
    newPos = get(helperAx,'position');
    %close(helperFig);
    delete(helperAx);
    if isequal(get(Ax,'tag'),'legend')
        newPos(1) = newPos(1) + (newPos(3) - oldPos(3))/2;
        newPos(2) = newPos(2) + (newPos(4) - oldPos(4))/2;
        newPos(3:4) = oldPos(3:4);
    end
end

% Call drawnow( ) to fix a bug in HG2 where some legend entry colors get
% mixed up.
drawnow( );

set(Ax,'position',newPos);

end
