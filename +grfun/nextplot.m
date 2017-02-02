function varargout = nextplot(x, varargin)
% nextplot  Simplify the use of the standard subplot function.
%
% Syntax for new figure window with certain subplot division
% ===========================================================
%
%     FF = grfun.nextplot([R,C])
%     FF = grfun.nextplot(R,C)
%
% Syntax for new graph at the next subplot position
% ==================================================
%
%     [AA,NewFig,I]  = grfun.nextplot( )
%
% Input arguments
% ================
%
% * `R` [ numeric ] - Number of rows of graphs in the figure window.
%
% * `C` [ numeric ] - Number of columns of graphs in the figure window.
%
% Output arguments
% =================
%
% * `FF` [ numeric ] - Handle to the figure window created.
%
% * `AA` [ numeric ] - Handle to the axes created.
%
% * `NewFig` [ numeric | empty ] - Handle to the new figure if one was
% opened for the next subplot; empty otherwise.
%
% * `I` [ numeric ] - Count of the subplots created in the current figure
% window including the next one.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

none = nargin>0 && isequaln(x, NaN);

% Open a new figure and initialise subplot data.
if nargin>0 && ~none
    if length(x)==3
        sub = x(1:2);
        current = x(3);
    elseif length(x)==2
        sub = x;
        current = 0;
    elseif length(x)==1
        if ~isempty(varargin) && ~ishandle(varargin{1})
            sub = [x, varargin{1}];
            varargin(1) = [ ];
        else
            s = ceil(sqrt(x));
            if s*(s-1)>=x
                sub = [s-1, s];
            else
                sub = [s, s];
            end
        end
        current = 0;
    end
    fg = figure(varargin{:});
    setappdata(fg, 'IRIS_NEXTPLOT_SUB', sub);
    setappdata(fg, 'IRIS_NEXTPLOT_CURRENT', current);
    setappdata(fg, 'IRIS_NEXTPLOT_FIGUREPROP', varargin);
    varargout{1} = fg;
    return
end

fg = gcf( );
sub = getappdata(fg, 'IRIS_NEXTPLOT_SUB');
current = getappdata(fg, 'IRIS_NEXTPLOT_CURRENT');

if ~isnumeric(sub) || length(sub)~=2 ...
        || ~isnumericscalar(current)
    error('Cannot use NEXTPLOT in this figure.');
end

newFig = [ ];
% Open a new figure if the number of subplots exceeds the maximum.
if current>=prod(sub)
    current = 0;
    figureProp = getappdata(fg, 'IRIS_NEXTPLOT_FIGUREPROP');
    if isempty(figureProp)
        fg = figure( );
    else
        fg = figure(figureProp{:});
    end
    setappdata(fg, 'IRIS_NEXTPLOT_SUB', sub);
    setappdata(fg, 'IRIS_NEXTPLOT_CURRENT', current);
    newFig = fg;
end

% Add new subplot to the current figure.
current = current + 1;
if ~none
    aa = subplot(sub(1), sub(2), current);
    grfun.clicktocopy(aa);
else
    aa = [ ];
end
setappdata(fg, 'IRIS_NEXTPLOT_CURRENT', current);
varargout{1} = aa;
varargout{2} = newFig;
varargout{3} = current;

end
