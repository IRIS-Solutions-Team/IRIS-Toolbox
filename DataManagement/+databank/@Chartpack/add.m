% Type `web databank/Chartpack/add.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = add(this, input, options)

arguments
    this
    input (1, :) string = string.empty(1, 0)
end

arguments (Repeating)
    options
end


if ~isempty(input)
    addCharts = databank.chartpack.Chart.fromString(input, options{:});
else
    addCharts = databank.chartpack.Chart(options{:});
    addCharts.Data = input;
end

for x = addCharts
    x.ParentChartpack = this;
end

this.Charts = [this.Charts, addCharts];

end%
