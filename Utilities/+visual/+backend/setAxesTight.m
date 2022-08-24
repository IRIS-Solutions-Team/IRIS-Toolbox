% setAxesTight  Set y-axis tight and set x-axis tight in non-time-series charts
%

function setAxesTight(handlesAxes)

    if nargin==0
        handlesAxes = visual.backend.getCurrentAxesIfExists();
    end

    if isempty(handlesAxes)
        return
    end

    for h = reshape(handlesAxes, 1, [])
        set(h, 'yLimSpec', 'tight');
        if ~isequal(getappdata(h, 'IRIS_TimeSeriesPlot'), true)
            set(h, 'xLimSpec', 'tight');
        end
    end

end%

