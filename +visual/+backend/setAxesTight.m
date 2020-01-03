function setAxesTight(handlesAxes)
% setAxesTight  Set y-axis tight and set x-axis tight in non-time-series charts
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin==0
    handlesAxes = visual.backend.getCurrentAxesIfExists( );
end

%--------------------------------------------------------------------------

if isempty(handlesAxes)
    return
end

for i = 1 : numel(handlesAxes)
    ithAxes = handlesAxes(i);
    set(ithAxes, 'YLimSpec', 'Tight');
    isTseries = getappdata(ithAxes, 'IRIS_SERIES');
    isTimeSubscriptable = getappdata(ithAxes, 'IRIS_TimeSeriesPlot');
    if ~isequal(isTseries, true) && ~isequal(isTimeSubscriptable, true)
        set(ithAxes, 'XLimSpec', 'Tight');
    end
end

end%

