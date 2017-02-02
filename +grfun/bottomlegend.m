function Le = bottomlegend(varargin)
% bottomlegend  Horizontal graph legend displayed at the bottom of the figure window.
%
% Syntax
% =======
%
%     Le = grfun.bottomlegend(Entry,Entry,...)
%
% Input arguments
% ================
%
% * `Entry` [ char | cellstr ] - Legend entries; same as in the standard
% `legend` function.
%
% Output arguments
% =================
%
% * `AX` [ numeric ] - Handle to the legend axes object created.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    Le = legend(varargin{:});
else
    % Use the app data `'ExcludeFromLegend'` to exclude objects from legend.
    Le = grfun.xlegend(varargin{:}); %#ok<UNRCH>
end

if ~isempty(Le)
    set(Le, 'orientation', 'horizontal');
    Le = grfun.movetosubplot(Le, 'bottom');
end

end
