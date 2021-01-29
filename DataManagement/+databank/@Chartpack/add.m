function this = add(this, input, varargin)

if isstring(input)
    addCharts = databank.chartpack.Chart.fromString(input, varargin{:});
else
    addCharts = databank.chartpack.Chart(varargin{:});
    addCharts.Data = input;
end

for x = addCharts
    x.ParentChartpack = this;
end

this.Charts = [this.Charts, addCharts];

end%

