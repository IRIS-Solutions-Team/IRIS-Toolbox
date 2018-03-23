function [flag, listOfMissing] = chkmissing(this, d, start, varargin)
% chkmissing  Check for missing initial values in simulation database.
%
% __Syntax__
%
%     [Ok, Miss] = chkmissing(M, D, Start)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
% * `D` [ struct ] - Input database for the simulation.
%
% * `Start` [ numeric ] - Start date for the simulation.
%
%
% __Output Arguments__
%
% * `Ok` [ `true` | `false` ] - True if the input database `D` contains
% all required initial values for simulating model `M` from date `Start`.
%
% * `Miss` [ cellstr ] - List of missing initial values.
%
%
% __Options__
%
% * `'error='` [ *`true`* | `false` ] - Throw an error if one or more
% initial values are missing.
%
%
% __Description__
%
% This function does not perform any simulation; it only checks for missing
% initial values in an input database.
%
%
% __Example_
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

opt = passvalopt('model.chkmissing',varargin{:});

%--------------------------------------------------------------------------

listOfMissing = cell.empty(1, 0);

nv = length(this);
[~, ~, nb, nf] = sizeOfSolution(this.Vector);
vecXb = this.Vector.Solution{2}(nf+1:end);

indexOfAvailable = true(1, nb);
for j = 1 : nb
    pos = real( vecXb(j) );
    sh = imag( vecXb(j) );
    name = this.Quantity.Name{pos};
    lag = sh - 1;
    try
        value = rangedata(d.(name), start+lag);
        value = value(:, :);
        if numel(value)==1 && nv>1
            value = repmat(value, 1, nv);
        end
        jthIsInitial = permute(this.Variant.IxInit(:, j, :), [1, 3, 2]);
        indexOfAvailable(j) = all(~isnan(value) | ~jthIsInitial);
    catch
        indexOfAvailable(j) = false;
    end
end

flag = all(indexOfAvailable);
if ~flag
    listOfMissing = printSolutionVector(this, vecXb(~indexOfAvailable));
    if opt.error
        throw( ...
            exception.Base('Model:MissingInitCond', 'error'), ...
            listOfMissing{:} ...
        );
    end
end

end
