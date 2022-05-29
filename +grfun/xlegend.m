function Le = xlegend(varargin)
% xlegend  [IRIS4Octave only] Create legend with items excluded from it based on appdata 'ExcludeFromLegend'.
%
%
% Syntax
% =======
%
%      Le = grfun.xlegend(...)
%
% Input arguments
% ================
%
% Input arguments are identical to the standard Matlab function `legend`.
%
%
% Output arguments
% ================
%
% * `Le` [ handle ] - Handle to the legend object created.
%
%
% Description
% ============
%
% This function behaves exactly the same as the standard Matlab function
% `legend` except that it excludes from legend the items whose appdata
% field `'ExcludeFromLegend'` is set to `true`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin{1})==1 && ishghandle(varargin{1})
    ax = varargin{1};
    varargin(1) = [ ];
else
    ax = gca( );
end

ch = allchild(ax);
nch = length(ch);
ix = false(1, nch);
stat = cell(1, nch);
for i = 1 : nch
    if isequal(getappdata(ch(i), 'IRIS_EXCLUDE_FROM_LEGEND'), true)
        stat{i} = get(ch(i), 'HandleVisibility');
        set(ch(i), 'HandleVisibility', 'Off');
    end
end

Le = legend(ax, varargin{:});

for i = find(ix)
    set(ch(i), 'HandleVisibility', stat{i});
end

end
