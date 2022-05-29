function [hLow, hHigh] = plotbounds(ax, low, high, y, opt)
% plotbounds  Add lower and upper bounds to estimation diagnostics plots.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

xlim = get(ax, 'XLim');

plotOpt = { };
if iscell(opt)
    plotOpt = opt;
elseif all(strcmpi(opt, 'auto')) || isequal(opt, @auto)
    % Plot bounds only if they fall within the current x-lims.
    if low<xlim(1) || low>xlim(2)
        low = NaN;
    end
    if high<xlim(1) || high>xlim(2)
        high = NaN;
    end
end
w = [0.02; 1/4; 1/2; 3/4; 0.98];
n = length(w);
pos = w*y;
hLow = plot(ax, low(ones(n, 1)), pos, 'marker', '>', plotOpt{:});
hHigh = plot(ax, high(ones(n, 1)), pos, 'marker', '<', plotOpt{:});
set(hHigh, 'color', get(hLow, 'color'));

end
