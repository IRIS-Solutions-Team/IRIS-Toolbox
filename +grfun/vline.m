function [Ln,Cp] = vline(varargin)
% vline  Add vertical line with text caption at the specified position.
%
% Syntax
% =======
%
%     [Ln,Cp] = grfun.vline(Pos,...)
%     [Ln,Cp] = grfun.vline(Ax,Pos,...)
%
% Input arguments
% ================
%
% * `Pos` [ numeric ] - Horizontal position or vector of positions at which
% the vertical line(s) will be drawn.
%
% * `Ax` [ numeric ] - Handle to an axes object (graph) or to a figure
% window in which the the line will be added; if not specified the line
% will be added to the current axes.
%
% Output arguments
% =================
%
% * `Ln` [ numeric ] - Handle to the vline(s) plotted (line objects).
%
% * `Cp` [ numeric ] - Handle to the caption(s) created (text objects).
%
% Options
% ========
%
% * `'caption='` [ char ] - Annotate vline with a text string.
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude vline from
% legend.
%
% * `'hPosition='` [ `'center'` | `'left'` | *`'right'`* ] - Horizontal
% position of the caption.
%
% * `'vPosition='` [ `'bottom'` | `'middle'` | *`'top'`* | numeric ] -
% Vertical position of the caption.
%
% * `'timePosition='` [ `'after'` | `'before'` | *`'middle'`* ] - Placement
% of the vertical line on the time axis: in the middle of the specified
% period, immediately before it (between the specified period and the
% previous one), or immediately after it (between the specified period and
% the next one).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin) >= 2 ...
        && ~ischar(varargin{2}) && all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [ ];
else
    Ax = gca( );
end

[Ln,Cp] = grfun.myinfline(Ax,'v',varargin{:});

end
