function d = emptydb(this)
% emptydb  Create model database with empty time series for each variable and shock
%
% __Syntax__
%
%     D = emptydb(M)
%
%
% __Input arguments__
%
% * `M` [ model ] - Model for which the empty database will be created.
%
%
% __Output arguments__
%
% * `D` [ struct ] - Database with an empty time series for each
% variable and each shock, and a vector of currently assigned values for
% each parameter.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TYPE = @int8;

%--------------------------------------------------------------------------

numberOfVariants = length(this);
numberOfQuantities = length(this.Quantity);
x = cell(1, numberOfQuantities);
d = cell2struct(x, this.Quantity.Name, 2);
indexOfParameters = this.Quantity.Type==TYPE(4);
emptyTimeSeries = TIME_SERIES_CONSTRUCTOR([ ], zeros(0, numberOfVariants));

% Add comment to time series for each variable.
labelOrName = getLabelOrName(this.Quantity);
for i = find(~indexOfParameters)
    name = this.Quantity.Name{i};
    d.(name) = comment(emptyTimeSeries, labelOrName{i});
end

% Add a value for each parameter.
d = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, d);

end
