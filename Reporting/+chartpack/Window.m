classdef Window
    properties
        Charts (1, :) chartpack.Chart = chartpack.Chart.empty(1, 0)

        ParentChartpack = []
        WindowSettings = cell.empty(1, 0) 
    end
end
