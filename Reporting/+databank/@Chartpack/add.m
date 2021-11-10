% Type `web databank/Chartpack/add.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = add(this, input, varargin)

% >=R2019b
%(
arguments
    this
    input (1, :) string = string.empty(1, 0)
end

arguments (Repeating)
    varargin
end
%)
% >=R2019b


if ~isempty(input)
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

