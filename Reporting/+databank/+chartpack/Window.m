classdef Window
    properties
        Charts (1, :) databank.chartpack.Chart = databank.chartpack.Chart.empty(1, 0)

        ParentChartpack = []
        WindowSettings = cell.empty(1, 0) 
    end
end
