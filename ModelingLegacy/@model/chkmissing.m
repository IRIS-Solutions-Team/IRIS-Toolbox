function [flag, listOfMissing] = chkmissing(this, d, start, varargin)
% chkmissing  Check for missing initial values in simulation database.
%
% ## Syntax ##
%
%     [Ok, Miss] = chkmissing(M, D, Start)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object.
%
% * `D` [ struct ] - Input database for the simulation.
%
% * `Start` [ numeric ] - Start date for the simulation.
%
%
% ## Output Arguments ##
%
% * `Ok` [ `true` | `false` ] - True if the input database `D` contains
% all required initial values for simulating model `M` from date `Start`.
%
% * `Miss` [ cellstr ] - List of missing initial values.
%
%
% ## Options ##
%
% * `'error='` [ *`true`* | `false` ] - Throw an error if one or more
% initial values are missing.
%
%
% ## Description ##
%
% This function does not perform any simulation; it only checks for missing
% initial values in an input database.
%
%
% __Example_
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

opt = passvalopt('model.chkmissing',varargin{:});

%--------------------------------------------------------------------------

listOfMissing = cell.empty(1, 0);

nv = length(this);
[~, ~, nb, nf] = sizeOfSolution(this.Vector);
vecXb = this.Vector.Solution{2}(nf+1:end);

indexOfAvailable = true(1, nb);
pos = real(vecXb);
sh = imag(vecXb);
lag = sh - 1;
for j = 1 : nb
    name = this.Quantity.Name{ pos(j) };
    try
        value = rangedata( d.(name), start+lag(j) );
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
    listOfMissing = printSolutionVector( this, ...
                                         pos(~indexOfAvailable) + 1i*lag(~indexOfAvailable) );
    if opt.error
        throw( exception.Base('Model:MissingInitCond', 'error'), ...
               listOfMissing{:} );
    end
end

end%

