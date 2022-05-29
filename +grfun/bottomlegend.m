function lg = bottomlegend(varargin)
% bottomlegend  Horizontal graph legend displayed at the bottom of the figure window.
%
% Syntax
% =======
%
%     lg = grfun.bottomlegend(entry, entry, ...)
%     lg = grfun.bottomlegend(ax, entry, entry, ...)
%     lg = grfun.bottomlegend(fig, entry, entry, ...)
%
%
% Input arguments
% ================
%
% * `entry` [ char | cellstr ] - Legend entries; same as in the standard
% `legend` function.
%
% * `ax` [ Axes ] - Handle to Axes objects for which bottom legend will
% be created.
%
% * `fig` [ Figure ] - Handle to Figure objects in which bottom legend
% will be created for the latest Axes object created.
%
%
% Output arguments
% =================
%
% * `lg` [ numeric ] - Handle to Legend objects created.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ax = NaN;

% Input handles can be either Axes objects or Figure objects. If they are
% Figures, find the latest Axes within each Figure, and creat bottom legend
% for it.
if ishandle(varargin{1})
    ax = [ ];
    if ~isempty(varargin{1})
        if strcmpi(get(varargin{1}(1), 'Type'), 'Figure')
            n = numel(varargin{1});
            ax = [ ];
            for i = 1 : n
                fig = varargin{1}(i);
                temp = findobj(fig, '-depth', 1, 'type', 'axes');
                if ~isempty(temp)
                    ax = [ax, temp(1)];
                end
            end
        elseif strcmpi(get(varargin{1}(1), 'Type'), 'Axes')
            ax = varargin{1};
        end
    end
    varargin(1) = [ ];
end

%--------------------------------------------------------------------------

if isequaln(ax, NaN)
    lg = legend(varargin{:});
else
    lg = [ ];
    for i = ax(:).'
        lg = [lg, legend(i, varargin{:})];
    end
end

if ~isempty(lg)
    set(lg, 'Orientation', 'Horizontal');
    grfun.movetosubplot(lg, 'bottom');
end

end
