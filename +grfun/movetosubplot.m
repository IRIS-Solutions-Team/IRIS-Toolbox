function ax = movetosubplot(ax, varargin)
% movetosubplot  Move an existing axes object or legend to specified subplot position.
%
% Syntax
% =======
%
%     ax = grfun.movetosubplot(ax, m, n, P)
%     ax = grfun.movetosubplot(ax, 'bottom')
%     ax = grfun.movetosubplot(ax, 'top')
%
%
% Input arguments
% ================
%
% * `ax` [ numeric ] - Handle to an existing axes object or legend.
%
% * `m`, `n`, `p` [ numeric ] - Specification of the new position; see help
% on standard `subplot`.
%
%
% Output arguments
% =================
%
% * `ax` [ numeric ] - Handle to the axes or legend moved to the new
% position.
%
%
% Description
% ============
%
% The syntax with `'bottom'` and `'top'` places the axes centered at, 
% respectively, the bottom or top of the figure window.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(varargin)
    return
end

if isempty(ax)
    return
end

if numel(ax)>1
    for i = ax(:).'
        grfun.movetosubplot(i, varargin{:});
    end
    return
end

%--------------------------------------------------------------------------

oldPos = get(ax, 'position');
Fig = get(ax, 'parent');
set(Fig, 'units', 'normalized');

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
    helperAx = subplot(varargin{:}, 'visible', 'off');
    newPos = get(helperAx, 'position');
    %close(helperFig);
    delete(helperAx);
    if isequal(get(ax, 'tag'), 'legend')
        newPos(1) = newPos(1) + (newPos(3) - oldPos(3))/2;
        newPos(2) = newPos(2) + (newPos(4) - oldPos(4))/2;
        newPos(3:4) = oldPos(3:4);
    end
end

% Call drawnow( ) to fix a bug in HG2 where some legend entry colors get
% mixed up.
drawnow( );

set(ax, 'position', newPos);

end
