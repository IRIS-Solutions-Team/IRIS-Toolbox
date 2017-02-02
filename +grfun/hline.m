function [Ln,Cp] = hline(varargin)
% hline  Add horizontal line with text caption at the specified position.
%
% Syntax
% =======
%
%     Ln = hline(Pos,...)
%     Ln = hline(Ax,Pos,...)
%
% Input arguments
% ================
%
% * `'Pos`' [ numeric ] - Vertical position or vector of positions at which
% the horizontal line(s) will be drawn.
%
% * `Ax` [ numeric ] - Handle to an axes object (graph) or to a figure
% window in which the the horizontal line will be added; if not specified
% the line will be added to the current axes.
%
% Output arguments
% =================
%
% * `Ln` [ numeric ] - Handle to the line plotted (line object).
%
% Options
% ========
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude the line from
% legend.
%
% Any options valid for the standard `plot` function.
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

[Ln,Cp] = grfun.myinfline(Ax,'h',varargin{:});

end
