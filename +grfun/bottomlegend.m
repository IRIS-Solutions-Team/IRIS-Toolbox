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
% Input arguments
% ================
%
% * `entry` [ char | cellstr ] - Legend entries; same as in the standard
% `legend` function.
%
% * `ax` [ Axes ] - Handle to Axes object for which the bottom legend will
% be created.
%
% * `fig` [ Figure ] - Handle to Figure object in which the bottom legend
% will be created for the last Axes object found.
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

ax = NaN;
if ishandle(varargin{1})
    ax = [ ];
    if ~isempty(varargin{1})
        if strcmpi(get(varargin{1}(1), 'Type'), 'Figure')
            n = numel(varargin{1});
            ax = [ ];
            for i = 1 : n
                fig = varargin{1}(i);
                temp = findobj(fig, '-depth', 1, 'type', 'axes');
                ax = [ax, temp(1)];
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
