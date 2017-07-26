function d = emptydb(this)
% emptydb  Create model-specific database with empty time series for all variables, shocks and parameters.
%
%
% Syntax
% =======
%
%     D = emptydb(M)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model for which the empty database will be created.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with an empty time series for each
% variable and each shock, and a vector of currently assigned values for
% each parameter.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

numberOfVariants = length(this);
numberOfQuantities = length(this.Quantity);
x = cell(1, numberOfQuantities);
d = cell2struct(x, this.Quantity.Name, 2);
indexOfParameters = this.Quantity.Type==TYPE(4);
emptyTimeSeries = Series([ ], zeros(0, numberOfVariants));

% Add comment to time series for each variable.
labelOrName = getLabelOrName(this.Quantity);
for i = find(~indexOfParameters)
    name = this.Quantity.Name{i};
    d.(name) = comment(emptyTimeSeries, labelOrName{i});
end

% Add a value for each parameter.
d = addparam(this, d);

end
