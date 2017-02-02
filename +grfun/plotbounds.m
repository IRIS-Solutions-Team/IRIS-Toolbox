function [HLow,HHigh] = plotbounds(Ax,Low,High,Y,PlotBounds)
% plotbounds  [Not a public function] Add lower and upper bounds to estimation diagnostics plots.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

xlim = get(Ax,'xLim');

plotOpt = { };
if iscell(PlotBounds)
    plotOpt = PlotBounds;
    plotOpt(1:2:end) = strrep(plotOpt(1:2:end),'=','');
end

if ischar(PlotBounds) && strcmpi(PlotBounds,'auto')
    % Plot bounds only if they fall within the current x-lims.
    if Low < xlim(1) || Low > xlim(2)
        Low = NaN;
    end
    if High < xlim(1) || High > xlim(2)
        High = NaN;
    end
end
w = [0.02;1/4;1/2;3/4;0.98];
n = length(w);
pos = w*Y;
HLow = plot(Ax,Low(ones(n,1)),pos,'marker','>',plotOpt{:});
HHigh = plot(Ax,High(ones(n,1)),pos,'marker','<',plotOpt{:});
set(HHigh,'color',get(HLow,'color'));

end